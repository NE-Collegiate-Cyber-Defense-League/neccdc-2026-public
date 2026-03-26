resource "aws_eip" "red_team" {
  domain   = "vpc"
  instance = aws_instance.red_team.id

  tags = {
    Name = "red-team"
  }
}


resource "aws_route53_record" "red_team_A" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "red.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.red_team.private_ip]
}


resource "aws_key_pair" "red_team" {
  key_name   = "red-team"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIxDIp+ISuWQB3PolzU9StBhNFeZuX4oOV4h6jLjPSifbsml5ZJ8u1BuGCkeMDYoKfeuiMg82UB5pUWgTNB8+0JTvLbJXScnUabqD6lsq3MsaBqbPXDDnSn4qH/9pVktuccNu6+CW5rt3FTIXqT0GFTfzVzGfslOT3eP4e4J2ctzo2RFC2+O5rNAGywCyMaWJ+Z2zghqTsIgpV7Y71sWa4eo7qL/HOfhPUkQBIXuwH5WfouKEDYaYHjmlR4y6OLqBjHgzzGjHVd/spFoPsMP0O8DXERfglTPnQKfUNX10gvW8LiFiMBOV/Y0GR6t0hx58n7JJq0LMu0njd3OpIS2r1 red-team@neccdl.org"
}


resource "aws_instance" "red_team" {
  ami           = data.aws_ami.ec2.id
  instance_type = "t3a.small"

  iam_instance_profile = aws_iam_instance_profile.ssm.id

  subnet_id                   = aws_subnet.public_vpn.id
  vpc_security_group_ids      = [aws_security_group.red_team.id]
  associate_public_ip_address = true
  private_ip                  = "10.0.254.201"

  ipv6_addresses = [
    cidrhost(local.vpn_cidr_range, 1229782938247303442) # "2600:1f26:1d:8000:1111:1111:1111:1112"
  ]

  key_name = aws_key_pair.red_team.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 32
  }

  tags = {
    Name = "red-team"
  }
}


resource "aws_security_group" "red_team" {
  name        = "red_team"
  description = "Allow traffic in and out of red-team jumpbox"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "red team ssh"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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
    Name = "red-team"
  }
}
