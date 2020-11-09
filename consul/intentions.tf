resource "consul_intention" "products_to_database" {
  source_name      = "products"
  destination_name = "database"
  action           = "allow"
}

resource "consul_intention" "public_to_products" {
  source_name      = "public"
  destination_name = "products"
  action           = "allow"
}

resource "consul_intention" "frontend_to_public" {
  source_name      = "frontend"
  destination_name = "public"
  action           = "allow"
}