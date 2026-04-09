# ☸️ Lab 1 — Kubernetes Cluster Installation

![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.34.6-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![kubeadm](https://img.shields.io/badge/kubeadm-bootstrap-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![k3s](https://img.shields.io/badge/k3s-bonus-FFC61C?style=for-the-badge&logo=k3s&logoColor=black)
![Flannel](https://img.shields.io/badge/CNI-Flannel-purple?style=for-the-badge)

> Bootstrap a production-style Kubernetes cluster from scratch using `kubeadm`, deploy a workload, and optionally replicate the setup using lightweight **k3s**.

---

## 📑 Table of Contents

- [Objectives](#-objectives)
- [Prerequisites](#-prerequisites)
- [Task 1 — Installing Kubernetes](#-task-1--installing-kubernetes-10-pts)
- [Task 2 — Run a Deployment](#-task-2--run-a-deployment-10-pts)
- [Task 3 — Bonus: k3s](#-task-3--bonus-k3s-5-pts)
- [Key Concepts](#-key-concepts)
- [Screenshots](#-screenshots)
- [Files](#-files)

---

## 🎯 Objectives

- Set up a multi-node Kubernetes cluster using `kubeadm`
- Configure pod networking with the Flannel CNI plugin
- Run a deployment on the cluster using `kubectl`
- *(Bonus)* Replicate the setup using k3s

---

## ✅ Prerequisites

- 2 Linux VMs (e.g., Ubuntu 22.04) with network connectivity between them
- At least **2 CPUs** and **2 GB RAM** per VM
- `kubectl` installed
- Swap disabled on both VMs (`sudo swapoff -a`)

---

## 🔧 Task 1 — Installing Kubernetes *(10 pts)*

### Steps

**a.** Create 2 virtual machines

**b.** On the first server, install Kubernetes `v1.34.6` using `kubeadm`:
```bash
sudo kubeadm init --kubernetes-version=v1.34.6 --pod-network-cidr=10.244.0.0/16
```

**c.** Configure `kubectl` on the control plane:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**d.** Apply the **Flannel** CNI plugin:
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```
![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab1/screenshots/ip.jpg)
**e.** Join the second server as a worker node:
```bash
# Run the kubeadm join command printed after kubeadm init, e.g.:
sudo kubeadm join <CONTROL_PLANE_IP>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

**Verify both nodes are Ready:**
```bash
kubectl get nodes
```
![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab1/screenshots/get-node.jpg)
---

## 🚀 Task 2 — Run a Deployment *(10 pts)*

Apply the deployment on the cluster using `kubectl`:
```bash
kubectl apply -f deployment.yaml
kubectl get pods -o wide
```
![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab1/screenshots/deployments.jpg)
---

## ⭐ Task 3 — Bonus: k3s *(5 pts)*

Redo the lab using **k3s** (lightweight Kubernetes):

**On the server node:**
```bash
curl -sfL https://get.k3s.io | sh -
# Get the node token
sudo cat /var/lib/rancher/k3s/server/node-token
```

**On the agent node:**
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<NODE_TOKEN> sh -
```

**Verify nodes:**
```bash
sudo k3s kubectl get nodes
```

---

## 📚 Key Concepts

| Concept | Description |
|---------|-------------|
| `kubeadm init` | Bootstraps the control plane node |
| `kubeadm join` | Adds worker nodes to the cluster |
| CNI (Flannel) | Container Network Interface for pod-to-pod networking |
| Control Plane | Node that manages the cluster state |
| Worker Node | Node that runs application workloads |
| k3s | Lightweight Kubernetes distribution by Rancher |

---

## 📸 Screenshot

| Step | Screenshot |
|------|------------|
| k3s status | ![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab1/screenshots/k3s.jpg) |
| k3s nodes up and running (bonus) | ![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab1/screenshots/get-node-k3s.jpg) |

---

## 📁 Files

```
lab1/
├── deployment.yaml       # Deployment manifest for Task 2
├── screenshots/          # Your lab screenshots
└── README.md
```
