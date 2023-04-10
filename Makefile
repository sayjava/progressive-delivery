
# prometheus-server.monitoring.svc.cluster.local
# grafana.monitoring.svc.cluster.local
# prometheus-prometheus-pushgateway.monitoring.svc.cluster.local

build_apps:
	@docker build --build-arg version='v1' -t app:v1 app
	@docker build --build-arg version='v2' -t app:v2 app
	@docker build --build-arg version='slow' -t app:slow app
	@docker build --build-arg version='error' -t app:error app
	@docker build --build-arg version='quit' -t app:quit app

.PHONY: build_apps

build_and_load_apps: build_apps
	@kind load docker-image   app:v1 app:v2 app:slow app:error app:quit

.PHONY: build_and_load_apps

install_grafana:
	@helm repo add grafana https://grafana.github.io/helm-charts

	@helm install grafana \
		--namespace=monitoring \
		--set=adminUser=admin \
		--set=adminPassword=admin \
		--set=service.type=NodePort \
    	grafana/grafana

.PHONY: install_grafana

install_prometheus:
	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

	@helm install prometheus prometheus-community/prometheus --create-namespace --namespace=monitoring

.PHONY: install_prometheus

install_metrics: install_prometheus install_grafana
	@helm upgrade ingress-nginx ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--namespace ingress-nginx \
		--set controller.metrics.enabled=true \
		--set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
		--set-string controller.podAnnotations."prometheus\.io/port"="10254"

.PHONY: install_metrics

install_rollout:
	@kubectl create namespace argo-rollouts
	@kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

.PHONY: install_rollout

show_prometheus:
	@kubectl port-forward --namespace=monitoring svc/prometheus-server  4000:80
.PHONY: show_prometheus

show_grafana:
	@kubectl port-forward --namespace=monitoring svc/grafana  5000:80
.PHONY: show_prometheus

show_apps:
	@kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
.PHONY: show_apps

show_rollout:
	@kubectl argo rollouts dashboard
.PHONY: show_rollout

generate_traffic:
	@bash traffic.sh
.PHONY: generate_traffic