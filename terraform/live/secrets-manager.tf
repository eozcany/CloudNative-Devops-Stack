# Store passwords in AWS Secrets Manager
resource "aws_secretsmanager_secret" "reversed_ip_sercrets" {
  name        = "reversed-ip"
  description = "Reversed IP App Secrets"
}

resource "aws_secretsmanager_secret_version" "reversed_ip_sercrets" {
  secret_id = aws_secretsmanager_secret.reversed_ip_sercrets.id
  secret_string = jsonencode({
    DB_HOST = "${helm_release.mysql.metadata.0.name}.${helm_release.mysql.metadata.0.namespace}.svc.cluster.local",
    DB_PASSWORD = random_password.mysql_user_password.result
    DB_NAME = var.reversed_ip_db
    DB_USER = var.reversed_ip_user
  })
}