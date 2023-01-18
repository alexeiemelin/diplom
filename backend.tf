terraform {
  backend "remote" {
    organization = "alexei-emelin"

    workspaces {
      name = "prod"
    }
    workspaces {
      name = "stage"
    }
  }
}