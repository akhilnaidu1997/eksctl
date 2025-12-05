data "aws_ami" "data_source" {
  most_recent = true
  owners      = ["973714476881"]
  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}