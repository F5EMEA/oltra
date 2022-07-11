# Multi-tenant Ingress services

In this use-case we go through how we can build a multi-tenant kubernetes cluster from the ingress and load balancing perpective. This includes clusters shared by different users at a single organization or clusters that are shared by different orginizations.

A multi-tenant cluster is shared by multiple users and/or workloads which are referred to as "tenants". The operators of multi-tenant clusters must isolate tenants from each other to minimize the damage that a compromised or malicious tenant can do to the cluster and other tenants.

## Ingress multi-tenancy requirements
Typically the requirement of a multi-tenat K8s environments in terms of Ingress/Load-Balancing are the following:
1. Each tenant should be able to manage their own Ingress Resources.
2. Ingress Resources of one tenant shouldn't not affect/interfere with another tenant's even if they are using the same FQDNs.
3. Performance degradation of the Ingress Controller (IC) on one tenant (due to usage/attacks/misconfiguration) shouldn't affect the performance of the IC on another tenant.
4. Each Tenant should be able to publish their ingress services outside the kubernetes cluster.
5. Each Tenant Load Balancing IPs should be different and must be assigned automatically.
6. Each Tenant should have a different Network IP address(es) to differentiate them and being able to apply different network policies outside the K8s cluster. 


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
| VirtualServer CRD | With VS CRD you can enable multiple functionalities such as **reverse proxy**, **DDoS**, **BoT mitigation**, **SSL offloading**, **HTTP/HTTP2 profiles**, **L4/7 iRules**, **WAF policies**, **SNAT pools** , **Cookie/IP Persistence**, **EDNS** |
| TransportServer CRD |  With TS CRD you can enable primarily L4 functionalities such as **reverse proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP Persistence** |
| Service Type LB | With service type LB you can enable primarily L4 functionalities like TS CRD such as **reverse proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP persistence** |


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
kubectl create namespace tenant-1
kubectl create namespace tenant-2
```

### Step 2. Deploy NGINX+ Ingress Controller

For each tenant deploy a seperate NGINX+ Ingress Controller. 

```
kubectl apply -f ~oltra/setup/2-Deploy-plus/1-Nginx-RBAC/ns-and-sa.yaml -n tenant-1
kubectl apply -f ~oltra/setup/2-Deploy-plus/1-Nginx-RBAC/ns-and-sa.yaml -n tenant-2

kubectl apply -f ~oltra/setup/2-Deploy-plus/1-Nginx-RBAC/role-bnding.yaml -n tenant-2
kubectl apply -f ~oltra/setup/2-Deploy-plus/1-Nginx-RBAC/role-bnding.yaml -n tenant-2

```

Verify that the NGINX pods are up and running on each tenant 
```
kubectl get pods -n customer-a -n cudstomer-b
....




```

### Step 3. BIGIP CIS / IPAM 

CIS and IPAM are already setup and running on the K8s cluster.
```
$ kubectl get po -n kube-sytem | grep f5
```

Verify that IPAM labels are configured for both Customer-A and Customer-B
```
$ kubectl describe deployment f5-ipam -n kube-sytem

....

```

### Step 4. Publish Ingress Controller

In this step we will publish the NGINX IC by creating a CIS CRD (TransportServer) on each namespace. An example of such CRD can be found below.
```yaml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: nginx-customer-a
  namespace: customer-a
spec:
  ipamLabel: "customer-a"
  virtualServerPort: 80
  virtualServerName: nginx-customer-a
  mode: standard
  snat: auto
  pool:
    service: nginx-svc
    servicePort: 80
    monitor:
      type: tcp
      interval: 3
      timeout: 10
```

Deploy CIS Transport Server CRDs

```
$ kubectl apply -f ts_crds.yaml
```

Verify that CRDs have been deployed successuly.


Send a 


### Step 5. Deploy applications

For each tenant deploy 2 demo applications

```
$ kubectl apply -f apps.yaml
```

Publish the applications through Ingress under different FQDNs.

```
$ kubectl apply -f nginx_tenants.yaml
```

Try and access these services.



### Step 6. Dashboards


### Step 7. Remove environment
