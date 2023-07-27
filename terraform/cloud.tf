terraform {
  cloud {
    organization = "AlexZh"

    workspaces {
      name = "stage"
    }
  }
}