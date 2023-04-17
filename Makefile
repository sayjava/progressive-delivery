
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

install_cd:
	@kubectl create namespace argocd
	@kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

.PHONY: install_cd

deploy_app:
	@kubectl apply -f deploy
	@kubectl apply -f analysis

.PHONY: deploy_app

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

show_cd:
	@kubectl port-forward svc/argocd-server -n argocd 9090:443
.PHONY: show_cd

show_gitea:
	@kubectl port-forward svc/gitea-http 3000:3000
.PHONY: show_gitea

generate_traffic:
	@bash traffic.sh
.PHONY: generate_traffic

create_canary_app:
	argocd app create canary \
	--repo http://gitea-http.default.svc.cluster.local:3000/ray/progressive \
	--path deployments/canary \
	--dest-server https://kubernetes.default.svc \
	--dest-namespace default
.PHONY: create_canary_app

create_traffic_app:
	argocd app create traffic \
	--repo http://gitea-http.default.svc.cluster.local:3000/ray/progressive \
	--path deployments/traffic \
	--dest-server https://kubernetes.default.svc \
	--dest-namespace default
.PHONY: create_traffic_app

create_gb_app:
	argocd app create blue-green \
	--repo http://gitea-http.default.svc.cluster.local:3000/ray/progressive \
	--path deployments/traffic \
	--dest-server https://kubernetes.default.svc \
	--dest-namespace default
.PHONY: create_bg_app

# aMAKb7E4WfH230J3