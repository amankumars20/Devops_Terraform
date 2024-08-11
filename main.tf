# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project VPC"
  }
}

# Create a public subnet

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "Public Subnet"
  }
}

# Create a private subnet

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "Public Subnet 2"
  }
}

# Create an internet gateway

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Create a public route table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}


# Associate the public route table with the public subnet

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate the public route table with the private subnet

resource "aws_route_table_association" "public_rt_a2" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public_rt.id
}


#Create a security group for the instances

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow all traffic from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
}



# Generate a private key for the frontend instance

resource "tls_private_key" "for_frontend" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key pair for the frontend instance

resource "aws_key_pair" "for_frontend" {
  key_name   = "for-frontend-instance"
  public_key = tls_private_key.for_frontend.public_key_openssh
}

# Save the private key to a file

resource "local_file" "frontend_private_key" {
  content         = tls_private_key.for_frontend.private_key_pem
  filename        = "~/.ssh/for-frontend-instance.pem"
  file_permission = "0600"
}

# Generate a private key for the backend instance

resource "tls_private_key" "for_backend" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key pair for the backend instance

resource "aws_key_pair" "for_backend" {
  key_name   = "for-backend-instance"
  public_key = tls_private_key.for_backend.public_key_openssh

}

# Save the private key to a file

resource "local_file" "backend_private_key" {
  content         = tls_private_key.for_backend.private_key_pem
  filename        = "~/.ssh/for-backend-instance.pem"
  file_permission = "0600"
}

# Launch an instance in the public subnet

resource "aws_instance" "frontend" {
  ami           = "ami-07a0715df72e58928"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name      = aws_key_pair.for_frontend.key_name
  tags = {
    Name = "FRONTEND"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.for_frontend.private_key_pem
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/home/ubuntu/frontend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/frontend.sh"
    ]
  }

}
# Launch an instance in the private

resource "aws_instance" "backend" {
  ami           = "ami-07a0715df72e58928"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.example.id]
  key_name      = aws_key_pair.for_backend.key_name
tags = {
    Name = "BACKEND"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.for_backend.private_key_pem
  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/home/ubuntu/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/backend.sh"
    ]
  }
}
