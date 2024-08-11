output "frontend_instance_id" {
  value       = aws_instance.frontend.id
  description = "The ID of the frontend instance"
}

output "frontend_instance_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "The public IP address of the frontend instance"
}

output "backend_instance_id" {
  value       = aws_instance.backend.id
  description = "The ID of the backend instance"
}

output "backend_instance_public_ip" {
  value       = aws_instance.backend.public_ip
  description = "The public IP address of the backend instance"
}

output "security_group_id" {
  value       = aws_security_group.example.id
  description = "The ID of the security group"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "The ID of the public subnet"
}

output "public_subnet2_id" {
  value       = aws_subnet.private.id
  description = "The ID of the private subnet"
}