# Multi-cluster strategies
Today, organizations are increasingly deploying more Kubernetes clusters and are implementing multi-cluster strategies in an effort to improve availability, scalability and isolation. Multi-cluster strategy is achieved by deploying an application on multiple Kubernetes clusters. This can be architected with two fundamental ways; 
  - Global Server Load Balancing (DNS) 
  - Local Load Balancing (LTM) 

Although both ways can help an organization achieve multi-clustering, they have quite few differences on the capabilities of these two methods. **Global Server Load Balancing** is relying on the DNS protocol to direct the user to the Kubernetes cluster according to the GSLB distribution algorithm by resolving a DNS name to an IP address. **Local Load Balancing** is based on the typical reverse proxy functionality that the load balancer (BIGIP) will terminate the client's connection and distribute the traffic across a group of backend Kubernetes clusters. 


## LTM
For LTM multi-cluster, we rely on GitOps deployment to provide such funcitonality. With GitOps the user needs to create are the parameters of the service they want to publish (YAML format) and save them to the file. An example of such file is shown below.
```yml
config: 
  - name: www.f5demo.cloud
    vip: 10.1.1.214
    port: 80
    template: http 
    monitor: http
    cluster:
    - cluster_name: primary
      nodeport: 33002
      ratio: 9
    - cluster_name: secondary
      nodeport: 33002
      ratio: 1
```
Once the file is created/modified on a Git repository we are using a CI/CD pipeline to automatically create the Virtual Server on the BIGIP and start load balancing services for multiple Kubernetes clusters. 

