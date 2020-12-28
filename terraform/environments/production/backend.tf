#backend make sure to change bucket name
terraform {
  backend "s3" {
    bucket = "terraform-csr-backend"
    key    = "production/terraform_prod.tfstate"
    region = "ap-south-1"
  }
}
