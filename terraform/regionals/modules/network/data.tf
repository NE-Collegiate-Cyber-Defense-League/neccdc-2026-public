data "aws_internet_gateway" "this" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
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
