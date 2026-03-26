resource "aws_route53_record" "scorestack_A" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "score.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.scorestack.private_ip]
}


resource "aws_instance" "scorestack" {
  ami           = data.aws_ami.ec2_x86.id
  instance_type = "t3a.large"

  iam_instance_profile = aws_iam_instance_profile.ssm.id

  subnet_id                   = aws_subnet.public_vpn.id
  vpc_security_group_ids      = [aws_security_group.scorestack.id]
  associate_public_ip_address = true
  private_ip                  = "10.0.254.200"

  ipv6_addresses = [
    cidrhost(local.vpn_cidr_range, 1229782938247303441) # "2600:1f26:1d:8000:1111:1111:1111:1111"
  ]

  key_name = aws_key_pair.black_team.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 80
  }

  tags = {
    Name = "scorestack"
  }
}


resource "aws_security_group" "scorestack" {
  name        = "scorestack"
  description = "Allow traffic in and out of scorestack"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Black team ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Public https ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Public http ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "scorestack"
  }
}
