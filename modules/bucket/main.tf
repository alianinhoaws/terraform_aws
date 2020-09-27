resource "aws_s3_bucket" "log_bucket" {
  bucket = "terraform-log-alianinho"
  acl    = "log-delivery-write"
}
