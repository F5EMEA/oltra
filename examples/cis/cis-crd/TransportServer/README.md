# Unsecured Transport Server

This section demonstrates the deployment of Transport Servers.
User may able to expose L4 services (TCP or UDP) via CIS using Transport Server CRD.

## TCP Transport Server

This section demonstrates the deployment of a TCP Transport Server.

Eg: tcp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: tcp-ts
spec:
  virtualServerAddress: "10.1.10.111"
  virtualServerPort: 80
  virtualServerName: tcp-ts
  mode: standard
  snat: auto
  pool:
    service: myapp-svc
    servicePort: 8080
    monitor:
      type: tcp
      interval: 3
      timeout: 10
```

Create the TS CRD resource. 
```
kubectl apply -f tcp-transport-server.yml
```

CIS will create a L4 Virtual Server on BIG-IP with VIP "10.1.10.111" and service `myapp-svc` as the pool


Confirm that the TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts 
```

Access the service as per the examples below. 

```
curl http://10.1.10.111 
```



## TCP Transport Server with IPAM

This section demonstrates the deployment of a TCP Transport Server with ipamLabel

Eg: tcp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: tcp-ts
spec:
  virtualServerAddress: "10.1.10.111"
  virtualServerPort: 80
  virtualServerName: tcp-ts
  mode: standard
  snat: auto
  pool:
    service: myapp-svc
    servicePort: 8080
    monitor:
      type: tcp
      interval: 3
      timeout: 10
```


Create the TS CRD resources. 
```
kubectl apply -f tcp-transport-server-ipamLabel.yml
```

Confirm that TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get vs 
```
Save the IP adresses that was assigned by the IPAM for this TS

Try accessing the service as per the example below. 
```
curl http://<IP Address assigned by IPAM>/
```



## UDP Transport Server

This section demonstrates the deployment of a UDP Transport Server

Eg: udp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: svc1-udp-transport-server
  namespace: default
spec:
  virtualServerAddress: "10.1.10.112"
  virtualServerPort: 8444
  virtualServerName: svc1-udp-ts
  type: udp
  mode: standard
  snat: auto
  pool:
    service: udp-svc
    servicePort: 8182
```