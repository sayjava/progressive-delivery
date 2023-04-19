# Slide 0: Objectives


# Slide 1: Current State of Affairs
- Discuss current setup
  - Apps running in none production environment means we don't know how they will behave (There are differences between prod and non-prod or non-production receiving cluster)
  - We are exposed to the current state of apps as our customer at the same time.
  - Rollback not instantaneous
  - Customer impact is quite high 

# Slide 2: Discuss concepts
- Deployment: an app running in production cluster
- Release: The version of the app accessible to customers
- Analysis: arbitrary job we can run on a Release or Deployment
- Promotion: Take a deployment to release
- Grace Period: Time when a new Release is going through assessment 
- Rollback: Reverting back to a previous healthy release
- Degraded: A current commit that has degraded deployment

# Slide 3: Cluster Setup
- Discuss cluster setup
- Discuss different app versions
- Discuss traffic generator
- Discuss Git
- Show Grafana (discuss Prometheus)
- Briefly discuss Argo CD
- Briefly discuss Argo Rollout

# Demo 1
General Rollout
 - Show App version 1 running at http://prod.local
 - Show App version 1 running at http://preview.local
 - Quick Tour of ArgoCD UI
   - Rollout
   - Services
   - Ingresses
 - Deploy V2
   - Visit the prod page (Confirm customers are still seeing V1)
   - Visit the preview page (Confirm devs can see V2)
   - Show grafana visualization (Confirm V1 traffic)
   - Go through with the rollout to V2 (Discuss Argo CD UI changes)
   - Go to http://prod.local to confirm new version
   - Show Grafana visualization representing new traffic
   - Rollback to V1 via ArgoCD
   - Show prod.local has returned
   - Show Grafana visualization


# Slide: 4
Now that we choose when the new version of our app is accessible to our customers,
what can we do in that mean time before the new version is promoted as a release

- Analysis are Arbitrary Jobs
  - Types of Jobs (Metrics, Web, NewRelic)
    - Metrics Jobs (Prometheus)
    - Possible splunk jobs
- Analysis Count
- Failure Limit
- Example Analysis
  - Smoke Test
  - Payload Test (Increase of static payload)
  - Response Time
  - Request duration
  - Screenshot Testing
  - Resource Usage (CPU/Memory)
  - NodeJS event loop lags (i.e time we spend in running functions)

- Pre-promotion Analysis (When it fails, promotion of release is aborted)
- Post-promotion Analysis (When it fails, release is rolled back)

# Demo 2
- Inform that we will be using dummy analysis for the purposes of speeding things up
-  Deploy version 3 (with pre & post promotion passing and auto deploy)
   -  Discuss auto promotion
   -  Show new app running (prod.local)
   -  Show grafana
-  Deploy version 4 (Pre promotion failing)
   -  Pre promotion failing
   -  Show the ArgoCD UI aborting
   -  Show the events and logs
   -  Show the prod.local referring to V3 
   -  Show grafana visualization
-  Deploy version 1 (With slow post promotion) (Post promotion failing)
   -  Access prod.local to confirm that new version is up anr running 
   -  Show grafana visualization
   -  Show the ArgoCD UI aborting
   -  Show the events and logs
   -  Show the prod.local reverted back to V4 


# Questions

# Slide 4
- Discuss Release Strategies
  - Blue Green
  - Canary Deployment
    - Steps
    - 
    - Analysis
  - Experimental Deployment


# Demo 3
- Delete blue-green app
- Create canary app (Paused Deployment)
- Discuss canary deployment from ArgoCD 