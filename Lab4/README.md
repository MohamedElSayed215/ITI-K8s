# ☸️ Lab 4 — Persistent Volumes, Downward API & ConfigMaps

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![PersistentVolume](https://img.shields.io/badge/Storage-PV%2FPVC-orange?style=for-the-badge&logo=kubernetes&logoColor=white)
![DownwardAPI](https://img.shields.io/badge/Downward-API-blue?style=for-the-badge)
![ConfigMap](https://img.shields.io/badge/ConfigMap-configuration-9cf?style=for-the-badge)

> Work with Kubernetes storage primitives (PV, PVC, Downward API) and inject configuration data into pods using ConfigMaps — both as environment variables and volume mounts.

---

## 📑 Table of Contents

- [Objectives](#-objectives)
- [Prerequisites](#-prerequisites)
- [Task 1 — Persistent Volumes](#-task-1--persistent-volumes-5-pts)
- [Task 2 — Downward API](#-task-2--downward-api-5-pts)
- [Task 3 — ConfigMaps](#-task-3--configmaps-10-pts)
- [Key Concepts](#-key-concepts)
- [Screenshots](#-screenshots)
- [Files](#-files)

---

## 🎯 Objectives

- Create and bind Persistent Volumes using hostPath
- Use the Downward API to expose pod metadata into the filesystem
- Create ConfigMaps from files and literals
- Mount ConfigMap data as environment variables and volume files

---

## ✅ Prerequisites

- A running Kubernetes / k3s cluster
- `kubectl` configured and working
- Access to the worker node filesystem (for hostPath)

---

## 💾 Task 1 — Persistent Volumes *(5 pts)*

### Steps

**a.** Create a PV named `nginx-pv` using **hostPath** with 1 GB capacity:
```yaml
# nginx-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: /mnt/nginx-data
```

**b.** Create an index.html file on the host with your full name:
```bash
sudo mkdir -p /mnt/nginx-data
echo "<h1>Your Full Name</h1>" | sudo tee /mnt/nginx-data/index.html
```

**c.** Create a PVC that binds to `nginx-pv`:
```yaml
# nginx-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

**d.** Mount the PVC in a deployment of 3 replicas pinned to the **same node**:
```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-hostpath
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-hostpath
  template:
    metadata:
      labels:
        app: nginx-hostpath
    spec:
      nodeSelector:
        kubernetes.io/hostname: <WORKER_NODE_NAME>
      containers:
        - name: nginx
          image: nginx:alpine
          volumeMounts:
            - name: nginx-storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: nginx-storage
          persistentVolumeClaim:
            claimName: nginx-pvc
```

```bash
kubectl apply -f nginx-pv.yaml
kubectl apply -f nginx-pvc.yaml
kubectl apply -f nginx-deployment.yaml
kubectl get pv,pvc
```

---

## 🔍 Task 2 — Downward API *(5 pts)*

Expose `podIP` and `podName` into the pod's filesystem:

**a & b.** Create a Downward API PV and PVC:
```yaml
# downward-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: downward-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/downward-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: downward-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

**c.** Create a deployment that mounts `podIP` and `podName` via Downward API into `index.html`:
```yaml
# downward-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: downward-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: downward
  template:
    metadata:
      labels:
        app: downward
    spec:
      initContainers:
        - name: init-html
          image: busybox
          command:
            - sh
            - -c
            - |
              echo "<h1>Pod Name: $(POD_NAME)</h1><h2>Pod IP: $(POD_IP)</h2>" > /html/index.html
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          volumeMounts:
            - name: html
              mountPath: /html
      containers:
        - name: nginx
          image: nginx:alpine
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      volumes:
        - name: html
          emptyDir: {}
```

---

## 🗂️ Task 3 — ConfigMaps *(10 pts)*

### Steps

**a.** Create `/opt/cm.yaml` and apply it:
```bash
sudo tee /opt/cm.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: birke
data:
  tree: birke
  level: "3"
  department: park
EOF

kubectl apply -f /opt/cm.yaml
```

**b.** Create a ConfigMap named `trauerweide` with `tree=trauerweide`:
```bash
kubectl create configmap trauerweide --from-literal=tree=trauerweide
```

**c.** Create a Pod named `pod1` using `nginx:alpine`:
- Expose key `tree` from ConfigMap `trauerweide` as env variable `TREE1`
- Mount all keys of ConfigMap `birke` as a volume under `/etc/birke/*`

```yaml
# pod1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
    - name: nginx
      image: nginx:alpine
      env:
        - name: TREE1
          valueFrom:
            configMapKeyRef:
              name: trauerweide
              key: tree
      volumeMounts:
        - name: birke-volume
          mountPath: /etc/birke
  volumes:
    - name: birke-volume
      configMap:
        name: birke
```

```bash
kubectl apply -f pod1.yaml

# Verify env variable
kubectl exec pod1 -- env | grep TREE1

# Verify volume mount
kubectl exec pod1 -- ls /etc/birke/
kubectl exec pod1 -- cat /etc/birke/tree
```

---

## 📚 Key Concepts

| Concept | Description |
|---------|-------------|
| `PersistentVolume (PV)` | A piece of storage provisioned in the cluster |
| `PersistentVolumeClaim (PVC)` | A request for storage by a pod |
| `hostPath` | Mounts a file/directory from the host node's filesystem |
| `Recycle` retain policy | PV is scrubbed and made available again after release |
| Downward API | Exposes pod metadata (name, IP, labels) into the container |
| `ConfigMap` | Stores non-confidential key-value configuration data |
| ConfigMap as EnvVar | Injects specific config keys as environment variables |
| ConfigMap as Volume | Mounts all config keys as individual files |

---

## 📸 Screenshots

| Step | Screenshot |
|------|------------|
| `kubectl get pv,pvc` — bound status | *(add screenshot)* |
| nginx serving `index.html` with your name | *(add screenshot)* |
| `podIP` and `podName` displayed in browser | *(add screenshot)* |
| `kubectl exec pod1 -- env \| grep TREE1` | *(add screenshot)* |
| `kubectl exec pod1 -- ls /etc/birke/` | *(add screenshot)* |

---

## 📁 Files

```
lab4/
├── nginx-pv.yaml               # PV with hostPath (1GB, Recycle)
├── nginx-pvc.yaml              # PVC binding to nginx-pv
├── nginx-deployment.yaml       # 3-replica deployment with PVC mount
├── downward-pv.yaml            # PV + PVC for Downward API
├── downward-deployment.yaml    # Deployment exposing podIP & podName
├── cm.yaml                     # ConfigMap "birke" (tree, level, department)
├── configmap-trauerweide.yaml  # ConfigMap "trauerweide" (tree=trauerweide)
├── pod1.yaml                   # Pod with env TREE1 + birke volume mount
├── screenshots/                # Your lab screenshots
└── README.md
```

---

<p align="center"><a href="../lab3/README.md">⬅️ Lab 3</a> &nbsp;|&nbsp; <a href="../README.md">Main README</a></p>
