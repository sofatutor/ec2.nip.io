variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
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

