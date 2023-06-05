# Argo Rollout Deployment Strategies

## Perquisites

- [Docker]()
- [kind (Kubernetes in Docker)]()
- [helm]()
- [make]()
- [kubectl]()
- [kubectl argo plugin]()

## Steps

```sh
make setup
```

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

## Rollouts

### Dark launch (Zero Traffic)

```yaml
  steps:
    # 1 Pod Zero traffic
    - setCanaryScale:
        replicas: 1

    # Pause Indefinitely
    - pause: {}

    # 60% traffic
    - setCanaryScale:
        weight: 60
        matchTrafficWeight: true

    # Pause Indefinitely
    - pause: {}

    # Full release
    - setWeight: 100
```

### Dark Launch (Smoke Test)

```yaml
 steps:
    # 1 Pod Zero traffic
    - setCanaryScale:
        replicas: 1

    # Pause Indefinitely
    - pause: {}

    # Run analysis
    - analysis:
        templates:
          - templateName: smoke-test
        args:
          - name: url
            value: canary-preview.default.svc.cluster.local

    # 60% traffic
    - setCanaryScale:
        weight: 60
        matchTrafficWeight: true

    # Pause Indefinitely
    - pause: {}

    # Full release
    - setWeight: 100
```

### Auto Rollback Analysis

```yaml
  steps:
      # 1 Pod Zero traffic
      - setWeight: 60

      # Run analysis that will always fail
      - analysis:
          templates:
            - templateName: always-pass

      # Pause Indefinitely
      - pause: {}

      # Run analysis that will always fail
      - analysis:
          templates:
            - templateName: always-pass
            - templateName: always-fail

      # Full release
      - setWeight: 100
```
