variable "app_name" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "subnet_id" {}
variable "user_name" {}
variable "security_group_id" {}
variable "s3_bucket_name" {}
variable "sqs_queue_name" {}
