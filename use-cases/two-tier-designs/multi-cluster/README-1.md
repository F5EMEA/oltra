# 2 Tier Architectures
In this section we will go through different scenarios for two tier architectures. 

Today, organizations are increasingly deploying more Kubernetes clusters and are implementing multi-cluster strategies in an effort to improve availability, scalability and isolation. Multi-cluster strategy is achieved by deploying an application on or across multiple Kubernetes clusters.  

In this use-case we will focus on same applications running on muliple clusters, which can be architected with two fundamental ways; GSLB or Load Balancing. 

## GSLB
Typical requirements of a multi-cluster GSLB environment cover the following:
1. Applications should be able to work as Active-Active or Active-Standby
2. Health monitoring should be provided on both the GSLB and K8s level


## Proposed Architecture
In order to address the above requirements we have designed a 2-tier architecture. The 1st tier is based on NGNIX+ Ingress Controller and will be deployed in each tentant while the 2nd tier is based on BIGIP/CIS that will have the role of the external load balancer.

<p align="center">
  <img src="https://raw.githubusercontent.com/skenderidis/f5-ingress-lab/main/use-cases/cluster-multi-tenancy/multi-tenancy.png" style="width:85%">
</p>

### Tier 1 - NGINX+ Ingress Controller
In our design we choose to have separate NGINX+ Ingress Controller deployment per tenant. This design was prefered because of the following benefits:

- **Security.** By deploying seperate IC instances, we are creating a full isolation for both dataplane and control plane between tenants. This means that in situation of high-usage, attacks or even misconfiguration on a tenant's IC this will not affect other tenants deployments.  

- **Customization.** Generally, you can customize or fine tune your IC behavior through the use of configmaps (e.g., set the number of worker processes, customize the access log format). While this is very important for the application delivery, ConfigMap applies globally, meaning that it affects every Ingress resource. Therefore if applied across mulitple tenants, you cannot fine-tune these variables based on each tenant's requirements.

- **Management.** When sharing a single IC across multiple tentants, the responsibility for upgrading, patching, scaling, performance-tuning, etc lies with the operator. By having seperate IC per tenant the responsibility can be transfered or shared with the tenants.

When running NGINX Ingress Controller, you have the following options with regards to which configuration resources it handles:

- **Cluster-wide Ingress Controller.** The Ingress Controller handles configuration resources created in any namespace of the cluster.
- **Single-namespace Ingress Controller (selected).** You can configure the Ingress Controller to handle configuration resources only from a particular namespace, which is controlled through the -watch-namespace command-line argument. In this design we chose to have a separate IC per namespace


### Tier 2 - BIGIP / CIS (external Load Balancer)
BIGIP role in the overall design is to publish the NGINX IC outside of the Kubernetes environment. To achieve that we are using CIS to discover the NGINX IC services and publish each service with with a different VIP on BIGIP.  

**Discovery**
Tenants, have at least one NGINX IC service running on their environment and some tentants might even run multiple NGINX IC services. CIS is used to discover the NGINX IC services running across all tenants and configure BIGIP accordingly. This can be achieve by deploying one of the 3 available CIS CRDs (**VirtualServer**, **TransportServer** or **IngressLink**) on the same namespaces as the NGINX IC services are running or publish the IC services with Type Load Balancer. Choosing between these methods on the type of functionality/features you need to enable on BIGIP. The following matrix gives you a brief explanation on what can be achieved by each CRDs.

| Type | Functionality |
|---|---|
| VirtualServer CRD | With VS CRD you can enable multiple functionalities such as **Reverse Proxy**, **DDoS**, **BoT mitigation**, **SSL offloading**, **HTTP/HTTP2 profiles**, **L4/7 iRules**, **WAF policies**, **SNAT pools** , **Cookie/IP Persistence**, **EDNS**. <br> Examples on VirtualServer CRD can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#virtualserver-crd-examples">here</a> |
| TransportServer CRD |  With TS CRD you can enable primarily L4 functionalities such as **Reverse Proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP Persistence**.<br> Examples on TransportServer CRD can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#transportserver-crd-examples">here</a> |
| Service Type LB | With service type LB you can enable primarily L4 functionalities like TS CRD such as **Reverse Proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP persistence**.<br> Examples on Service Type LB can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#service-type-loadbalancer-examples">here</a> |


**Separation** 

Given the fact that we are sharing the same BIGIP device across all tenants, we need to consider how to allocate IP addresses without creating conflict between tenants. The way to achieve this is by using F5's IPAM controller. The IPAM controller will be configured with different labels per tenat and each label will define the IP ranges that should be assigned per tenant.
These labels must be referenced on the CIS CRDs that will be used to publish the NGINX IC services.

