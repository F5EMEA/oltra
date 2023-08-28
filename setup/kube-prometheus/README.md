# Installation nots

Install from  https://github.com/prometheus-operator/kube-prometheus

git clone https://github.com/prometheus-operator/kube-prometheus

Copy manifests/setup to oltra and apply changes


kubectl apply --server-side -f manifests/setup


Add PersistentVolumeClaim

```yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-storage-claim
  namespace: monitoring
spec:
  storageClassName: local-path
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

```

make these changes on Grafana deployment
```yaml
      volumes:
      - name: grafana-storage
        persistentVolumeClaim:
          claimName: grafana-storage-claim
```

Make sure that you dont overwrite the `grafana-dashboardDatasources.yaml` as it contains the data sources for grafana

Prometheus default config is to have access to 3 namespaces: `default/kube-system/monitoring`. We need to add `nginx`

Add the following on `prometheus-roleBindingSpecificNamespaces.yaml`
```yaml
- apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    labels:
      app.kubernetes.io/component: prometheus
      app.kubernetes.io/instance: k8s
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/part-of: kube-prometheus
      app.kubernetes.io/version: 2.46.0
    name: prometheus-k8s
    namespace: nginx
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: prometheus-k8s
  subjects:
  - kind: ServiceAccount
    name: prometheus-k8s
    namespace: monitoring
```

Add the following on `prometheus-roleSpecificNamespaces.yaml`
```yaml
- apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    labels:
      app.kubernetes.io/component: prometheus
      app.kubernetes.io/instance: k8s
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/part-of: kube-prometheus
      app.kubernetes.io/version: 2.46.0
    name: prometheus-k8s
    namespace: nginx
  rules:
  - apiGroups:
    - ""
    resources:
    - services
    - endpoints
    - pods
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - extensions
    resources:
    - ingresses
    verbs:
    - get
    - list
    - watch
  - apiGroups:
    - networking.k8s.io
    resources:
    - ingresses
    verbs:
    - get
    - list
    - watch
```

Delete network policies from manifests folder

Grafana's default user/pass (admin/admin) (Change it to Ingresslink123)

Install the dashboards from Grafanahub

