variable "vpc_cidr" {
  type = string
  default = "12.0.0.0/16"
}

variable "public_subnet_1" {
  type = string
  default = "12.0.1.0/24"
}

variable "public_subnet_2" {
  type = string
  default = "12.0.2.0/24"
}

variable "ami_id" {
  type = string
  default = "ami-02dfbd4ff395f2a1b"
}