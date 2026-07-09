#!/usr/bin/env bash

set -e

NAMESPACE="argocd"
SERVICE="argocd-server"
LOCAL_PORT=8080
REMOTE_PORT=443

echo "Waiting for Argo CD server to become available..."

kubectl wait \
  --namespace "${NAMESPACE}" \
  --for=condition=Available \
  deployment/${SERVICE} \
  --timeout=300s

echo "Getting admin password..."

PASSWORD=$(kubectl \
  -n "${NAMESPACE}" \
  get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode)

echo ""
echo "========================================="
echo " Argo CD is ready!"
echo "========================================="
echo "URL      : https://localhost:${LOCAL_PORT}"
echo "Username : admin"
echo "Password : ${PASSWORD}"
echo "========================================="
echo ""
echo "Starting port-forward..."
echo "Press Ctrl+C when you're done."
echo ""

kubectl port-forward \
  -n "${NAMESPACE}" \
  svc/${SERVICE} \
  ${LOCAL_PORT}:${REMOTE_PORT}