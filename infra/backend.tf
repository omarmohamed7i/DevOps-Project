terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket = "devops-candidate-1-omar-alaswar-terraform"
    prefix = "devops-test"
  }
}
