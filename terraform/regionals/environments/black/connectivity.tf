resource "aws_key_pair" "black_team" {
  key_name   = "black-team"
  public_key = file("../../../../documents/black_team/id_rsa.pub")
}


resource "aws_iam_role" "ssm" {
  name        = "SessionManagerRole"
  description = "Allow the ability to SSM into the EC2 instance"
  path        = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachments_exclusive" "ssm" {
  role_name = aws_iam_role.ssm.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_instance_profile" "ssm" {
  name = "SessionManagerRole"
  role = aws_iam_role.ssm.name
}
