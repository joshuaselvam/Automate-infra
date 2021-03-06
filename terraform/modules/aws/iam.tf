# Creates an IAM role with the trust policy that enables the process
# of fetching temporary credentials from STS.
#
# By tying this trust policy with access policies, the resulting 
# temporary credentials generated by STS have only the permissions 
# allowed by the access policies.
resource "aws_iam_role" "main" {
  name               = "default"
  assume_role_policy = data.aws_iam_policy_document.default.json
}

# Attaches an access policy to that role.
locals {
    s3_bucket_infra_access_policy = templatefile("${path.module}/template/infra_policy_iam_bucket.json.tmpl", {
    buckets = [for bucket in aws_s3_bucket.encrypted: bucket["arn"]]
  })
}

resource "aws_iam_role_policy" "bucket-root" {
  name   = "bucket-root-s3"
  role   = aws_iam_role.main.name
  policy = local.s3_bucket_infra_access_policy 
}



# Creates the instance profile that acts as a container for that
# role that we created that has the trust policy that is able
# to gather temporary credentials using STS and specifies the
# access policies to the bucket.
#
# This instance profile can then be provided to the aws_instance
# resource to have it at launch time.
resource "aws_iam_instance_profile" "instance-profile-docker-registry-s3" {
  name = "instance-profile-docker-registry-s3"
  role = aws_iam_role.main.name
}

#Add IAM USERS

resource "aws_iam_user" "iamusers" {
  count = length(var.iam_username)
  name = element(var.iam_username,count.index )
}

#NONPROD S3 IAM POLICY
locals {
    nonprod_policy_s3_bucket = templatefile("${path.module}/template/nonprod_policy_s3_bucket.json.tmpl", {
    buckets = aws_s3_bucket.nonprod_bucket.*.arn
  })
}
resource "aws_iam_policy" "nonprod_s3" {
 name = "nonprod_s3_access"
 policy = local.nonprod_policy_s3_bucket
}

resource "aws_iam_user_policy_attachment" "non-prod" {
 count = length(var.iam_username)
 user = element(aws_iam_user.iamusers.*.name,count.index )
 policy_arn = aws_iam_policy.nonprod_s3.arn
}
