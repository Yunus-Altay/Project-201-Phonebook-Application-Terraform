variable "vpc_id" {
  default = "vpc-01243ded86dda1fa1"
}

variable "tag_name" {
  default = "phonebook-app"
}

variable "key_name" {
  default = "first-key-pair"
}

variable "subnet_id_list" {
  type = list(string)
  default = [
    "subnet-02a52ed17fe9248ba",
    "subnet-051f333f8553fa026",
    "subnet-06af6baedc3edab6b",
    "subnet-0828df16f6a1b8b78",
    "subnet-0aeb3fbafa45b6da4",
    "subnet-0b13c61efae4235b5"
  ]
}

variable "db_name" {
  default = "phonebook"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "admin1234"
}