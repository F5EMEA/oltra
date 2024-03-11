# Configure behaviour of HTTP Virtual Server

This section demonstrates how to configuring the parameter httpTraffic on the VirtualServer resources changes the behaviour of the BIGIP Virtual Server.
There are 3 options:

 - httpTraffic = allow -> Allows HTTP (Default)
 - httpTraffic = none  -> Only HTTPS
 - httpTraffic = redirect -> redirects HTTP to HTTPS

In this example we will use `httpTraffic = redirect` on the VirtualServer resource so that BIGIP redirects traffic coming on port 80 to port 443.


Eg: redirect-tls.yml
```yml
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  name: redirect-tls
  labels:
    f5cr: "true"
spec:
  tls:
    termination: edge
    clientSSL: /Common/clientssl
    reference: bigip
  hosts:
  - redirect.f5k8s.net
```

Eg: redirect-vs.yml
```yml
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: redirect-vs
  namespace: default
spec:
  tlsProfileName: redirect-tls
  virtualServerAddress: 10.1.10.60
  httpTraffic: redirect
  host: redirect.f5k8s.net
  pools:
    - path: /lattee
      service: app1-svc
      servicePort: 8080
    - path: /mocha
      service: app2-svc
      servicePort: 8080

```

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `httpTaffic`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/httpTraffic
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.


Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f redirect-tls.yml
kubectl apply -f redirect-vs.yml
```

Confirm that the VirtualServer resource is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

Expected output 
```
NAME          HOST                 TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS    IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
redirect-vs   redirect.f5k8s.net   redirect-tls     redirect      10.1.10.60               10.1.10.60      Ok       19s
```


Access the service on Port 80 using the following example. 
```
curl -v http://redirect.f5k8s.net/mocha
```

Verify that BIGIP redirected the traffic to the HTTPS Server (port 443). The output should be similar to:
```
* Added coffee.f5k8s.net:80:10.1.10.60 to DNS cache
* Hostname coffee.f5k8s.net was found in DNS cache
*   Trying 10.1.10.60...
* TCP_NODELAY set
* Connected to coffee.f5k8s.net (10.1.10.60) port 80 (#0)
> GET /mocha HTTP/1.1
> Host: coffee.f5k8s.net
> User-Agent: curl/7.58.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 302 Moved Temporarily                          <=== Redirect 302
< Location: https://coffee.f5k8s.net:443/mocha         <=== Redirect Location Header
< Server: BigIP
* HTTP/1.0 connection set to keep alive!
< Connection: Keep-Alive
< Content-Length: 0
< 
* Connection #0 to host coffee.f5k8s.net left intact
```

***Clean up the environment (Optional)***
```
kubectl delete -f redirect-tls.yml
kubectl delete -f redirect-vs.yml
```

