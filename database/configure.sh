#!/bin/bash

set -e

boundary connect postgres \
    --dbname=products \
    -target-id $(cd boundary && terraform output -raw boundary_target_postgres) -- -f database/products.sql