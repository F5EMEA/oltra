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

Make sure that you dont overwrite the `grafana-dashboardDatasources.yaml`

Delete network policies from manifests folder

Grafana's default user/pass (admin/admin) (Change it to Ingresslink123)

Install the dashboards from Grafanahub
