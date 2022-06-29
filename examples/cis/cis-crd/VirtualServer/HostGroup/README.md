# Virtual Server with Host Group (Host Based Routing)

The `HostGroup` feature allows CIS to support Host based routing. This is similar to how Ingress Resources operate. The benefit of using the `HostGroup` feature is the ability to reuse the same IP Address on BIG-IP.
You can configure VirtualServer CRD using the `HostGroup` parameter to club multiple VirtualServer CRD with different hostnames into a single BIG-IP VirtualServer.

We provide the following 2 examples for the `HostGroup` feature: 
- [HTTP Virtual Server with Host Based Routing](#http-virtual-server-with-host-based-routing)
- [HTTP Virtual Server with Host Based Routing and IPAM](#http-virtual-server-with-host-based-routing-and-ipam)


## HTTP Virtual Server with Host Based Routing

This section demonstrates the `HostGroup` feature with two VirtualServer CRDs.

Eg: virtual-with-hostGroup.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: app2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: app1.f5demo.local
  virtualServerAddress: "10.1.10.100"
  virtualServerName: "hostgroup-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
---
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: app2-hostgroup-vs
  labels:
    f5cr: "true"
spec:
  host: app2.f5demo.local
  virtualServerAddress: "10.1.10.100"
  virtualServerName: "hostgroup-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080

```
By deploying the above 2 VirtualServer CRDs in your cluster, CIS will create a single HTTP Virtual Server (with VIP `10.1.10.100`) on the BIG-IP system with different hostnames (in this example, `app1.f5demo.local` and `app2.f5demo.local`) since both VS CRDs share the same hostGroup property.

Create the VS CRD resources. 
```
kubectl apply -f virtual-with-hostGroup.yml
```

Confirm that both VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service as per the example below. 
```
curl http://test.f5demo.local/ --resolve test.f5demo.local:80:10.1.10.100

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl http://app1.f5demo.local/ --resolve app1.f5demo.local:80:10.1.10.100
curl http://app2.f5demo.local/ --resolve app2.f5demo.local:80:10.1.10.100

```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname.


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
  host: ipam1.f5demo.local
  ipamLabel: "Dev"
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
  host: ipam2.f5demo.local
  ipamLabel: "Dev"
  virtualServerName: "hostgroup-ipam-vs"  
  hostGroup: "apps"
  pools:
    - path: /
      service: app2-svc
      servicePort: 8080
```


Create the VS CRD resources. 
```
kubectl apply -f virtual-with-hostGroup-ipam.yml
```

Confirm that both VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Save the IP adresses that was assigned by the IPAM for this VirtualServer
```
IP=$(kubectl get vs ipam1-hostgroup-vs --template '{{.status.vsAddress}}')
```

Try accessing the serviceas per the examples below. 
```
curl http://ipam1.f5demo.local/ --resolve ipam1.f5demo.local:80:$IP
curl http://ipam2.f5demo.local/ --resolve ipam2.f5demo.local:80:$IP
```

Verify that the traffic was forwarded to the `app1-svc` and `app2-svc` services as per the Hostname.

