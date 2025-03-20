variable "resource_group_name" {
  description = "The name of the resource group in which to create the container instance."

}

variable "container_app_environment_id" {
  description = "The ID of the container app environment in which to create the container instance."

}

variable "name" {
  description = "The name of the container instance."
}


variable "registry_password" {
  description = "The password for the container registry."
  default     = null
}

variable "container" {
  description = "The container configuration for the container instance."
  type = object({
    name   = string
    image  = string
    cpu    = optional(number, 0.25)
    memory = optional(string, "0.5Gi")
    env    = map(string)
    volume = map(string)
  })
}

variable "ingress" {
  description = "The ingress configuration for the container instance."
  type = object({
    allow_insecure_connections = bool
    external_enabled           = bool
    target_port                = number
    exposed_port               = optional(number, null)
    transport                  = string
  })

}

variable "environment_storage_name" {
  description = "The name of the Azure file share to mount."

}

variable "volumes" {
  description = "The volumes to mount in the container instance."
  type = list(string)
  
}
