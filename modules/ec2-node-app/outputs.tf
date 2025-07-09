output "ec2_instance_id" {
  value = aws_instance.node_app.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}

output "access_key" {
  value = aws_iam_access_key.access_key.id
  sensitive = true
}

output "secret_access_key" {
  value = aws_iam_access_key.access_key.secret
  sensitive = true
}