# Secure Virtual Server with Re-encrypt Termination using BIG-IP Profiles

This section demonstrates the option to configure VirtualAddress with custom HTTP/HTTPS port numbers.  
For this example section CIS will create a Virtual Server on BIG-IP with custom port (8080). To achieve this we will add `virtualServerHTTPPort` parameter on the VirtualServer resource with the port that we want BIGIP VIP to listen to. 

Eg: reference-vs.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: custom-port-http-vs
  labels:
    f5cr: "true"
spec:
  host: custom.f5demo.local
  virtualServerAddress: "10.1.10.57"
  virtualServerName: "custom-port-http-vs"
  virtualServerHTTPPort: 8080
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```
> **Note:** for HTTPS VirtualServer the parameter name is `virtualServerHTTPSPort`


Change the working directory to `CustomPort`.
```
cd ~/oltra/examples/cis/cis-crd/VirtualServer/CustomPort
```

Create the VS CRD resource. 
```
kubectl apply -f custom-http-port.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.57` and attaches a policy which forwards all traffic to pool echo-svc when the Host Header is equal to `custom.f5demo.local`.   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs custom-port-http-vs
```

Try accessing the service with curl as per the examples below. 
```
curl http://custom.f5demo.local:8080 --resolve custom.f5demo.local:8080:10.1.10.57
```

You should be able to access the service running in K8s. The output should be similar to:

```cmd
{
    "Server Name": "custom.f5demo.local",
    "Server Address": "10.244.140.93",
    "Server Port": "8080",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"host":"custom.f5demo.local:8080","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "56414",
    "Timestamp": "1657610679",
    "Data": "0"
```