# https://aws.amazon.com/blogs/compute/secure-connectivity-from-public-to-private-introducing-ec2-instance-connect-endpoint-june-13-2023/
resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id = aws_subnet.public_vpn.id

  ip_address_type    = "dualstack"
  preserve_client_ip = false

  security_group_ids = [
    aws_security_group.instance_connect_endpoint.id
  ]

  tags = {
    Name = "ec2-instance-endpoint"
    team = "shared"
  }
}

resource "aws_security_group" "instance_connect_endpoint" {
  name        = "ec2-instance-endpoint"
  description = "Allow all servers to connect to EC2 instance endpoint"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow ssh in"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    description = "Allow ssh out"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  tags = {
    Name = "ec2-instance-endpoint"
    team = "shared"
  }
}
