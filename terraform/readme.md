## Check User before connection.

```bash
aws sts get-caller-identity
```
> Also check if the access tab in eks has this user added or not

## Update the kubeconfig.

```bash
aws eks update-kubeconfig --name staging-demo-eks --region us-east-1
```
## To tunnel to Cluster

```bash
kubectl port-forward -n "argocd" svc/argocd 8080:8080 >/dev/null 2>&1 &
```
## Check read write access and admin access.

```bash
kubectl auth can-i "*" "*" # r/w
kubectl get nodes # admin access
kubectl get pods -n kube-system # All pods running or not
```
