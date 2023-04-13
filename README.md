## Setup

- [ ] Ingress controller
- [ ] ArgoCD
- [ ] Argo Rollout
- [ ] Gitea
- [ ] Hostnames
- [ ] Prometheus
- [ ] Graphana

## Dashboard

https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

## K8s

https://howchoo.com/kubernetes/read-kubernetes-secrets

kubectl -n argocd get secret argocd-initial-admin-secret -o yaml

## Argo Rollout

```bash
kubectl create namespace argo-rollouts 

kubectl apply -n argo-rollouts -f
https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

kubectl argo rollouts dashboard
```

## Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Examples

https://github.com/argoproj/argo-rollouts/tree/master/examples

## Install Expose ingress controller

https://kubernetes.github.io/ingress-nginx/deploy/#local-testing

```bash
helm upgrade --install ingress-nginx ingress-nginx\
--repo https://kubernetes.github.io/ingress-nginx\
--namespace ingress-nginx --create-namespace
```

```bash
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

```bash
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

## GITEA

```bash
helm repo add gitea-charts https://dl.gitea.io/charts/ helm install gitea
gitea-charts/gitea
```

```bash
kubectl --namespace default port-forward svc/gitea-http 3000:3000
```

## ISTIO Canary

https://github.com/etiennetremel/istio-cross-namespace-canary-release-demo
