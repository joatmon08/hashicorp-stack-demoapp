#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: products
automountServiceAccountToken: true
EOF