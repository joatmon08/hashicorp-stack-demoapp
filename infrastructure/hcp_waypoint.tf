resource "hcp_waypoint_application_template" "spring_postgres" {
  name    = "spring-postgresql"
  summary = "Spring Boot application with PostgreSQL driver"
  terraform_cloud_workspace_details = {
    name                 = "application"
    terraform_project_id = var.waypoint_terraform_project_id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-stack-demoapp/java/github"
    version = "0.0.0"
  }

  variable_options = [{
    name          = "business_unit"
    variable_type = "string"
    options       = [module.vpc.database_subnet_group_name]
  }]
}

resource "hcp_waypoint_add_on_definition" "aws_rds_postgresql" {
  name        = "aws-rds-postgresql"
  summary     = "AWS RDS managed instance with PostgreSQL"
  description = "Creates an AWS RDS instance with PostgreSQL"

  terraform_cloud_workspace_details = {
    name                 = "database"
    terraform_project_id = var.waypoint_terraform_project_id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-stack-demoapp/postgres-waypoint/aws"
    version = "0.0.0"
  }
}