variable "resource_group_name" {
  description = "The name of the resource group in which the container apps should be created."
  
}

variable "location" {
  description = "The location of the resource group in which the container apps should be created." 
  
}

variable "name" {
    description = "The name of the container apps."
  
}

variable "log_analytics_workspace_id" {
    description = "The ID of the Log Analytics workspace."
    type = string
    default = null
}

variable "storage" {
    description = "The storage configuration for the container apps."
    type = object({
        account_name = string
        account_resource_group_name = string
        share_name = list(string)
    })
}