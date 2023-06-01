
# http://prometheus-server.monitoring.svc.cluster.local
# http://grafana.monitoring.svc.cluster.local
# prometheus-prometheus-pushgateway.monitoring.svc.cluster.local

build_and_load_apps:
	@docker build --build-arg version='v1' -t app:v1 app
	@docker build --build-arg version='v2' -t app:v2 app
	@docker build --build-arg version='v3' -t app:v3 app
	@docker build --build-arg version='v4' -t app:v4 app
	@docker build --build-arg version='slow' -t app:slow app
	@docker build --build-arg version='error' -t app:error app
	@docker build --build-arg version='quit' -t app:quit app

	@kind load docker-image   app:v1 app:v2 app:v3 app:v4 app:slow app:error app:quit

.PHONY: build_and_load_apps

install_monitoring:
	@kubectl create namespace monitoring
	@helm repo add grafana https://grafana.github.io/helm-charts
	@helm install grafana \
		--namespace=monitoring \
		--set=adminUser=admin \
		--set=adminPassword=admin \
		--set=service.type=NodePort \
    	grafana/grafana

	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	@helm install prometheus prometheus-community/prometheus --create-namespace --namespace=monitoring
.PHONY: install_monitoring

install_ingress:
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	@helm repo update
	@helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx --create-namespace

	@helm upgrade ingress-nginx ingress-nginx \
		--repo https://kubernetes.github.io/ingress-nginx \
		--namespace ingress-nginx \
		--set controller.metrics.enabled=true \
		--set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
		--set-string controller.podAnnotations."prometheus\.io/port"="10254"
.PHONY: install_ingress

install_argo_rollout:
	@kubectl create namespace argo-rollouts
	@kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
.PHONY: install_argo_rollout

setup_cluster:
	@kind create cluster --config configs/kind.yml
.PHONY: setup_cluster

setup: setup_cluster build_and_load_apps install_monitoring install_ingress install_argo_rollout
	@kubectl apply -f deployments/canary/deployment.yml
.PHONY: setup

tear_down:
	@kind delete cluster
.PHONY: tear_down

deploy_analysis:
	@kubectl apply -f analysis
.PHONY: deploy_analysis

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

wrk_traffic:
	wrk -t1 -c1 -d2h http://prod.local:8080
.PHONY: wrk_traffic

canary_deployment:
	@kubectl apply -f deployments/canary/rollout.yml
.PHONY: canary_deployment

canary_deploy_version:
	@kubectl argo rollouts set image canary-app canary-app=app:$(version)
.PHONY: canary_deploy_version

canary_watch:
	@kubectl argo rollouts get rollout canary-app -w
.PHONY: canary_watch

canary_status:
	@kubectl argo rollouts status canary-app
.PHONY: canary_status

canary_version:
	@kubectl argo rollouts version canary-app
.PHONY: canary_version

canary_promote:
	@kubectl argo rollouts promote canary-app
.PHONY: canary_promote

canary_rolloback:
	@kubectl argo rollouts undo canary-app
.PHONY: canary_rollback