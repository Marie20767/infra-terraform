output "instance_id" {
  value = aws_instance.node_app.id
}

output "public_ip" {
  value = aws_instance.node_app.public_ip
}