> **How to avoid tenats changing IPAM labels** <br>
> **Option 1.** CIS CRDs are deployed/managed by the Kubernetes administrator and the tenant has read-only rights.<br>
> **Option 2.** CIS CRDs can only be deployed throught a pipeline that verifies the right usage of the labels. Manifests are created/stored on a GIT by the tenant and then a pipeline applies the desired state on the K8s cluster. Tenant has read-only rights on the CRDs. <br>
> **Option 3.** Finally as the last option we can use [**OPA Gatekeeper**](https://open-policy-agent.github.io/gatekeeper/website/docs/). Gatekeeper's engine is designed to be portable, allowing administrators to detect and reject non-compliant commits to an infrastructure-as-code system's source-of-truth, further strengthening compliance efforts and preventing bad state from slowing down the organization. Therefore the administrator can set the label values that need to be present on the CIS CRD in order for it to be accepted. 

More information on CIS and IPAM can be found on the following links:
- [CIS](https://clouddocs.f5.com/containers/latest/)
- [CIS CRDs](https://clouddocs.f5.com/containers/latest/userguide/crd/)
- [IPAM Controller](https://clouddocs.f5.com/containers/latest/userguide/ipam/)


## Demo 

### Step 1. Create Tentants

Create the namespace for each tenant (Tenant-1, Tenant-2)
```
kubectl create namespace tenant1
kubectl create namespace tenant2
```

### Step 2. Deploy NGINX+ Ingress Controller

For each tenant we will deploy a seperate NGINX+ Ingress Controller. 

1. Copy the NGINX plus deployment from the setup folder
```
cd ~/oltra/use-cases/multi-tenancy
mkdir nginx_t1
mkdir nginx_t2
cp -R ~/oltra/setup/nginx-ic/* nginx_t1
cp -R ~/oltra/setup/nginx-ic/* nginx_t2
```

2. Replace the namespace `nginx` with `tenant1` and `tenant2` for the required manifests
```
./rename.sh
```

3. Apply configurations
```
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t1/rbac
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t2/rbac
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t1/resources
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t2/resources
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t1/nginx-plus
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t2/nginx-plus
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t1/publish
kubectl apply -f ~/oltra/use-cases/multi-tenancy/nginx_t2/publish
```

4. Verify that the NGINX pods are up and running on each tenant

```
kubectl get pods -n tenant1
kubectl get pods -n tenant2
```
```
####################################      Expected Output   ######################################
NAME                            READY   STATUS    RESTARTS   AGE
nginx-tenant1-74fd9b786-hqm6k   1/1     Running   0          22s
##################################################################################################
```

5. Confirm that CIS TransportServer CRDs have been deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts -n tenant1
kubectl get ts -n tenant2
```
```
####################################      Expected Output   ######################################
NAME            VIRTUALSERVERADDRESS   VIRTUALSERVERPORT   POOL            POOLPORT   IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
nginx-tenant1                          80                  nginx-tenant1   80         tenant1     10.1.10.191     Ok       30h
##################################################################################################
```

6. Save the IP adresses that was assigned by the IPAM for each tenant NGINX services
```
IP_tenant1=$(kubectl get ts nginx-tenant1 -n tenant1 --template '{{.status.vsAddress}}')
IP_tenant2=$(kubectl get ts nginx-tenant2 -n tenant2 --template '{{.status.vsAddress}}')
```

7. Try accessing the service as per the example below. 
```
curl http://$IP_tenant1
curl http://$IP_tenant2
```

The output should be similar to:

```html
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.21.5</center>
</body>
</html>
```

### Step 3. Deploy services for each tenant

1. Deploy demo applications in each tenant
```
kubectl apply -f  ~/oltra/setup/apps/apps.yml -n tenant1
kubectl apply -f  ~/oltra/setup/apps/apps.yml -n tenant2
```

2. Deploy Ingress services for each tenant
```yml
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-tentant1
  namespace: tenant1
spec:
  ingressClassName: nginx-tenant1
  rules:
  - host: tenant1.f5demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-svc
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-tentant2
  namespace: tenant2
spec:
  ingressClassName: nginx-tenant2
  rules:
  - host: tenant2.f5demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-svc
            port:
              number: 80
EOF
```


3. Access the services for both tenants as per the example below. 
```
curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2
```


### Step 4. (Optional) Grafana Dashboards 

1. Setup scraping for the new NGINX instances
```yml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx-metrics-tenant1
  namespace: tenant1
  labels:
    type: nginx-metrics
spec:
  ports:
  - port: 9113
    protocol: TCP
    targetPort: 9113
    name: prometheus
  selector:
    app: nginx-tenant1
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-metrics-tenant2
  namespace: tenant2
  labels:
    type: nginx-metrics
spec:
  ports:
  - port: 9113
    protocol: TCP
    targetPort: 9113
    name: prometheus
  selector:
    app: nginx-tenant2
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nginx-metrics
  namespace: monitoring
  labels:
    type: nginx-plus
spec:
  selector:
    matchLabels:
      type: nginx-metrics
  namespaceSelector:
    matchNames:
    - nginx
    - tenant1
    - tenant2
  endpoints:
  - interval: 30s
    path: /metrics
    port: prometheus
EOF
```

2. Login to Grafana. On the UDF you can acess Grafana from BIGIP "Access" methods as per the image below.

<p align="left">
  <img src="images/grafana.png" style="width:35%">
</p>

Login to Grafana (credentials **admin/IngressLab123**)
<p align="left">
  <img src="images/login.png" style="width:50%">
</p>


Go to **Dashboards->Browse**

<p align="left">
  <img src="images/browse.png" style="width:22%">
</p>


Select any of the 2 Ingress Dashboards (NGINX Ingress / NGINX Ingress Details) which can be found on NGINX Folder

<p align="left">
  <img src="images/dashboards.png" style="width:40%">
</p>



2. Run the following script to generate traffic and review the Grafana Dashboards per tenant
```cmd
for i in {1..500} ; do curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1; \
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2;  \
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1; \
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2; \
done
```

**Ingress Dashboard**

<p align="left">
  <img src="images/ingress.png" style="width:90%">
</p>

**Ingress Dashboard Details**

<p align="left">
  <img src="images/ingress-details.png" style="width:90%">
</p>