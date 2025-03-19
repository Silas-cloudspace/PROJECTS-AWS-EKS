# environment variables
region       = "eu-west-1"
project_name = "topsurvey"
environment  = "dev"

# vpc variables
vpc_cidr                    = "10.0.0.0/16"
public_subnet_az1_cidr      = "10.0.0.0/24"
public_subnet_az2_cidr      = "10.0.1.0/24"
private_app_subnet_az1_cidr = "10.0.2.0/24"
private_app_subnet_az2_cidr = "10.0.3.0/24"
data_subnet_az1_cidr        = "10.0.4.0/24"
data_subnet_az2_cidr        = "10.0.5.0/24"

# Database Variables
db_username = "admin1982"

# IAM variable
aws_user_name = "Silas_Teixeira"

# route53 variables
domain_name       = "cloudspace-consulting.com"
alternative_names = "*.cloudspace-consulting.com"
record_name       = "topsurvey"

# SNS variables
email = "silas.cloudspace@gmail.com"