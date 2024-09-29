variable "environment" {
  type    = string
  default = "stage"
}

variable "vpc_environment_tag" {
  type    = string
  default = "stage"
}

variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "use_cloudflare_ip_whitelist" {
  type    = bool
  default = false
}

variable "availability_zones" {
  type    = list(string)
  default = ["ca-central-1a", "ca-central-1b", "ca-central-1d"]
}

variable "vpc_cidr" {
  type    = string
  default = "x.x.x.x/x"
}

variable "app_port" {
  type    = number
}

variable "ecs_task_cpu" {
  type    = number
  default = 512
}

variable "ecs_task_memory" {
  type    = number
  default = 1024
}

variable "ecs_desired_count" {
  type    = number
  default = 3
}

variable "log_group_retention" {
  type    = number
  default = 60
}

variable "use_cloudfront_alias" {
  type    = bool
  default = false
}

variable "cloudfront_alias" {
  type    = string
  default = ""
}

variable "cloudwatch_alarm_email_addresses" {
  type    = list(string)
}
