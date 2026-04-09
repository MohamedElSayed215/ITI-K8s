#!/bin/bash
echo "Current Context (Cluster):"
kubectl config current-context
echo

echo "Current Namespace:"
kubectl config view --minify --output 'jsonpath={..namespace}'
echo -e "\n"

echo "Node Hostnames:"
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

echo
