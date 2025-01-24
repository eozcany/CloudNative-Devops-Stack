
# Reversed-IP App

The **Reversed-IP App** is a Node.js application deployed locally using Docker and Kubernetes. This guide provides a step-by-step process for deploying the app along with its dependencies (MySQL) using Helm.

## Local Deployment 

### Prerequisites

Before deploying the app, ensure the following are installed:

- [Docker](https://www.docker.com/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) or a Kubernetes cluster
- [Helm](https://helm.sh/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)

---

### Step-by-Step Local Deployment Guide

#### Start Minikube
```
minikube start 
```
#### Build the Docker image
```
eval $(minikube docker-env)
cd app
docker build -t reversed-ip:1.0 .
```
#### Deploy the Application with Helm
```
cd helm/charts/local
helm dependency update
helm install local .
```
#### Verify the deployment:
```
kubectl get pods
```
#### Access the Application
```
kubectl port-forward svc/local-reversed-ip 8000:80
```

Open the browser hit http://localhost:8000/

## AWS EKS Deployment 

[https://reversed-ip.hyprime.io](https://reversed-ip.hyprime.io/)

### Prerequisites

Before deploying the app, ensure the following are installed:

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Helm](https://helm.sh/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS Profile](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html)
- [Github PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

### Step-by-Step Local Deployment Guide

#### Navigate to the Terraform code and initilize

```
cd terraform/live
terraform init
```

#### Deploy VPC and EKS at the beginning for only first apply

why: Terraform code consumes both kubernetes and aws provider, so without provisioning an EKS cluster, kubernetes provider terraform resource will throws the error

```
terraform plan --target module.eks --target module.vpc
terraform apply --target module.eks --target module.vpc
```

Use --auto-approve flag or type yes if terraform asks to continue


#### Deploy AWS and Kubernetes resources

```
terraform plan 
terraform apply
```

## CI-CD Pipeline

- Uses Github Actions Runner
- Runner Pods are provisioned in Kubernetes by deployed [Actions Runner Controller](https://github.com/actions/actions-runner-controller/tree/master)
- Find the actions runner file .github/workflows/reversed-ip-ci-cd.yaml
- Once application updated, Actions runner will be triggered automatically

## Architecture

- Nodejs : Application Software Language
- Docker : Container Runtime and Image Creating
- IaC : Terraform, Helm
- Cloud: AWS
- Container Orchestration: Kubernetes (EKS Managed Control Plan, Spot Worker Nodes)
- Networking and Firewall : VPC and Security Groups, (Public and Prviate Subnet)
- CI-CD: Github Actions
- CI-CD Runners: Actions Runner Controller on Kubernetes
- Deployment Strategy: Rolling Update
- Container Registry: AWS ECR
- Secrets Management: AWS Secrets Manager
- Database: MySQL (K8s Deployment)
- DNS: AWS Route53
- TLS Certificates: AWS ACM
- Secrets Synchronizer: External-Secrets Operator on K8s
- Traffic Management: Nginx Ingress Controller On K8s
- Load Balancing : AWS ALB
- EKS Worker Node Scaling: Cluster Autoscaler on K8s
- Kubernetes Metrics Provider: Metrics Server on K8s
- IAM Management: IRSA Roles with least permissions trusted only apps on defined namespaces


## Possible Improvements Neglected by time and cost boundary

- Argo CD could be used to deploy reversed-ip app if an image pushed to the ECR Registy

- Github APP could be used instead PAT (Github Personel Access Token) to deploying Actions Runner Controller on K8s

- Karpenter could be used instead Cluster Autoscaler

- RDS could be used as a DB instead Mysql K8s Deployment

- K8s Resource Limits/Request could be adjusted for all helm and k8s deployments

- Actions Runner RBAC could be optimized according to Least Permission Principle

- S3 backend could be used for Terraform.