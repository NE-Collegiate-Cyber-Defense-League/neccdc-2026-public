resource "aws_eip" "wireguard" {
  domain   = "vpc"
  instance = aws_instance.wireguard.id

  tags = {
    Name = "wireguard"
  }
}


resource "aws_route53_record" "vpn_ipv4" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "vpn.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.wireguard.public_ip]
}

resource "aws_route53_record" "vpn_ipv6" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "vpn.${data.aws_route53_zone.public.name}"
  type    = "AAAA"
  ttl     = "300"
  records = [aws_instance.wireguard.ipv6_addresses[0]]
}


resource "aws_instance" "wireguard" {
  ami           = data.aws_ami.ec2.id
  instance_type = "t4g.medium"

  iam_instance_profile = aws_iam_instance_profile.ssm.id

  subnet_id                   = aws_subnet.public_vpn.id
  vpc_security_group_ids      = [aws_security_group.wireguard.id]
  associate_public_ip_address = true
  private_ip                  = cidrhost(local.vpn_ipv4_cidr_range, 100) # 10.255.254.100

  ipv6_addresses = [
    cidrhost(local.vpn_ipv6_cidr_range, -2) # "2600:1f26:1d:8000:ffff:ffff:ffff:fffe"
  ]

  key_name = aws_key_pair.black_team.id

  tags = {
    Name = "wireguard"
  }
}


resource "aws_security_group" "wireguard" {
  name        = "wireguard"
  description = "Allow traffic in and out of wireguard"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "BlackTeam Wireguard UDP"
    from_port        = 51899
    to_port          = 51899
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "BlackTeam Wireguard TCP"
    from_port        = 51999
    to_port          = 51999
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH into wireguard"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Only required for initial creation
  ingress {
    description      = "Team Wireguard Web TCP"
    from_port        = 51800
    to_port          = 52000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Team Wireguard UDP"
    from_port        = 51800
    to_port          = 52000
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wireguard"
  }
}
