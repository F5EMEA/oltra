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
  virtualServerAddress: "10.1.10.93"
  host: "*.f5demo.local"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```

Create the VS CRD resource. 
```
kubectl apply -f virtual-wildcardhost.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.93` and attaches a policy which forwards traffic to service `echo-svc` if the Host Header matches `*.f5demo.local`.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service with curl as per the examples below. 
```
curl http://test.example.local/ --resolve test.example.local:80:10.1.10.93

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl http://test1.f5demo.local/ --resolve test1.f5demo.local:80:10.1.10.93
curl http://test2.f5demo.local/ --resolve test2.f5demo.local:80:10.1.10.93
...
...
curl http://test10.f5demo.local/ --resolve test10.f5demo.local:80:10.1.10.93

```

Verify that you traffic was forwarded to the `echo-svc` service on both tests.



## HTTPS Virtual Server with wildcard Host parameter

This section demonstrates the deployment of a **HTTPS** Virtual Server with wildcard Host parameter.
The virtual server should send traffic to the backend service if the Host Header matches the wildcard value configured on the Host parameter.
For this example we need to use 2 custom resources; TLSProfile and VirtualServer


Eg: wildcardhost-tls.yml

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
    - '*.f5demo.local'
  tls:
    clientSSL: /Common/clientssl
    reference: bigip
    termination: edge
```

Eg: wildcardhost-tls-vs.yml

```yml
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: wildcard-tls-vs
  namespace: default
spec:
  host: '*.f5demo.local'
  tlsProfileName: wildcard-tls
  virtualServerAddress: 10.1.10.93
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
kubectl apply -f virtual-wildcardhost.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.93` and attaches a policy which forwards traffic to service `echo-svc` if the Host Header matches `*.f5demo.local`.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Try accessing the service with curl as per the examples below. 
```
curl -k https://test.example.local/ --resolve test.example.local:80:10.1.10.93

```
In the above example you should see a reset connection as it didnt match the configured Host parameter.
`curl: (56) Recv failure: Connection reset by peer`


Try again with the examples below
```
curl -k https://test1.f5demo.local/ --resolve test1.f5demo.local:80:10.1.10.93
curl -k https://test2.f5demo.local/ --resolve test2.f5demo.local:80:10.1.10.93
...
...
curl -k https://test10.f5demo.local/ --resolve test10.f5demo.local:80:10.1.10.93

```

Verify that you traffic was forwarded to the `echo-svc` service on both tests.
