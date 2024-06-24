resource "tfe_registry_module" "github_java" {
  organization = tfe_organization.demo.name

  vcs_repo {
    display_identifier         = "${var.github_user}/terraform-github-java"
    identifier                 = "${var.github_user}/terraform-github-java"
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
    branch                     = "main"
  }
}

resource "tfe_no_code_module" "github_java_nocode" {
  organization    = tfe_organization.demo.id
  registry_module = tfe_registry_module.github_java.id
}

resource "tfe_registry_module" "aws_postgres" {
  organization = tfe_organization.demo.name

  vcs_repo {
    display_identifier         = "${var.github_user}/terraform-aws-postgres-waypoint"
    identifier                 = "${var.github_user}/terraform-aws-postgres-waypoint"
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
    branch                     = "main"
  }
}

resource "tfe_no_code_module" "aws_postgres_nocode" {
  organization    = tfe_organization.demo.id
  registry_module = tfe_registry_module.aws_postgres.id
}