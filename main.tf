terraform {
  backend "s3" {}

  required_providers {
    heroku = {
      source  = "registry.terraform.io/heroku/heroku"
      version = "~> 5.0.2"
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.2.0"
    }
  }
}

resource "random_pet" "app_name" {}

resource "heroku_app" "app" {
  name   = random_pet.app_name.id
  region = "eu"

  sensitive_config_vars = var.dream_env
  buildpacks            = ["heroku/go"]
}

resource "heroku_build" "app" {
  app_id = heroku_app.app.id

  source {
    # A local directory, changing its contents will
    # force a new build during `terraform apply`
    path = var.dream_project_dir
  }
}

# Launch the app's web process by scaling-up
resource "heroku_formation" "app" {
  app_id     = heroku_app.app.id
  type       = "web"
  quantity   = 1
  size       = "free"
  depends_on = [heroku_build.app]
}

output "APP_URL" {
  value = "https://${heroku_app.app.name}.herokuapp.com"
}