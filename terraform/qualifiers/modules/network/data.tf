data "aws_route_table" "public" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Name"
    values = ["team-public"]
  }

  filter {
    name   = "tag:team"
    values = ["shared"]
  }

  filter {
    name   = "tag:network"
    values = ["public"]
  }
}

data "aws_route_table" "edge_associated" {
  vpc_id = var.vpc_id

  filter {
    name   = "tag:Name"
    values = ["edge-associated"]
  }

  filter {
    name   = "tag:team"
    values = ["shared"]
  }
}