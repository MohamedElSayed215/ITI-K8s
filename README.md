# ☸️ Kubernetes Labs — ITI

![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.34.6-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![k3s](https://img.shields.io/badge/k3s-lightweight-FFC61C?style=for-the-badge&logo=k3s&logoColor=black)
![kubeadm](https://img.shields.io/badge/kubeadm-cluster--setup-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-configs-CC2020?style=for-the-badge&logo=yaml&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

> A hands-on series of Kubernetes labs covering cluster setup, workload management, networking, storage, and configuration — progressing from bare-metal bootstrapping to advanced Ingress routing and ConfigMaps.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Prerequisites](#-prerequisites)
- [Lab 1 — Cluster Installation with kubeadm](#-lab-1--cluster-installation-with-kubeadm)
- [Lab 2 — kubectl Config, Plugins & Deployments](#-lab-2--kubectl-config-plugins--deployments)
- [Lab 3 — Services & Ingress Routing](#-lab-3--services--ingress-routing)
- [Lab 4 — Persistent Volumes, Downward API & ConfigMaps](#-lab-4--persistent-volumes-downward-api--configmaps)
- [Screenshots](#-screenshots)
- [Repo Structure](#-repo-structure)

---

## 🧭 Overview

| Lab | Topic | Key Tools |
|-----|-------|-----------|
| Lab 1 | Cluster Installation | `kubeadm`, `flannel`, `k3s` |
| Lab 2 | kubectl Config & Plugins | `kubectl`, `k3s`, YAML |
| Lab 3 | Ingress & Services | `kubectl expose`, Ingress, ClusterIP |
| Lab 4 | Storage & ConfigMaps | PV, PVC, Downward API, ConfigMap |

---

## ✅ Prerequisites

- Two Linux VMs (e.g., Ubuntu 22.04) — one control plane, one worker
- `kubectl` installed on your local machine
- Basic knowledge of Linux CLI and YAML
- Internet access for pulling images

---

## 🧪 Lab 1 — Cluster Installation with kubeadm

**Objective:** Bootstrap a production-style Kubernetes cluster from scratch using `kubeadm`.

### Tasks

1. **Installing Kubernetes** *(10 pts)*
   - Create 2 virtual machines
   - Install Kubernetes `v1.34.6` on the first server using `kubeadm`
   - Designate the first server as the **control plane** node
   - Deploy the **Flannel** CNI plugin for pod networking
   - Join the second server as a **worker node** using `kubeadm join`

2. **Run a Deployment** *(10 pts)*
   - Use `kubectl` to run a provided deployment on the cluster and verify it is running

3. **⭐ Bonus — k3s** *(5 pts)*
   - Redo the entire lab using **k3s** (lightweight Kubernetes)
   - Set up 1 server node and 1 agent node
   - Verify both nodes are `Ready`

### Key Concepts
`kubeadm init` · `kubeadm join` · CNI (Flannel) · Control Plane · Worker Node · k3s

---

## 🔧 Lab 2 — kubectl Config, Plugins & Deployments

**Objective:** Manage cluster contexts, build custom kubectl plugins, and deploy workloads with specific configurations.

### Tasks

1. **kubectl Config** *(5 pts)*
   - Create a k3s cluster with 1 server (control plane) and 1 agent (worker)
   - Create a new namespace called `iti-46`
   - Edit the `~/.kube/config` file to add a new context named `iti-context` using the default user and the `iti-46` namespace

2. **kubectl Plugin** *(5 pts)*
   - Create a custom kubectl plugin called `kubectl-hostnames`
   - The plugin should display the **hostnames of all nodes** in the cluster

3. **Creating Deployments** *(10 pts)*
   - Write a deployment YAML with **3 replicas** of image `nginx:alpine`
   - Ensure pods have the environment variable `FOO=ITI` set

### Key Concepts
`kubectl config` · Contexts · Namespaces · kubectl Plugins · Deployment YAML · Environment Variables

---

## 🌐 Lab 3 — Services & Ingress Routing

**Objective:** Expose applications internally using ClusterIP services and route external traffic with an Ingress resource.

### Tasks

1. **Ingress and Services** *(15 pts)*
   - Create a namespace called `iti-45`
   - Deploy 2 workloads in the `world` namespace:
     - `africa` — 2 replicas, image `husseingalal/africa:latest`
     - `europe` — 2 replicas, image `husseingalal/europe:latest`
   - Expose both deployments as **ClusterIP Services** on port `8888` → target port `80` (service names must match deployment names)
   - Create an **Ingress** resource named `world` for domain `world.universe.mine`
     - Map domain to the K8s Node IP via `/etc/hosts`
     - Configure two routes:
       - `http://world.universe.mine/europe/` → `europe` service
       - `http://world.universe.mine/africa/` → `africa` service

### Key Concepts
`ClusterIP` · `kubectl expose` · Ingress · Path-based Routing · Namespaces · `/etc/hosts`

---

## 💾 Lab 4 — Persistent Volumes, Downward API & ConfigMaps

**Objective:** Work with Kubernetes storage primitives and inject configuration data into pods.

### Tasks

1. **Persistent Volumes** *(5 pts)*
   - Create a PV named `nginx-pv` using **hostPath** type with **1 GB** storage capacity
   - Create a PVC that binds to `nginx-pv` with **Recycle** retain policy (reusable)
   - Ensure the hostPath directory contains an `index.html` with your full name
   - Mount the PVC inside a deployment of **3 replicas**, all pinned to the **same node**

2. **Downward API** *(5 pts)*
   - Create a **Downward API** PV that exposes `podIP` and `podName`
   - Create a PVC that uses this PV
   - Mount the PVC in a deployment so that `podIP` and `podName` are displayed in `index.html`

3. **ConfigMaps** *(10 pts)*
   - Create a file `/opt/cm.yaml` with the following content and apply it:
     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       name: birke
     data:
       tree: birke
       level: "3"
       department: park
     ```
   - Create a ConfigMap named `trauerweide` with data `tree=trauerweide`
   - Create a Pod named `pod1` using image `nginx:alpine`:
     - Expose key `tree` from ConfigMap `trauerweide` as env variable `TREE1`
     - Mount **all keys** of ConfigMap `birke` as a volume under `/etc/birke/*`

### Key Concepts
`PersistentVolume` · `PersistentVolumeClaim` · `hostPath` · Downward API · `ConfigMap` · Volume Mounts · Environment Variables

---

## 📸 Screenshots

> Add your lab screenshots here to document your work.

| Lab | Description | Screenshot |
|-----|-------------|------------|
| Lab 1 | Nodes ready after kubeadm setup | *(add screenshot)* |
| Lab 1 | k3s cluster nodes up and running | *(add screenshot)* |
| Lab 2 | iti-context in kubectl config | *(add screenshot)* |
| Lab 2 | kubectl-hostnames plugin output | *(add screenshot)* |
| Lab 3 | Ingress routing to /europe and /africa | *(add screenshot)* |
| Lab 4 | PVC mounted, index.html served | *(add screenshot)* |
| Lab 4 | ConfigMap keys available in pod | *(add screenshot)* |

---

## 📁 Repo Structure

```
kubernetes-labs/
├── lab1/
│   ├── deployment.yaml
│   └── README.md
├── lab2/
│   ├── deployment.yaml
│   ├── kubectl-hostnames
│   └── README.md
├── lab3/
│   ├── africa-deployment.yaml
│   ├── europe-deployment.yaml
│   ├── services.yaml
│   ├── ingress.yaml
│   └── README.md
├── lab4/
│   ├── nginx-pv.yaml
│   ├── nginx-pvc.yaml
│   ├── downward-pv.yaml
│   ├── configmap-birke.yaml   (cm.yaml)
│   ├── configmap-trauerweide.yaml
│   ├── pod1.yaml
│   └── README.md
└── README.md
```

---

## 👤 Author

**[Your Name]**
- GitHub: [@yourusername](https://github.com/yourusername)

---

<p align="center">Made with ❤️ and lots of <code>kubectl apply</code></p>
