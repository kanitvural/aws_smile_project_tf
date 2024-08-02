resource "aws_s3_bucket" "main" {
  bucket = "kntbucketlondon"  # Ya da istediğiniz bir isim verin

  tags = {
    Name = "kntbucketlondon"
  }
}
