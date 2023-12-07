# Region
variable "region" {
  type    = list(string)
  default = ["sa-brazil-1", "la-south-2"]
}

# Authentication
variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

# availability zones
variable "availability_zones_sp" {
  type    = list(string)
  default = ["sa-brazil-1a", "sa-brazil-1b"]
}

variable "availability_zones_st" {
  type    = list(string)
  default = ["la-south-2a", "la-south-2b"]
}
variable "vpc_name_sp" {
  default = "huaweicloud_vpc_sp"
}

variable "vpc_cidr_sp" {
  default = "192.168.0.0/16"
}

variable "vpc_name_st" {
  default = "huaweicloud_vpc_st"
}

variable "vpc_cidr_st" {
  default = "172.16.0.0/16"
}

variable "subnet_cidr_st" {
  default = "172.16.1.0/24"
}

variable "subnet_gateway_st" {
  default = "172.16.1.1"
}

variable "subnet_cidr_sp" {
  default = "192.168.1.0/24"
}

variable "subnet_gateway_sp" {
  default = "192.168.1.1"
}

variable "default_password" {
  default = "Huawei@123"
}
