# Provider設定
provider "aws" {
  region = "ap-northeast-1"
}

variable "app_name" {
  type = string
  default = "sample"
}

variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

module "network" {
  source   = "./network"
  app_name = var.app_name
  azs      = var.azs
}

module "iam" {
  source = "./iam"
}