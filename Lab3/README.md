# ☸️ Lab 3 — Services & Ingress Routing

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Ingress](https://img.shields.io/badge/Ingress-Routing-0078D7?style=for-the-badge&logo=kubernetes&logoColor=white)
![ClusterIP](https://img.shields.io/badge/Service-ClusterIP-green?style=for-the-badge)
![YAML](https://img.shields.io/badge/YAML-configs-CC2020?style=for-the-badge&logo=yaml&logoColor=white)

> Expose applications internally using **ClusterIP** services and route external HTTP traffic to multiple backends using a single **Ingress** resource with path-based routing.

---

## 📑 Table of Contents

- [Objectives](#-objectives)
- [Prerequisites](#-prerequisites)
- [Task — Ingress and Services](#-task--ingress-and-services-15-pts)
- [Architecture](#-architecture)
- [Key Concepts](#-key-concepts)
- [Screenshots](#-screenshots)
- [Files](#-files)

---

## 🎯 Objectives

- Create namespaces and manage multi-deployment environments
- Expose deployments as ClusterIP services
- Configure an Ingress resource with path-based routing rules
- Map a custom domain to the cluster node via `/etc/hosts`

---

## ✅ Prerequisites

- A running Kubernetes / k3s cluster
- An Ingress controller installed (e.g., Traefik — bundled with k3s, or nginx-ingress)
- `kubectl` configured and working
- Access to edit `/etc/hosts` on your machine

---

## 🌐 Task — Ingress and Services *(15 pts)*

### Steps

**a.** Create a namespace called `iti-46`:
```bash
kubectl create namespace iti-46
```

**b.** Create 2 deployments in the `world` namespace:

```yaml
# africa-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: africa
  namespace: world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: africa
  template:
    metadata:
      labels:
        app: africa
    spec:
      containers:
        - name: africa
          image: husseingalal/africa:latest
          ports:
            - containerPort: 80
```

```yaml
# europe-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: europe
  namespace: world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: europe
  template:
    metadata:
      labels:
        app: europe
    spec:
      containers:
        - name: europe
          image: husseingalal/europe:latest
          ports:
            - containerPort: 80
```

**c.** Expose both deployments as **ClusterIP** services on port `8888` → target port `80`:
```bash
kubectl expose deployment africa --port=8888 --target-port=80 -n world
kubectl expose deployment europe --port=8888 --target-port=80 -n world
```

Or using a YAML manifest:
```yaml
# services.yaml
apiVersion: v1
kind: Service
metadata:
  name: africa
  namespace: world
spec:
  selector:
    app: africa
  ports:
    - port: 8888
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: europe
  namespace: world
spec:
  selector:
    app: europe
  ports:
    - port: 8888
      targetPort: 80
```

**d.** Add the domain to `/etc/hosts` on your machine:
```bash
echo "<NODE_IP>  world.universe.mine" | sudo tee -a /etc/hosts
```

**e.** Create the **Ingress** resource named `world`:
```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world
  namespace: world
spec:
  rules:
    - host: world.universe.mine
      http:
        paths:
          - path: /europe/
            pathType: Prefix
            backend:
              service:
                name: europe
                port:
                  number: 8888
          - path: /africa/
            pathType: Prefix
            backend:
              service:
                name: africa
                port:
                  number: 8888
```

```bash
kubectl apply -f ingress.yaml
```

**Verify routing:**
```bash
curl http://world.universe.mine/europe/
curl http://world.universe.mine/africa/
```

---

## 🗺️ Architecture

```
                        world.universe.mine
                               │
                        /etc/hosts → Node IP
                               │
                       ┌───────▼────────┐
                       │  Ingress: world │
                       └───────┬────────┘
                 ┌─────────────┴─────────────┐
                 │                           │
          /europe/                       /africa/
                 │                           │
        ┌────────▼────────┐       ┌──────────▼──────────┐
        │ Service: europe  │       │  Service: africa     │
        │ ClusterIP :8888  │       │  ClusterIP :8888     │
        └────────┬────────┘       └──────────┬──────────┘
                 │                           │
        ┌────────▼────────┐       ┌──────────▼──────────┐
        │  Pod (x2)        │       │  Pod (x2)            │
        │  europe:latest   │       │  africa:latest       │
        └─────────────────┘       └─────────────────────┘
```

---

## 📚 Key Concepts

| Concept | Description |
|---------|-------------|
| `ClusterIP` | Internal-only service type, accessible within the cluster |
| `kubectl expose` | Quickly creates a service for a deployment |
| Ingress | Manages external HTTP/S access to cluster services |
| Path-based Routing | Route traffic to different services based on URL path |
| Ingress Controller | The component that fulfills Ingress rules (e.g., Traefik, nginx) |
| `/etc/hosts` | Maps custom domain names to IP addresses locally |

---

## 📸 Screenshots

| Step | Screenshot |
|------|------------|
| Objects running in `world` namespace | ![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab3/screenshots/part2.jpg) |
| `curl` response from `/europe/` & `/africa/` routes | ![](https://github.com/MohamedElSayed215/ITI-K8s/blob/main/Lab3/screenshots/test-part2.jpg) |

---

## 📁 Files

```
lab3/
├── africa-deployment.yaml    # africa deployment (2 replicas)
├── europe-deployment.yaml    # europe deployment (2 replicas)
├── services.yaml             # ClusterIP services for both deployments
├── ingress.yaml              # Ingress resource with path-based routing
├── screenshots/              # Your lab screenshots
└── README.md
```

---

<p align="center"><a href="../lab2/README.md">⬅️ Lab 2</a> &nbsp;|&nbsp; <a href="../README.md">Main README</a> &nbsp;|&nbsp; <a href="../lab4/README.md">Lab 4 ➡️</a></p>
