terraform {
  backend "remote" {
    organization = "alexei_emelin"

    workspaces {
      name = "diplom"
    }
  }
}