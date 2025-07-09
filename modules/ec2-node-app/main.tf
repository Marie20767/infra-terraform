data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

########################
# Create IAM User
########################
resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

########################
# Create S3 Bucket
########################
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.s3_bucket_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

########################
# Create SQS Queue
########################
resource "aws_sqs_queue" "sqs_queue" {
  name = var.sqs_queue_name
}

########################
# Create EC2 Instance
########################
resource "aws_instance" "node_app" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]

  tags = {
    Name = var.app_name
  }
}

########################
# IAM Policy for EC2/SQS/S3 access
########################
resource "aws_iam_user_policy" "ec2_s3_sqs_policy" {
  name = "limited_ec2_s3_sqs_access"
  user = aws_iam_user.user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:TerminateInstances"
        ],
        Resource = aws_instance.node_app.arn
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.sqs_queue.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.s3_bucket.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

// TODO: delete ec2 instance, s3 bucket, sqs and user