# 🧩 Microservices Deployment with Kubernetes (K3s)

## 📘 Project Overview

This project deploys a **microservices architecture** on a **K3s Kubernetes cluster** using **Vagrant**.  
It demonstrates key DevOps concepts such as:
- Containerization with **Docker**
- Deployment and orchestration with **Kubernetes**
- Use of **Kubernetes manifests** for Infrastructure as Code (IaC)
- Secure configuration with **Kubernetes Secrets**
- Horizontal scaling and monitoring based on CPU usage

---

## ⚙️ Architecture

The system is composed of several services, each running in its own container:

| Component | Description | Port |
|------------|-------------|------|
| `inventory-database` | PostgreSQL database for the inventory app | 5432 |
| `billing-database` | PostgreSQL database for the billing app | 5432 |
| `rabbitmq` | RabbitMQ message queue | 5672 |
| `inventory-app` | Backend connected to `inventory-database` | 8080 |
| `billing-app` | Backend connected to `billing-database` and consuming RabbitMQ messages | 8080 |
| `api-gateway-app` | API gateway that routes requests to other services | 3000 |

---

## 🏗️ Project Structure

```
.
├── Dockerfiles/
│ ├── Dockerfile.api-gateway
│ ├── Dockerfile.inventory-app
│ ├── Dockerfile.billing-app
│ └── ...
├── Manifests/
│ ├── api-gateway.yaml
│ ├── inventory-app.yaml
│ ├── billing-app.yaml
│ ├── rabbitmq.yaml
│ ├── databases/
│ │ ├── inventory-db.yaml
│ │ └── billing-db.yaml
│ └── secrets.yaml
├── Scripts/
│ └── orchestrator.sh
└── Vagrantfile
```

---

## 🧱 Prerequisites

Before running the project, make sure you have installed:

- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- A [Docker Hub](https://hub.docker.com/) account (for your images)
- Git (to clone and manage the repository)

---

## 🚀 Installation & Usage

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd <your-repo-folder>
```
### 2️⃣ Create and start the K3s cluster

Run the provided script:
```
./Scripts/orchestrator.sh create
```
✅ This command:

Starts the Vagrant virtual machines (master and agent)

Installs K3s on them

Applies all Kubernetes manifests from the Manifests/ directory

### 3️⃣ Verify the cluster status
launch vm with 
```
vagrant ssh master 
```

Once created, check that the nodes are ready:
```
kubectl get nodes
```
Expected output:
```
NAME           STATUS   ROLES                  AGE   VERSION
master-node    Ready    control-plane,master   5m    v1.29.0+k3s1
agent-node     Ready    <none>                 5m    v1.29.0+k3s1
```
Check the running pods:
```
kubectl get pods -A
```

### 4️⃣ Access the services

List all Kubernetes services:
```
kubectl get svc
```
Typical output:
```
NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
api-gateway-svc   NodePort    10.43.84.45    <none>        3000:32000/TCP   2m
inventory-svc     ClusterIP   10.43.14.231   <none>        8080/TCP         2m
billing-svc       ClusterIP   10.43.15.122   <none>        8080/TCP         2m
rabbitmq-svc      ClusterIP   10.43.11.43    <none>        5672/TCP         2m

```

Now, open your browser and go to:
```
http://<master-node-ip>:32000
```
This connects to the API Gateway.

### 5️⃣ Manage the cluster

| Action | Command | Description |
|--------|----------|-------------|
| **Start cluster** | `./Scripts/orchestrator.sh start` | Starts existing VMs and services |
| **Stop cluster** | `./Scripts/orchestrator.sh stop` | Stops the cluster |
| **Delete cluster** | `./Scripts/orchestrator.sh delete` | Destroys all VMs and removes the cluster |
| **Apply manifests manually** | `kubectl apply -f Manifests/` | Re-applies all Kubernetes configs |
| **Delete manifests** | `kubectl delete -f Manifests/` | Removes all Kubernetes resources |


## 🔒 Secrets Management

Database credentials and other sensitive information are stored in Kubernetes Secrets defined in:

``` 
Manifests/secrets.yaml
```
You can view your secrets with:
```
kubectl get secrets
```

## 🧩 Scaling Configuration

api-gateway and inventory-app deployments include Horizontal Pod Autoscalers (HPA).

They automatically scale between 1 and 3 replicas when CPU usage exceeds 60%.

Example:
```
kubectl get hpa
```

## 🧰 Troubleshooting

If you see:
```sh
error: error loading config file "/etc/rancher/k3s/k3s.yaml": permission denied
```

Fix it by running on the master VM:
```sh
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```

Then retry: 
```sh
kubectl get nodes
```