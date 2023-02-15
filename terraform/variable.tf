variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}




variable "ecs_instance_type" {
  default = "t2.micro"
}

variable "app_port" {
  default = 80
}
variable "container_definitions" {
  type = list(object({
    name  = string
    image = string
    port_mappings = list(object({
      container_port = number
      host_port      = number
    }))
    environment = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

