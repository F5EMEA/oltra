# NGINX Service Mesh

## Download the meshctl utility

Download the meshctl AMD64 Linux binary from [downloads.f5.com](https://downloads.f5.com/esd/product.jsp?sw=NGINX-Public&pro=NGINX_Service_Mesh)

```
mkdir ~/bin
curl -o ~/bin/nginx-meshctl.gz '<S3 link from downloads.f5.com>'
gunzip ~/bin/nginx-meshctl.gz
chmod +x ~/bin/nginx-meshctl
export PATH=~/bin:$PATH
```

## Prepare the Kubernetes Cluster

### Modify the Kube-API Server

The KubeAPI Server needs to be modified to enable Service Account Token Volume Projection.

You need to `ssh` on to the master node, and modify `/etc/kubernetes/manifests/kube-apiserver.yaml`.
Ensure that the following arguments are patched into the file:

```
spec:
  containers:
  - command:
    - kube-apiserver
    - --service-account-api-audiences=api
    - --service-account-issuer=api
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
```

### Add Jaeger, Zipkin and OpenTelemetry

We have a monitoring namespace in the OLTRA K8s cluster, but it doesn't (yet) include OpenTracing/OpenTelemetry
by default, so we need to add those services before we deploy the service mesh.

```
kubectl apply -f monitoring/jaeger.yaml
kubectl apply -f monitoring/zipkin.yaml
kubectl apply -f monitoring/otel.yaml
```

## Deploy the Service Mesh

We currently have no persistent storage in OLTRA, so we need to use the `--persistent-storage` flag to turn this off.
This is not recommended in a real deployment scenario.
See: [Persistent Storage Docs](https://docs.nginx.com/nginx-service-mesh/get-started/kubernetes-platform/persistent-storage/)

```
nginx-meshctl deploy \
  --registry-server docker-registry.nginx.com/nsm \
  --mtls-mode=strict \
  --mtls-trust-domain k8s.oltra.demo \
  --access-control-mode deny \
  --prometheus-address prometheus.monitoring.svc:9090 \
  --telemetry-exporters "type=otlp,host=otel-collector.monitoring.svc,port=4317" \
  --telemetry-sampler-ratio 0.25 \
  --disabled-namespaces kube-system,monitoring \
  --persistent-storage off
```

