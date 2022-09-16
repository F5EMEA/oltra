#  TransportServer CRD
In this section we provide examples for the most common use-cases of TransportServer CRDs with F5 CIS.
- [TCP TransportServer](#tcp-transport-server)
- [TCP TransportServer with IPAM](#tcp-transport-server-with-ipam)
- [UDP TransportServer](#udp-transport-server)


## TCP Transport Server
This section demonstrates the deployment of a TCP TransportServer CRD.

Eg: tcp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: tcp-ts
spec:
  virtualServerAddress: "10.1.10.74"
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
Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Change the working directory to `TransportServer`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/TransportServer
```

Create the TS CRD resource. 
```
kubectl apply -f tcp-transport-server.yml
```
>Note: CIS will create a L4 Virtual Server on BIG-IP with VIP "10.1.10.74" and the service `myapp-svc` as the pool. 

Confirm that the TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts tcp-ts
```

Access the service as per the examples below. 
```
curl http://10.1.10.74
```

The output should be similar to:
```
Server address: 10.244.140.103:8080
Server name: myapp-6cc75dfc85-qhk5d
Date: 14/Jul/2022:06:17:19 +0000
URI: /
Request ID: 18c2b70bcca18c590a0125db04be5661
```

***Clean up the environment (Optional)***
```
kubectl delete -f tcp-transport-server.yml
```

## TCP Transport Server with IPAM

This section demonstrates the deployment of a TCP Transport Server with ipamLabel

Eg: tcp-transport-server-ipamLabel.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: tcp-ipam-ts
spec:
  ipamLabel: "dev"
  virtualServerPort: 80
  virtualServerName: tcp-ipam-ts
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

Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Change the working directory to `TransportServer`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/TransportServer
```

Create the TS CRD resources. 
```
kubectl apply -f tcp-transport-server-ipamLabel.yml
```

Confirm that TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts tcp-ipam-ts
```

Save the IP adresses that was assigned by the IPAM for this TS
```
IP=$(kubectl get ts tcp-ipam-ts --template '{{.status.vsAddress}}')
```

Try accessing the service as per the example below. 
```
curl http://$IP/
```

The output should be similar to:
```
Server address: 10.244.196.189:8080
Server name: myapp-6cc75dfc85-msntl
Date: 14/Jul/2022:06:22:38 +0000
URI: /
Request ID: 705dca97504efb7adba9c6fbd4309605
```

***Clean up the environment (Optional)***
```
kubectl delete -f tcp-transport-server-ipamLabel.yml
```
## UDP Transport Server

This section demonstrates the deployment of a UDP Transport Server (Deploying coreDNS server)

Eg: udp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: udp-transport-server
  namespace: default
spec:
  virtualServerAddress: "10.1.10.75"
  virtualServerPort: 53
  virtualServerName: svc-udp-ts
  type: udp
  mode: standard
  snat: auto
  pool:
    service: coredns
    servicePort: 5353
```

Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Change the working directory to `TransportServer`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/TransportServer
```

Create the TS CRD resources. 
```
kubectl apply -f udp-transport-server.yml
```

Confirm that TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts udp-transport-server
```

Try accessing any DNS service on the internet like `www.example.com` through the Transport Server VIP (`10.1.10.75`)
```
dig @10.1.10.75 www.example.com
```

The output should be similar to:
```
; <<>> DiG 9.11.3-1ubuntu1.13-Ubuntu <<>> @10.1.10.75 www.example.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62205
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.example.com.               IN      A

;; ANSWER SECTION:
www.example.com.        14244   IN      A       93.184.216.34

;; Query time: 4 msec
;; SERVER: 10.1.10.75#53(10.1.10.75)        <================ DNS Server
;; WHEN: Thu Jul 14 06:38:20 UTC 2022
;; MSG SIZE  rcvd: 75
```

> Note that the response comes from 10.1.10.75 which is the Transport Server IP

***Clean up the environment (Optional)***
```
kubectl delete -f udp-transport-server.yml
```
