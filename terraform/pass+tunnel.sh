#!/usr/bin/env bash

set -e

AWS_REGION="us-east-1"
CLUSTER_NAME="staging-demo-eks"
NAMESPACE="argocd"
SERVICE="argocd-server"
LOCAL_PORT=8080
REMOTE_PORT=443

ROOT_APP_FILE="../argoCD/app of apps/root-app.yaml" 

echo "Updating kubeconfig..."

aws eks update-kubeconfig \
  --region "${AWS_REGION}" \
  --name "${CLUSTER_NAME}"

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

echo "Applying Root Application..."

kubectl apply -f "${ROOT_APP_FILE}"

echo "Starting port-forward..."

kubectl port-forward \
  -n "${NAMESPACE}" \
  svc/${SERVICE} \
  ${LOCAL_PORT}:${REMOTE_PORT} >/dev/null 2>&1 &

PF_PID=$!

echo ""
echo "========================================="
echo " Argo CD is ready!"
echo "========================================="
echo "URL      : https://localhost:${LOCAL_PORT}"
echo "Username : admin"
echo "Password : ${PASSWORD}"
echo "========================================="
echo ""
echo "Port-forward running in background (PID: ${PF_PID})"
echo "To stop it:"
echo "kill ${PF_PID}"

wait ${PF_PID}