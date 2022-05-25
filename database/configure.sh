#!/bin/bash

set -e

export PGPASSWORD=$(cd infrastructure && terraform output -raw product_database_password)

boundary connect postgres \
    -username=$(cd infrastructure && terraform output -raw product_database_username) -dbname=products \
    -target-id $(cd boundary && terraform output -raw boundary_target_postgres) -- -f database/products.sql