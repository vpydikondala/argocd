# Product API GitOps Deployment with Helm & Argo CD

### Overview
This repository demonstrates a complete **GitOps workflow** for deploying a **FastAPI-based Product API** application onto **Kubernetes** using:

- **Helm** → package, templatize, and manage Kubernetes manifests  
- **Argo CD** → continuously sync cluster state from this Git repo  
- **Minikube / Kubernetes** → runtime platform  
- **GitHub** → single source of truth for app and infra definitions  

All cluster resources are declarative, version-controlled, and automatically reconciled by Argo CD.



### Repository Structure

.
├── .github/ # (Optional) CI/CD workflows
├── apps/
│ └── product-api/ # Application code & tooling
│ ├── Dockerfile # Container definition for Product API
│ ├── docker/ # Docker context / helpers
│ ├── argocd/ # Argo CD related files
│ └── kubectl/ # Utility scripts
├── infra/
│ └── charts/product-api/ # Helm chart for product-api
│ ├── templates/ # Deployment, Service, Ingress templates
│ ├── values.yaml # Default Helm values
│ ├── Chart.yaml # Chart metadata
│ └── _helpers.tpl # Helm helper templates
├── environments/
│ └── dev/argocd/ # Environment-specific configs
│ ├── product-api-app.yaml # Argo CD Application CRD
│ └── values.yaml # Dev overrides
├── README.md # Project documentation
└── .gitignore # Ignore rules (e.g., secrets)


### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)  
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [Minikube](https://minikube.sigs.k8s.io/docs/) (for local cluster)  
- [Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/) installed in cluster  
- [Helm](https://helm.sh/docs/intro/install/)  



## 🐳 Building the Docker Image

From repo root:

docker build -t ghcr.io/<your-username>/product-api:latest ./apps/product-api
docker push ghcr.io/<your-username>/product-api:latest
Update infra/charts/product-api/values.yaml with the new tag.

### Deploy with Argo CD (GitOps)
Commit your chart and values changes to GitHub.

Argo CD watches the repo and automatically syncs the Application CRD:


# environments/dev/argocd/product-api-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: product-api-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<your-org>/<your-repo>.git
    targetRevision: main
    path: infra/charts/product-api
    helm:
      valueFiles:
        - environments/dev/argocd/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
Argo CD applies the Deployment, Service, and Ingress automatically.

### Accessing the Application
Option 1: Ingress (preferred)
Ensure Minikube ingress addon is enabled:


minikube addons enable ingress
Get Minikube IP:


minikube ip
Edit your hosts file (Windows: C:\Windows\System32\drivers\etc\hosts, Linux: /etc/hosts) and add:


<minikube-ip> product.local
Visit: http://product.local/

Option 2: Port-Forward (debugging)

kubectl port-forward -n default svc/product-api 8081:80
curl http://localhost:8081/
### Secrets Management
Image pull secrets (ghcr-creds) are referenced by name in values.yaml.

Secrets are not committed to Git.

Recommended options for production:

Sealed Secrets

SOPS

External Secrets Operator

### Cleaning Up from Minikube
Remove just the Product API

kubectl delete application product-api-app -n argocd --ignore-not-found
kubectl delete deploy,svc,ingress -n default -l app=product-api --ignore-not-found
Remove Argo CD (if installed in cluster)

kubectl delete ns argocd
Reset Minikube completely

minikube delete
### Next Steps
Add CI workflow to auto-build & push Docker image (GitHub Actions).

Add production environment under environments/prod/.

Introduce Sealed Secrets for secure secret management.

Enable monitoring with Prometheus/Grafana.

### Summary
This project shows how to:

Package an app with Helm

Manage cluster state with GitOps (Argo CD)

Deploy into Kubernetes

Expose via Ingress

Keep everything declarative, reproducible, and automated