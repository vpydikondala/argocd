# DevOps Microshop Monorepo

This repo contains both application code and infrastructure for GitOps CI/CD:

- apps/ - microservices source and Dockerfiles
- infra/ - Helm charts, ArgoCD manifests, environment configs
- .github/workflows - GitHub Actions CI/CD pipelines

# DevOps Microshop Monorepo (GitOps CI/CD Project)

This is a full-stack GitOps-enabled monorepo project using:

- Kubernetes (via Minikube)
- Helm charts for deployments
- ArgoCD for GitOps continuous delivery
- GitHub Actions for CI/CD pipelines
- GitHub Container Registry (GHCR) for container image hosting

---

## Monorepo Structure

argocd/
├── apps/
│ └── product-api/
│ ├── app/
│ │ └── main.py
│ └── Dockerfile
│
├── infra/
│ ├── charts/
│ │ └── product-api/
│ ├── environments/
│ │ └── dev/
│ │ ├── values/
│ │ │ └── product-api-values.yaml
│ │ └── argocd/
│ │ └── product-api-app.yaml
│
├── .github/
│ └── workflows/
│ ├── ci.yaml
│ └── deploy.yaml
│
└── README.md


## Prerequisites

- Docker
- Minikube
- kubectl
- Helm
- ArgoCD CLI (optional)
- yq (YAML processor)
- GitHub account and PAT (Personal Access Token)

---

## Step-by-Step Instructions

### 🔧 Step 1: Start Minikube

minikube start --cpus=4 --memory=6g
minikube addons enable ingress

## Step 2: Install ArgoCD on Minikube

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

## Port forward ArgoCD UI:

kubectl port-forward svc/argocd-server -n argocd 8080:443

## Get initial ArgoCD admin password:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

Login to: https://localhost:8080

### Step 3: Configure Hosts File

echo "$(minikube ip)  product.local" | sudo tee -a /etc/hosts

Step 4: Deploy ArgoCD Application

kubectl apply -f ./infra/environments/dev/argocd/product-api-app.yaml -n argocd

## GitHub Actions Setup

## Add Secrets to GitHub

Secret Name	        Description
PERSONAL_TOKEN	    GitHub PAT with repo access

## GitHub Actions Workflows

.github/workflows/ci.yaml

Builds and pushes Docker image to GHCR

.github/workflows/deploy.yaml

Updates Helm value file (GitOps-style trigger)

### Test End-to-End

Push code to apps/product-api

GitHub builds & pushes Docker image

Deploy workflow updates image tag

ArgoCD syncs changes automatically

Access app at: http://product.local

### Ideas for Expansion
Add multiple microservices under apps/

Split environments (dev, staging, prod)

Add Argo Rollouts for canary/blue-green

Add Prometheus, Grafana for monitoring

Use Sealed Secrets or External Secrets

### Maintainer

Author: Pydikondala Venkanna

GitHub: @vpydikondala

### License

MIT © Venkanna Pydikondala