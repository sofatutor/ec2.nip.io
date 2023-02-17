# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
  profile = "sofatutor-operations-sandbox"
}

# Create a VPC and subnets
resource "aws_vpc" "nip_io_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "nip-io-vpc"
  }
}

resource "aws_ecr_repository" "main" {
  name                 = "nio_io"
  image_tag_mutability = "MUTABLE"
}

resource "aws_subnet" "nip_io_subnet_a" {
  vpc_id     = aws_vpc.nip_io_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "nip-io-subnet-a"
  }
}

resource "aws_subnet" "nip_io_subnet_b" {
  vpc_id     = aws_vpc.nip_io_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "nip-io-subnet-b"
  }
}

resource "aws_internet_gateway" "nip_io_igw" {
  vpc_id = aws_vpc.nip_io_vpc.id

  tags = {
    Name = "nip-io-igw"
  }
}

resource "aws_internet_gateway_attachment" "nip_io_attachment" {
  count = 0
  vpc_id              = aws_vpc.nip_io_vpc.id
  internet_gateway_id = aws_internet_gateway.nip_io_igw.id
}

resource "aws_route_table" "nip_io_public_route_table" {
  vpc_id = aws_vpc.nip_io_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nip_io_igw.id
  }

  tags = {
    Name = "nip-io-public-route-table"
  }
}

resource "aws_route_table_association" "nip_io_association" {
  subnet_id      = aws_subnet.nip_io_subnet_a.id
  route_table_id = aws_route_table.nip_io_public_route_table.id
}

# Create a security group for the ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb_sg"
  vpc_id = aws_vpc.nip_io_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the application load balancer
resource "aws_lb" "nip_io_alb" {
  name               = "nip-io-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.nip_io_subnet_a.id, aws_subnet.nip_io_subnet_b.id]

  tags = {
    Name = "nip-io-alb"
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "nip_io_tg" {
  name     = "nip-io-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nip_io_vpc.id

  health_check {
    path = "/"
    interval = 30
    timeout = 5
  }
}

# Create an IAM role for the ECS task
resource "aws_iam_role" "nip_io_task_role" {
  name = "nip-io-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Create an IAM policy for the ECS task
resource "aws_iam_policy" "nip_io_task_policy" {
  name = "nip-io-task-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "awslogs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ]
  })
}

resource "aws_iam_role" "nip_io_task_execution_role" {
  name = "nip-io-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the policy to the task execution role
resource "aws_iam_role_policy_attachment" "nip_io_task_policy_attachment" {
  policy_arn = aws_iam_policy.nip_io_task_policy.arn
  role       = aws_iam_role.nip_io_task_execution_role.name
}

# Create the ECS cluster
resource "aws_ecs_cluster" "nip_io_cluster" {
  name = "nip-io-cluster"
}

# Create a task definition for the ECS task
resource "aws_ecs_task_definition" "nip_io_task_definition" {
  family                   = "nip-io-task"
  container_definitions    = jsonencode([
    {
      name            = "my-container"
      image           = "nginx:latest"
      portMappings    = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  cpu             = 256
  memory          = 1024

  requires_compatibilities = [
    "FARGATE"
  ]

  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.nip_io_task_execution_role.arn
}

# Create an ECS service
resource "aws_ecs_service" "nip_io_service" {
  name            = "nip-io-service"
  cluster         = aws_ecs_cluster.nip_io_cluster.arn
  task_definition = aws_ecs_task_definition.nip_io_task_definition.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups = [aws_security_group.nip_io_sg.id]
    subnets         = aws_subnet.nip_io_subnet_a.*.id
  }
}

# Create a security group for the task
resource "aws_security_group" "nip_io_sg" {
  name_prefix = "nip-io-sg"
  vpc_id = aws_vpc.nip_io_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.nip_io_vpc.id

  tags = {
    Name = "public"
  }
}
