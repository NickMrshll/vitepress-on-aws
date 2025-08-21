variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "bucket_prefix" {
  type    = string
  default = "vitepress-"
}

variable "domain_name" {
  type = string
}

#Set to @ for root domain
variable "vitepress_subdomain" {
  type = string
}
