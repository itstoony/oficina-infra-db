output "db_endpoint" {
  description = "Endpoint do RDS (host:porta)"
  value       = aws_db_instance.oficina.endpoint
}

output "db_host" {
  description = "Host do RDS (sem porta)"
  value       = aws_db_instance.oficina.address
}

output "db_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.oficina.port
}

output "db_name" {
  description = "Nome do banco"
  value       = aws_db_instance.oficina.db_name
}
