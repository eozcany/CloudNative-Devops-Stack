# Reversed-IP App

The **Reversed-IP App** is a Node.js application deployed locally using Docker and Kubernetes. This guide provides a step-by-step process for deploying the app along with its dependencies (MySQL) using Helm.

## Local Deployment 

### Prerequisites

Before deploying the app, ensure the following are installed:

- [Docker](https://docs.docker.com/desktop/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) or a Kubernetes cluster
- [Helm](https://helm.sh/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

---

### Step-by-Step Local Deployment Guide

#### Start Minikube

minikube start 

#### Build the Docker image
eval $(minikube docker-env)

docker build -t reversed-ip:1.0 .

#### Deploy the Application with Helm
cd helm/charts/local
helm dependency update
helm install local .

#### Verify the deployment:
kubectl get pods

#### Access the Application
kubectl port-forward svc/local-reversed-ip 8000:80

Open the browser hit http://localhost:8000/

