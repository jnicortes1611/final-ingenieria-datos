variable "region" {
  description = "Region AWS del ejercicio"
  type        = string
  default     = "us-east-2"
}

variable "nombre_bucket" {
  description = "Nombre globalmente unico, con prefijo final-ingdatos-"
  type        = string

  validation {
    condition     = startswith(var.nombre_bucket, "final-ingdatos-")
    error_message = "El bucket debe comenzar con final-ingdatos-."
  }
}
