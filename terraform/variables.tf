variable "environment" {
  description = "De omgeving waarin Terraform wordt uitgevoerd (bijv. 'dev' of 'prod')."
  type        = string
}

variable "project_id" {
  description = "Het Google Cloud Project waarin de resources worden aangemaakt."
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "password"
}

variable "db_user" {
  description = "The name of the user for the database"
  type        = string
  default     = "postgres"
}

variable "subnet_ip_range" {
  description = "IP range for the new subnet"
  type        = string
  default     = "10.10.0.0/16" # Specified IP range for the subnet
}