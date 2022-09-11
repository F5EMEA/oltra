# Security on the Edge
DevOps teams need to integrate security controls like WAF or DDoS that are authorized/maintained by the security team without slowing release velocity or performance. In this use-case we will focus on how we can deploy multiple applications behind NGINX+ Ingress Controller and publish each one with a seperate WAF/DDoS Policy.

## Requirements
The usual requirements for such an environments are the following:
* DevOps team should be able to control the process of publishing resources.
* The process should happen in a Kubernetes-native way.
* DevOps teams shouldn’t have to manage the external IPs on BIGIP
* WAF/DDoS policies need to be applied on the applications that are getting published.
* While the main service that should be exposed is the NGINX+ Ingress Controller, DevOps teams might require also to expose TCP/UDP apps without going through the Ingress Controller.
* Multiple NGINX+ IC groups running per Kubernetes cluster.
* The design should be scalable to multiple Kubernetes clusters


## Proposed Architecture

<p align="center">
  <img src="layer7-tcp.png">
</p>

Having a single, standardized approach that runs everywhere Kubernetes runs, ensures that configurations are applied consistently, across all environments. This is one of the many benefits that **Kubernetes-native** configuration provides.

BIGIP can be configured in a kubernetes-native manner though the use of <a href="https://clouddocs.f5.com/containers/latest/userguide/what-is.html">CIS controller</a>. Altough CIS has multiple modes of operation (Ingress, Routes, CRDs, Configmaps) the most relevant for our use case are VirtualServer CRD and TransportServer CRDs and Service Type LoadBalancer. 

| Type | Functionality |
|---|---|
| VirtualServer | With VirtualServer Custom Resource you can forward all traffic to your service through a L7 Virtual Server on BIGIP. It provides functionalities such as **Reverse Proxy**, **DDoS**, **BoT protection**, **SSL offloading**, **HTTP2**, **OneConnect**, **iRules**, **WAF**, **SNAT** , **Cookie/IP Persistence** and **EDNS**. <br> It works with and without **IPAM** controller. <br> Examples on VirtualServer CRD can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#virtualserver-crd-examples">here</a> |
| TransportServer |  With TransportServer Custom Resource you can forward all traffic to your service through a L4 Virtual Server on BIGIP. It provides functionalities such as **Reverse Proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP Persistence**.<br> It works with and without the **IPAM** controller.<br> Examples on TransportServer can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#transportserver-crd-examples">here</a> |
| Service Type LB | Services of type LoadBalancer are natively supported in Kubernetes deployments. When you create a service of type LoadBalancer it spins up service in integration with F5 IPAM Controller which allocates an IP address that will forward all traffic to your service through a L4 Virtual Server on BIGIP. It provides functionalities such as **Reverse Proxy**,  **L4 DDoS**, **L4 iRules**, **SNAT pools**, **IP persistence**.<br> It works only with **IPAM** controller.<br> Examples on Service Type LB can be found <a href="https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/README.md#service-type-loadbalancer-examples">here</a> |

**VirtualServer** is the only option for publishing NGINX Ingress Controller since in this use case we need to attach WAF and/or DDoS profiles to the published services. VirtualServer Custom Resource creates a Layer 7 Virtual server on BIGIP and by using the Policy CRD it can attach pre-configured WAF, DDoS profile on the same BIGIP Virtual Server. 
If we want to have separate WAF/DDoS profiles per Hostname, then we would need to create separate multiple VirtualServer CRs, each with a different profile attached.  

### SSL Decryption
In order for BIGIP to be able to apply the WAF/DDoS policies on the traffic going through the Virtual Server, it needs first to decrypt the SSL. Therefore the SSL decoding will take place on BIGIP.
The SSL certificates can either be configured manually on BIGIP and referenced on VS CRD or they can be configured automatically through CIS from Kubernetes secrets. Examples on how to configure VirtualServer CR with TLS can be found <a href="https://github.com/F5EMEA/oltra/tree/multi-cluster/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination">here</a>

**TransportServer** and **Service Type LB** are recommended methods to publish either TCP or UDP applications, since both provide Layer 4 Load Balancing and provide IPAM functionality.


## Demo 
In the following section we will demontrate how we can implement the above architecture. We will be using VirtualServer to publish both NGINX+ IC and Service Type LB for a UDP application (CoreDNS). Behind NGINX+ we will be deploying 3 different applications with different WAF/DDoS setting on each:
- www.f5demo.local **(WAF only)**
- app1.f5demo.local **(WAF and DDOS)**
- app2.f5demo.local **(No WAF and No DDoS)**


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


