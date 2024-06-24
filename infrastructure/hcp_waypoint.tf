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