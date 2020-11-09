project = "coffee"

app "database" {
  url {
    auto_hostname = false
  }

  labels = {
    "service" = "database"
  }

  build {
    use "docker-pull" {
      image              = "hashicorpdemoapp/product-api-db"
      tag                = "v0.0.11"
      disable_entrypoint = true
    }
  }

  deploy {
    use "kubernetes" {
      service_account = "database"
      service_port    = 5432
      replicas        = 1
      annotations = {
        "consul.hashicorp.com/connect-inject"  = "true"
        "consul.hashicorp.com/connect-service" = "database"
      }
      static_environment = {
        POSTGRES_DB       = "products"
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "password"
      }
    }
  }

  release {
    use "kubernetes" {
      load_balancer = true
      port          = 5432
    }
  }
}

app "products" {
  url {
    auto_hostname = false
  }

  labels = {
    "service" = "products"
  }

  build {
    use "docker-pull" {
      image              = "hashicorpdemoapp/product-api"
      tag                = "v0.0.11"
      disable_entrypoint = true
    }
  }

  deploy {

    hook {
      when    = "before"
      command = ["./kubernetes/products.sh"]
    }

    use "kubernetes" {
      service_port = 9090
      replicas     = 2
      static_environment = {
        CONFIG_FILE = "/vault/secrets/config"
      }
      service_account = "products"
      probe_path      = "/health"
      annotations = {
        "consul.hashicorp.com/connect-inject"              = "true"
        "consul.hashicorp.com/connect-service"             = "products"
        "consul.hashicorp.com/connect-service-upstreams"   = "database:5432"
        "vault.hashicorp.com/agent-inject"                 = "true"
        "vault.hashicorp.com/role"                         = "products"
        "vault.hashicorp.com/namespace"                    = "admin"
        "vault.hashicorp.com/agent-inject-secret-config"   = "database/creds/products"
        "vault.hashicorp.com/agent-inject-template-config" = <<EOF
{
"bind_address": ":9090",
{{ with secret "database/creds/products" -}}
"db_connection": "host=localhost port=5432 user={{ .Data.username }} password={{ .Data.password }} dbname=products sslmode=disable"
{{- end }}
}
EOF
      }
    }
  }

  release {
    use "kubernetes" {
      load_balancer = false
      port          = 9090
    }
  }
}

app "public" {
  url {
    auto_hostname = false
  }

  labels = {
    "service" = "public"
  }

  build {
    use "docker-pull" {
      image              = "hashicorpdemoapp/public-api"
      tag                = "v0.0.2"
      disable_entrypoint = true
    }
  }

  deploy {
    use "kubernetes" {
      service_port = 8080
      replicas     = 1
      static_environment = {
        BIND_ADDRESS     = ":8080"
        PRODUCTS_API_URI = "http://localhost:9090"
      }
      service_account = "public"
      annotations = {
        "consul.hashicorp.com/connect-inject"            = "true"
        "consul.hashicorp.com/connect-service"           = "public"
        "consul.hashicorp.com/connect-service-upstreams" = "products:9090"
      }
    }
  }

  release {
    use "kubernetes" {
      load_balancer = false
      port = 8080
    }
  }
}

app "frontend" {
  labels = {
    "service" = "frontend"
  }

  build {
    use "docker" {
      dockerfile = "frontend"
    }
    registry {
      use "aws-ecr" {
        region     = "us-west-2"
        repository = "frontend"
        tag        = "latest"
      }
    }
  }

  deploy {
    use "kubernetes" {
      service_port    = 80
      replicas        = 1
      service_account = "frontend"
      annotations = {
        "consul.hashicorp.com/connect-inject"            = "true"
        "consul.hashicorp.com/connect-service"           = "frontend"
        "consul.hashicorp.com/connect-service-upstreams" = "public:8080"
      }
    }
  }

  release {
    use "kubernetes" {
      load_balancer = true
      port          = 80
    }
  }
}
