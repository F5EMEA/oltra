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
  name: redirect-tls-coffee
  labels:
    f5cr: "true"
spec:
  tls:
    termination: edge
    clientSSL: /Common/clientssl
    reference: bigip
  hosts:
  - coffee.f5demo.local
```

Eg: redirect-vs.yml
```yml
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: coffee-vs
  namespace: default
spec:
  tlsProfileName: redirect-tls-coffee
  virtualServerAddress: 10.1.10.60
  httpTraffic: redirect
  host: coffee.f5demo.local
  pools:
    - path: /lattee
      service: app1-svc
      servicePort: 8080
    - path: /mocha
      service: app2-svc
      servicePort: 8080

```

Change the working directory to `httpTaffic`.
```
cd ~/oltra/examples/cis/cis-crd/VirtualServer/httpTaffic
```

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f redirect-tls.yml
kubectl apply -f redirect-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service on Port 80 using the following example. 
```
curl -v http://coffee.f5demo.local/mocha --resolve coffee.f5demo.local:80:10.1.10.60
```

Verify that BIGIP redirected the traffic to the HTTPS Server (port 443). The output should be similar to:

```cmd
* Added coffee.f5demo.local:80:10.1.10.60 to DNS cache
* Hostname coffee.f5demo.local was found in DNS cache
*   Trying 10.1.10.60...
* TCP_NODELAY set
* Connected to coffee.f5demo.local (10.1.10.60) port 80 (#0)
> GET /mocha HTTP/1.1
> Host: coffee.f5demo.local
> User-Agent: curl/7.58.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 302 Moved Temporarily                          <=== Redirect 302
< Location: https://coffee.f5demo.local:443/mocha         <=== Redirect Location Header
< Server: BigIP
* HTTP/1.0 connection set to keep alive!
< Connection: Keep-Alive
< Content-Length: 0
< 
* Connection #0 to host coffee.f5demo.local left intact
```
