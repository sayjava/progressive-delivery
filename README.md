# Argo Rollout Deployment Strategies 

## Perquisites
- [Docker]()
- [kind (Kubernetes in Docker)]()
- [helm]()
- [make]()
- [kubectl]()
- [kubectl argo plugin]()

## Setup

- [ ] Ingress controller
- [ ] Argo Rollout
- [ ] Prometheus
- [ ] Grafana

## Steps
- create cluster with `kind create cluster --config configs/kind.yml`
- create namespaces: `make setup` 
- build and load apps: `make build_and_load_apps`
- install grafana: `make install_grafana`
- install prometheus: `make install_prometheus`
- install ingress: `make install_ingress`
- install argo rollout `make install_argo_rollout`


## Setup monitoring
- run `make show_grafana`
- login for the first time with `admin` and `admin` for username and password.
- add prometheus as a datasource from the `Admin` panel
  - Select prometheus
  - Use `http://prometheus-server.monitoring.svc` as the prometheus url
  - Install the application dashboard using the supplied application dashboard
  - Install the nginx dashboard from the dashboard folder

## Deploy Applications

- Test app `http://prod.local:8080` 
- Generate traffic `make generate_traffic`

## Canary Deployment
- 