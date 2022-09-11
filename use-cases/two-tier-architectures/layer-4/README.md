# Layer 4 Deployments
One of the most common deployments in regards to the external load balancer is Layer 4. The main requirement in this case is to provide L4 connectivity between the external environment and the Ingress Controller running inside Kubernetes. The typical customer environmnet will contain mutliple Ingress Controllers for different environments such as Production, UAT and Demo and probably multiple Kubernetes clusters. 

## Requirements
The usual requirements for such an environments are the following:
* DevOps teams should be able to control the process of publishing resources.
* The process should happen in a Kubernetes-native way.
* DevOps teams shouldn’t have to manage the external IPs on BIGIP.
* SSL termination should take place on Kubernetes Ingress Controller.
* While the main service that should be exposed is the NGINX+ Ingress Controller, DevOps teams might require also to expose TCP/UDP apps without going through the Ingress Controller.
* Multiple NGINX+ IC running per Kubernetes cluster.
* The design should be scalable to multiple Kubernetes clusters

## Proposed Architecture

<p align="center">
  <img src="layer4-tcp.png">
</p>

Having a single, standardized approach that runs everywhere Kubernetes runs, ensures that configurations are applied consistently, across all environments. This is one of the many benefits that **Kubernetes-native** configuration provides.

BIGIP can be configured in a kubernetes-native way though the use of <a href="https://clouddocs.f5.com/containers/latest/userguide/what-is.html">CIS controller</a>. Altough CIS has multiple modes of operation (Ingress, Routes, CRDs, Configmaps) the 3 most relevant for our use case are IngressLink and TransportServer and Service Type LoadBalancer. 

| Type | Functionality |
|---|---|
| TransportServer |  With TransportServer Custom Resource you can forward all traffic to your service through a L4 Virtual Server on BIGIP. It provides functionalities such as **Reverse Proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP Persistence**.<br> It works with and without the **IPAM** controller.<br> Examples on TransportServer can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#transportserver-crd-examples">here</a> |
| Service Type LB | Services of type LoadBalancer are natively supported in Kubernetes deployments. When you create a service of type LoadBalancer it spins up service in integration with F5 IPAM Controller which allocates an IP address that will forward all traffic to your service through a L4 Virtual Server on BIGIP. It provides functionalities such as **Reverse Proxy**,  **L4 DDoS**, **iRules**, **SNAT**, **IP persistence** and **EDNS**.<br> It works only with **IPAM** controller.<br> Examples on Service Type LB can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#service-type-loadbalancer-examples">here</a> |
| IngressLink | IngressLink Custom Resource is a dedicated CRD for integrating BIGIP with NGINX Ingress Controller. The integration is acheved through a Layer 4 Virtual Server on BIGIP that forwards all traffic to NGINX Ingress Controller. <br> It works with or without **IPAM** controller. <br> Examples on IngressLink can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#ingresslink-examples">here</a> |

**IngressLink** and **Service Type LB** are the recommended methods for publishing NGINX Ingress Controller in our use case. Both methods provide Layer 4 Load Balancing from BIGIP to NGINX+ IC instances and therefore do not terminate SSL and both support IPAM so that IPs are not managed by the DevOps teams.

An intresting feature is that both methods can populate the Ingress resource Address information with the external IP that has been configured on BIGIP. To achieve this integration we need to enable the correct arguments on NGINX Ingress Controller deployment. These arguments are:
- "-ingresslink" for Ingresslink deployments
- "-external-service" for Type LB deployments

<p align="center">
  <img src="ingresses.png">
</p>

More information on how to configure those arguments can be found on the link https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/command-line-arguments/

**TransportServer** and **Service Type LB** are recommended methods to publish either TCP or UDP applications, since both provide Layer 4 Load Balancing and provide IPAM functionality.

> **Why select ServiceType LB?**
> - Easier deployment since it doesn;t require additional resources (TS CRD).
> - Makes the code portable to cloud environments that support ServiceType LB

> **Why select TransportServer (TS) or IngressLink instead?**
> - If you want to use a static IP address on the BIGIP
> - If, for RBAC purposes, you need to control the publishing of a service, then having a separate resource such as TransportServer or IngressLink can help you apply different clusterroles to them and therefore control who has access to the resource.


## Demo 
In the following section we will demontrate how we can implement the above architecture. We will be using ServiceType LB to publish both NGINX+ IC and a UDP application (CoreDNS). Behind NGINX+ we will be deploying 3 different applications:
- www.f5demo.local
- app1.f5demo.local
- app2.f5demo.local

### Step 1. Verify NGINX+ and CIS are already running

Run the following command to verify NGINX+ is running
```
kubectl create namespace layer4
```

Run the following command to verify CIS is running
```
kubectl create namespace layer4
```


### Step 2. Deploy services behind NGINX+ IC.

1. Deploy demo applications
```
kubectl apply -f  ~/oltra/setup/apps/apps.yml -n tenant2
```


### Step 3. Publish NGINX+ on with a Service Type LB


3. Access the services for both tenants as per the example below. 
```
curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2
```


### Step 4. Publish the UDP application with a TransportServer


3. Access the services for both tenants as per the example below. 
```
curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2
```


### Step 5. Publish the UDP application though NGINX+


3. Access the services for both tenants as per the example below. 
```
curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2
```


