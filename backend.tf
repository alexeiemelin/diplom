terraform {
  backend "remote" {
    organization = "diplom"

    workspaces {
      name = "diplom"
    }
  }
}