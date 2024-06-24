resource "hcp_waypoint_application_template" "github_java" {
  name    = "spring-postgresql"
  summary = "Spring Boot application with PostgreSQL"
  terraform_cloud_workspace_details = {
    name                 = "application"
    terraform_project_id = var.waypoint_terraform_project_id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-stack-demoapp/java/github"
    version = "0.0.0"
  }
}