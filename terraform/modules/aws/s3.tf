resource "aws_s3_bucket" "nonprod_bucket" {
  count         = length(var.nonprod_s3bucket)
  bucket        = var.nonprod_s3bucket[count.index]
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count         = length(aws_s3_bucket.nonprod_bucket.*.bucket)
  bucket        = var.nonprod_s3bucket[count.index]
 
  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
