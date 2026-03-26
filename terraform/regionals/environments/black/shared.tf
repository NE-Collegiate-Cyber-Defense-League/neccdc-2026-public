resource "aws_security_group" "blue_team" {
  name        = "blue-team"
  description = "Allow access in and out for all blue team servers"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "Allow all in"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "blue-team"
    team = "shared"
  }
}
