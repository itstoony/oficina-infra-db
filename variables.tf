variable "region" {
  description = "Região AWS"
  type        = string
  default     = "sa-east-1"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_user" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "oficina"
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}
