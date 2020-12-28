# Create a AWS S3 bucket that is encrypted by default
# at the server side using the name provided by the
# `bucket` variable.
resource "aws_s3_bucket" "encrypted" {
  for_each      = toset(var.infra_s3bucket)
  bucket        = each.value
  acl           = "private"
  force_destroy = "true"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
  id      = "backups"
  enabled = true
  prefix = "backups/"


  expiration {
           days = 30
             }

}

}

resource "aws_s3_bucket_public_access_block" "encrypted_public_access_block" {
  count  = length(local.encrypted_infra_s3buckets)
  bucket    = local.encrypted_infra_s3buckets[count.index]

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}



# Set up the bucket policy to allow only a 
# specific set of operations on both the root
# of the bucket as well as its subdirectories.
locals {
    
    encrypted_infra_s3buckets = [for bucket in aws_s3_bucket.encrypted: bucket["id"]]
    encrypted_infra_s3buckets_arn = [for bucket in aws_s3_bucket.encrypted: bucket["arn"]]

}

resource "aws_s3_bucket_policy" "main" {
  count     = length(local.encrypted_infra_s3buckets)
  bucket    = local.encrypted_infra_s3buckets[count.index]
  policy    = templatefile("${path.module}/template/infra_policy_s3_bucket.json.tmpl", {
  bucket   = local.encrypted_infra_s3buckets_arn[count.index]
})
}