Details and demo on this scenario can be found on [**GitOps**](https://github.com/F5EMEA/oltra/blob/main/use-cases/gitops/) use case. 

***LTM*** multi-cluster method is recommended when 
- Advanced Load Balancing conditions/logic is required (Ratio, HTTP Headers, Geolocation, etc).
- DNS Load Balancing is not possible due to TTL caching or other application related constrain.  


## DNS
DNS multi-clustering is achieved with the use of CIS [**ExternalDNS CRD**](https://clouddocs.f5.com/containers/latest/userguide/crd/externaldns.html). ExternalDNS role is to create WideIPs on F5 BIGIP DNS platform that will load balance the DNS traffic to the BIGIP Virtual Servers that publish the Kubernetes resources (Ingress Controller). 

<p align="center">
  <img src="multi-cluster-gslb.png" style="width:80%">
</p>


### How does it work
DNS multi-clustering is a two step process. **First** we create a Custom Resource of type VirtualServer, TransportServer or IngressLink that contain the Hostname (FQDN) of the service we want to load balance. 
```yml
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: sample-virtual
spec:
  host: www.f5demo.cloud       <==== Hostname (FQDN)
  virtualServerAddress: 10.1.10.240
  pools:
  - monitor:
      interval: 20
      recv: ""
      send: /
      timeout: 10
      type: http
    path: /
    service: svc-1
    servicePort: 80
```
An **ExternalDNS** Custom Resource must be created that will have the same hostname as with Custom Resource (VS/TS/IL) we created earlier.
```yml
apiVersion: "cis.f5.com/v1"
kind: ExternalDNS
metadata:
  name: exdns
  labels:
    f5cr: "true"
spec:
  domainName: www.f5demo.cloud     <==== Hostname matches with pervious CR
  dnsRecordType: A
  loadBalanceMethod: round-robin
  pools:
  - name: www-primary-k8s
    dnsRecordType: A
    loadBalanceMethod: round-robin
    dataServerName: /Common/GSLBServer
    monitor:
      type: https
      send: "GET /"
      recv: ""
      interval: 10
      timeout: 10
```

> **Note:** The Host parameter can be configured to be either explicit or wildcard (*.f5demo.cloud)

DNS multi-cluster provides the following functionalities: 

- **Active-Active Applications.** EDNS can be configured to load balance equally (Round Robin) services running in different clusters.

- **Active-Standby Applications.** EDNS can be configured to have order preference between the services running in different clusters.

- **Health Monitoring.** EDNS provides real-time health monitoring of the services (via HTTP/HTTPS/TCP probes) so that the user is always sent to the Kubernetes cluster that the application is available/operational. 
> **(Important) Note:** Since the application runs behind NGINX+ Ingress Controller, it is recommened to have liveness probes configured on the K8s deployments so that NGINX+ removes the services when they are facing health issues and that the timeout/frequency on the EDNS is bigger than the one on liveness probes.

- **Distributed environments.** Given the fact that EDNS relies on DNS, it can accomodates Kuberentes clusters that are deployed across different datacenters.


### DNS Demo

Ideally for the multi-cluster demo we would need 2 K8s clusters and 2 BIGIP, one BIGIP for each cluster. Due to the fact that we have 1 BIGIP and 1 K8s cluster in our environment we will simulate mutli-cluster environment by deployhing the same application on 2 Namespaces, deploy 2 CIS instances that monitor these namespaces and both CIS instances will update the same BIGIP DNS.

IMAGE



### Step 1. Create Tentants

Create the 2 namespaces. Each namespace will represent a different cluster
```
kubectl create namespace cluster1
kubectl create namespace cluster2
```

### Step 2. Deploy NGINX+ Ingress Controller

For each namespace (cluster) we will deploy a seperate NGINX+ Ingress Controller. 

1. Change the working directory to `multi-cluster`.
```
cd ~/oltra/use-cases/two-tier-architectures/multi-cluster
```

2. Copy the NGINX plus deployment from the setup folder
```
cd ~/oltra/use-cases/two-tier-architectures/multi-cluster
mkdir nginx_t1
mkdir nginx_t2
cp -R ~/oltra/setup/nginx-ic/* nginx_t1
cp -R ~/oltra/setup/nginx-ic/* nginx_t2
```

3. Replace the namespace `nginx` with `cluster1` and `cluster2` for the required manifests
```
./rename.sh
```

4. Deploy NGNINX+ IC for each namespace (cluster).
```
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t1/rbac
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t2/rbac
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t1/resources
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t2/resources
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t1/nginx-plus
kubectl apply -f ~/oltra/use-cases/two-tier-architectures/multi-cluster/nginx_t2/nginx-plus
```

5. Verify that the NGINX pods are up and running on both namespaces

```
kubectl get pods -n cluster1
kubectl get pods -n cluster2
```
```
####################################      Expected Output   ######################################
NAME                            READY   STATUS    RESTARTS   AGE
nginx-cluster1-74fd9b786-hqm6k   1/1     Running   0          22s
##################################################################################################
```

6. Scale down to 0 the existing CIS instance. 
```
```
> Note: We do that since the existing CIS listens across all Namespace. In this case we will create a conflict of multiple CIS configuring BIGP for the same CRD but on different partitions. 
 
7. Deploy 2 new CIS instances. One will manage namespace `cluster1` and the other will manage namespace `cluster2` 
```
cp /Users/K.Skenderidis/Documents/GitHub/oltra/setup/cis/cis/cis-ctlr-crd.yml cis-cluster1.yml
cp /Users/K.Skenderidis/Documents/GitHub/oltra/setup/cis/cis/cis-ctlr-crd.yml cis-cluster2.yml
sed '3 i New Line with sed' File1
sed '3 i New Line with sed' File1
sed '3 i New Line with sed' File1
sed '3 i New Line with sed' File1
sed '3 i New Line with sed' File1
sed '3 i New Line with sed' File1
kubectl apply -f cis-cluster1.yml
kubectl apply -f cis-cluster2.yml

```

8. Deploy


5. Deploy TS 

```
kubectl xxxxxxx
kubectl xxxxxx
```

6. Save the IP adresses that was assigned by the IPAM for each tenant NGINX services
```
IP_cluster1=$(kubectl get svc nginx-cluster1 -n cluster1 --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
IP_cluster2=$(kubectl get svc nginx-cluster2 -n cluster2 --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```
IP=$(kubectl get svc svc-lb-ipam --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')


7. Create EDNS for cluster1 and cluster2
```

```

8. DIG commands



8. Try accessing the service as per the example below. 
```
curl http://$IP_cluster1
curl http://$IP_cluster2
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
```
kubectl apply -f ingress.yml
```


3. Access the services for both tenants as per the example below. 
```
curl http://tenant1.f5demo.local/ --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/ --resolve tenant2.f5demo.local:80:$IP_tenant2
curl http://tenant1.f5demo.local/app2 --resolve tenant1.f5demo.local:80:$IP_tenant1
curl http://tenant2.f5demo.local/app2 --resolve tenant2.f5demo.local:80:$IP_tenant2
```



