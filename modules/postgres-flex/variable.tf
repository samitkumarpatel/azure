variable "resource_group_name" {
    description = "The name of the resource group in which to create the PostgreSQL Flexible Server."
    type        = string
}

variable "location" {
    description = "The Azure location where the PostgreSQL Flexible Server will be created."
    type        = string
}
variable "server_name" {
    description = "The name of the PostgreSQL Flexible Server."
    type        = string
}

variable "database_names" {
    description = "A list of database names to create on the PostgreSQL Flexible Server."
    type        = list(string)
    default     = []
}