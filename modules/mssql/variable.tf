variable "resource_group_name" {
  description = "The name of the resource group in which to create the SQL Server."
  type        = string
}

variable "location" {
  description = "The Azure Region where the SQL Server should exist."
  type        = string
}

variable "server_name" {
  description = "value for the SQL Server name. Must be globally unique."
  type        = string
}

variable "database_names" {
  description = "A list of database names to create on the SQL Server."
  type        = list(string)
  default     = []
}