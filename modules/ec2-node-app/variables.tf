variable "app_name" {}
variable "ami_id" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "subnet_id" {}
variable "security_group_id" {}
variable "user_data" {}
