# RDS Subnet Group
resource "aws_db_subnet_group" "surveys_db_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-grp"
  subnet_ids = [aws_subnet.private_data_subnet_az1.id, aws_subnet.private_data_subnet_az2.id]
  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-grp"
  }
}

# Generate a random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS PostgreSQL instance
resource "aws_db_instance" "surveys_db" {
  identifier              = "${var.project_name}-${var.environment}-surveys-db"
  engine                  = "postgres"
  engine_version          = "17.4"
  instance_class          = "db.t3.small"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  db_name                 = "surveys"
  username                = var.db_username
  password                = random_password.db_password.result
  parameter_group_name    = "default.postgres17"
  db_subnet_group_name    = aws_db_subnet_group.surveys_db_subnet_group.name
  skip_final_snapshot     = true # use no in production environments
  vpc_security_group_ids  = [aws_security_group.surveys_db_sg.id]
  multi_az                = true
  backup_retention_period = 7
  storage_encrypted       = true

  # Reference to monitoring configuration defined in cloudwatch.tf
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  # Performance insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-surveys-db"
  }
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-${var.environment}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    host     = aws_db_instance.surveys_db.address
    user     = var.db_username
    password = random_password.db_password.result
    database = aws_db_instance.surveys_db.db_name
  })
}

