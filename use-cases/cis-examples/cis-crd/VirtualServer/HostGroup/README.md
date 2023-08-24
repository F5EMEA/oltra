# Virtual Server with Host Group (Host Based Routing)

The `HostGroup` feature allows CIS to support Host based routing. This is similar to how Ingress Resources operate. The benefit of using the `HostGroup` feature is the ability to reuse the same IP Address on BIG-IP.
You can configure VirtualServer CRD using the `HostGroup` parameter to club multiple VirtualServer CRD with different hostnames into a single BIG-IP VirtualServer.

We provide the following 2 examples for the `HostGroup` feature: 
- [HTTP Virtual Server with Host Based Routing](#http-virtual-server-with-host-based-routing)
- [HTTP Virtual Server with Host Based Routing and IPAM](#http-virtual-server-with-host-based-routing-and-ipam)

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

## HTTP Virtual Server with Host Based Routing

This section demonstrates the `HostGroup` feature with two VirtualServer CRDs.

Eg: virtual-with-hostGroup.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: hg1-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: hg1.f5k8s.net
  virtualServerName: "hostgroup-vs"
  virtualServerAddress: "10.1.10.59"
  hostGroup: "apps"
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
---
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: hg1-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: hg2.f5k8s.net
  virtualServerName: "hostgroup-vs"
  virtualServerAddress: "10.1.10.59"
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080

```
By deploying the above 2 VirtualServer CRDs in your cluster, CIS will create a single HTTP Virtual Server (with VIP `10.1.10.59`) on the BIG-IP system with a Policy that routes based on the hostname (in this example, `hg1.f5k8s.net` and `hg2.f5k8s.net`). This is because both VS CRDs share the same hostGroup property.



Change the working directory to `HostGroup`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/HostGroup
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the VirtualServer resources.
```
kubectl apply -f virtual-with-hostGroup.yml
```

Confirm that both VirtualServer resources are deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

Expected output 
```
NAME               HOST            TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS    IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
hg1-hostgroup-vs   hg1.f5k8s.net                                  10.1.10.59               10.1.10.59      Ok       10s
hg2-hostgroup-vs   hg2.f5k8s.net                                  10.1.10.59               10.1.10.59      Ok       10s
```


Try accessing the service as per the example below. 
```
curl http://hg1.f5k8s.net/ 
curl http://hg2.f5k8s.net/

```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname.  The output should be similar to:
```
Server address: 10.244.140.116:8080
Server name: app2-78c95bccb5-jvfnr
Date: 12/Jul/2022:07:21:49 +0000
URI: /                                        <======== URI Path
Request ID: a5b08e8249b65a11aaaacd307feeca8e  
```

***Clean up the environment (Optional)***
```
kubectl delete -f virtual-with-hostGroup.yml
```

## HTTP Virtual Server with Host Based Routing and IPAM

In this example we are using again hostGroup to club Virtual Servers together but we are using `ipamLabel` insted of `virtualServerAddress` in order to create a VirtualServer IP.

Eg: virtual-with-hostGroup-ipam.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: ipam1-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: ipam1-hg.f5k8s.net
  ipamLabel: "dev"
  virtualServerName: "hostgroup-ipam-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
---
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: ipam2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: ipam2-hg.f5k8s.net
  ipamLabel: "dev"
  virtualServerName: "hostgroup-ipam-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080
```
Change the working directory to `HostGroup`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/HostGroup
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.


Create the VirtualServer resources. 
```
kubectl apply -f virtual-with-hostGroup-ipam.yml
```

Confirm that both VirtualServer resources are deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 

################################################   Expected Output  ################################################
NAME                  HOST                  TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS    IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
ipam1-hostgroup-vs    ipam-hg1.f5k8s.net                                                dev         None            Ok       9s
ipam2-hostgroup-vs    ipam-hg2.f5k8s.net                                                dev         None            Ok       9s
####################################################################################################################
```

Save the IP adresses that was assigned by the IPAM for this VirtualServer
```
IP=$(kubectl get f5-vs ipam1-hostgroup-vs --output=jsonpath='{.status.vsAddress}')
```

Try accessing the serviceas per the examples below. 
```
curl http://ipam-hg1.f5k8s.net/ --resolve ipam-hg1.f5k8s.net:80:$IP
curl http://ipam-hg2.f5k8s.net/ --resolve ipam-hg2.f5k8s.net:80:$IP
```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname. The output should be similar to:
```
Server address: 10.244.140.116:8080
Server name: app2-78c95bccb5-jvfnr
Date: 12/Jul/2022:07:21:49 +0000
URI: /                                        <======== URI Path
Request ID: a5b08e8249b65a11aaaacd307feeca8e  
```

***Clean up the environment (Optional)***
```
kubectl delete -f virtual-with-hostGroup-ipam.yml
```