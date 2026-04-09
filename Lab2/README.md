# ☸️ Lab 2 — kubectl Config, Plugins & Deployments

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![k3s](https://img.shields.io/badge/k3s-cluster-FFC61C?style=for-the-badge&logo=k3s&logoColor=black)
![kubectl](https://img.shields.io/badge/kubectl-plugin-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-configs-CC2020?style=for-the-badge&logo=yaml&logoColor=white)

> Manage cluster contexts and namespaces, build a custom `kubectl` plugin, and deploy workloads with environment variable configurations.

---

## 📑 Table of Contents

- [Objectives](#-objectives)
- [Prerequisites](#-prerequisites)
- [Task 1 — kubectl Config](#-task-1--kubectl-config-5-pts)
- [Task 2 — kubectl Plugin](#-task-2--kubectl-plugin-5-pts)
- [Task 3 — Creating Deployments](#-task-3--creating-deployments-10-pts)
- [Key Concepts](#-key-concepts)
- [Screenshots](#-screenshots)
- [Files](#-files)

---

## 🎯 Objectives

- Create a k3s cluster and manage namespaces and contexts via `kubeconfig`
- Write a custom `kubectl` plugin to extend CLI functionality
- Deploy an application using a YAML manifest with environment variables

---

## ✅ Prerequisites

- A running k3s cluster (from Lab 1 bonus or fresh setup)
- `kubectl` configured and pointing to the cluster
- Basic shell scripting knowledge (for the plugin)

---

## 🔧 Task 1 — kubectl Config *(5 pts)*

### Steps

**a.** Create a k3s cluster with 1 server (control plane) and 1 agent (worker) — refer to Lab 1 bonus.

**b.** Create a new namespace called `iti-46`:
```bash
kubectl create namespace iti-46
```

**c.** Edit `~/.kube/config` to add a new context named `iti-context` using the default user and `iti-46` namespace:
```bash
kubectl config set-context iti-context \
  --cluster=default \
  --user=default \
  --namespace=iti-46
```

**Switch to the new context:**
```bash
kubectl config use-context iti-context
kubectl config get-contexts
```

---

## 🔌 Task 2 — kubectl Plugin *(5 pts)*

Create a plugin called `kubectl-hostnames` that displays hostnames of all nodes:

**a.** Create the plugin script:
```bash
sudo nano /usr/local/bin/kubectl-hostnames
```

**b.** Add the following content:
```bash
#!/bin/bash
kubectl get nodes -o custom-columns="HOSTNAME:.metadata.name"
```

**c.** Make it executable:
```bash
sudo chmod +x /usr/local/bin/kubectl-hostnames
```

**d.** Run it:
```bash
kubectl hostnames
```

---

## 🚀 Task 3 — Creating Deployments *(10 pts)*

Create a deployment YAML with **3 replicas** of `nginx:alpine` and env variable `FOO=ITI`:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: iti-46
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          env:
            - name: FOO
              value: "ITI"
```

**Apply and verify:**
```bash
kubectl apply -f deployment.yaml
kubectl get pods -n iti-46
kubectl exec -it <pod-name> -n iti-46 -- env | grep FOO
```

---

## 📚 Key Concepts

| Concept | Description |
|---------|-------------|
| `kubeconfig` | File storing cluster connection info, users, and contexts |
| Context | A named combination of cluster + user + namespace |
| Namespace | Logical isolation of resources within a cluster |
| kubectl Plugin | A binary/script prefixed with `kubectl-` on PATH |
| Deployment | Manages a set of identical, replicated pods |
| Environment Variables | Key-value pairs injected into container runtime |

---

## 📸 Screenshots

| Step | Screenshot |
|------|------------|
| `kubectl config get-contexts` showing `iti-context` | *(add screenshot)* |
| `kubectl hostnames` plugin output | *(add screenshot)* |
| Pods running with `FOO=ITI` env variable | *(add screenshot)* |

---

## 📁 Files

```
lab2/
├── deployment.yaml         # nginx:alpine deployment with FOO=ITI
├── kubectl-hostnames       # Custom kubectl plugin script
├── screenshots/            # Your lab screenshots
└── README.md
```

---

<p align="center"><a href="../lab1/README.md">⬅️ Lab 1</a> &nbsp;|&nbsp; <a href="../README.md">Main README</a> &nbsp;|&nbsp; <a href="../lab3/README.md">Lab 3 ➡️</a></p>
