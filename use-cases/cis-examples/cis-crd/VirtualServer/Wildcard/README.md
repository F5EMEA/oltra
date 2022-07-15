# Virtual Server with Wildcard Domain

This section demonstrates the options to configure virtual server using Wildcard Hostname parameter for both HTTP and HTTPS.

 - [HTTP Virtual Server with wildcard Host parameter](#http-virtual-server-with-wildcard-host-parameter)
 - [HTTPS Virtual Server with wildcard Host parameter](#https-virtual-server-with-wildcard-host-parameter)

## HTTP Virtual Server with wildcard Host parameter

This section demonstrates the deployment of a **HTTP** Virtual Server with wildcard Host parameter.
The virtual server should send traffic to the backend service if the Host Header matches the wildcard value configured on the Host parameter.

Eg: wildcardhost-vs.yml

```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: wildcard-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.72"
  host: "*.f5demo.local"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```
Change the working directory to `Wildcard`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/Wildcard
```

Create the VS CRD resource. 
```
kubectl apply -f wildcardhost-vs.yml
```

CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.72` and attach a policy that forwards traffic to service `echo-svc` if the Host Header matches `*.f5demo.local`.   

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs wildcard-vs
```

Try accessing the service with curl as per the examples below. 
```
curl http://test.example.local/ --resolve test.example.local:80:10.1.10.72

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl http://test1.f5demo.local/ --resolve test1.f5demo.local:80:10.1.10.72
curl http://test2.f5demo.local/ --resolve test2.f5demo.local:80:10.1.10.72
...
...
curl http://test10.f5demo.local/ --resolve test10.f5demo.local:80:10.1.10.72

```

Verify that you traffic was forwarded to the `echo-svc` service on both tests. The output should be similar to:
```cmd
{
    "Server Name": "test1.f5demo.local",
    "Server Address": "10.244.140.78",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"host":"test1.f5demo.local","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "60184",
    "Timestamp": "1657635755",
    "Data": "0"
}
```

## HTTPS Virtual Server with wildcard Host parameter

This section demonstrates the deployment of a **HTTPS** Virtual Server with wildcard Host parameter.
The virtual server should send traffic to the backend service if the Host Header matches the wildcard value configured on the Host parameter.
For this example we need to use 2 custom resources; TLSProfile and VirtualServer


Eg: wildcardhost-tls.yml / wildcardhost-tls-vs.yml

```yml
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  labels:
    f5cr: "true"
  name: wildcard-tls
  namespace: default
spec:
  hosts:
    - '*.f5test.local'
  tls:
    clientSSL: /Common/clientssl
    reference: bigip
    termination: edge
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: wildcard-tls-vs
  namespace: default
spec:
  host: '*.f5test.local'
  tlsProfileName: wildcard-tls
  virtualServerAddress: 10.1.10.73
  virtualServerName: "wildcard-tls-vs"
  httpTraffic: none
  pools:
    - path: /
      service: echo-svc
      servicePort: 80
  snat: auto
```


Create the VS CRD resource. 
```
kubectl apply -f wildcardhost-tls.yml
kubectl apply -f wildcardhost-tls-vs.yml
```
CIS will create an HTTPS Virtual Server on BIG-IP with VIP `10.1.10.73` and attach a policy that forwards traffic to service `echo-svc` if the Host Header matches `*.f5demo.local`.   

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs wildcard-tls-vs
```

Try accessing the service with curl as per the examples below. 
```
curl -k https://test.example.local/ --resolve test.example.local:80:10.1.10.73

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl -k https://test1.f5test.local/ --resolve test1.f5test.local:443:10.1.10.73
curl -k https://test2.f5test.local/ --resolve test2.f5test.local:443:10.1.10.73
...
...
curl -k https://test10.f5test.local/ --resolve test10.f5test.local:443:10.1.10.73

```

Verify that you traffic was forwarded to the `echo-svc` service on both tests.
