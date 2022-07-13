# Rewrite Examples

In this section we provide 2 rewrite examples. One for AppRoot rewrite and another for URI Path rewrite.

- [AppRoot rewrite (rewriteAppRoot)](#approot-rewrite)
- [URI Path rewrite (rewrite)](#uri-path-rewrite)


## AppRoot rewrite
Redirecting the application to specific path when request made with root path "/".


Eg: approot.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: approot-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.61"
  rewriteAppRoot: /home
  host: approot.f5demo.local
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
```

Change the working directory to `Rewrite`.
```
cd ~/oltra/examples/cis/cis-crd/VirtualServer/Rewrite
```

Create the CRD resource.
```
kubectl apply -f approot.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs approot-vs
```

Access the service using curl. 
```
curl -v http://approot.f5demo.local/ --resolve approot.f5demo.local:80:10.1.10.61
```

You should receive a 302 redirect from BIGIP with Location Header set as `/home`. The output should be similar to:

```cmd
* Added approot.f5demo.local:80:10.1.10.61 to DNS cache
* Hostname approot.f5demo.local was found in DNS cache
*   Trying 10.1.10.61...
* TCP_NODELAY set
* Connected to approot.f5demo.local (10.1.10.61) port 80 (#0)
> GET / HTTP/1.1
> Host: approot.f5demo.local
> User-Agent: curl/7.58.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 302 Moved Temporarily
< Location: /home                           <======== Location Header
< Server: BigIP
* HTTP/1.0 connection set to keep alive!
< Connection: Keep-Alive
< Content-Length: 0
```

## URI Path rewrite
Rewriting the path in HTTP Header of a request before submitting to the pool

Eg: rewrite.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: rewrite-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.62"
  host: rewrite.f5demo.local
  pools:
    - path: /lab
      service: svc-1
      servicePort: 8080
      rewrite: /laboratory
    - path: /lib
      service: svc-2
      servicePort: 8080
      rewrite: /library
```
Change the working directory to `Rewrite`.
```
cd ~/oltra/examples/cis/cis-crd/VirtualServer/Rewrite
```

Create the CRD resource.
```
kubectl apply -f rewrite.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs rewrite-vs
```

Access the service using curl. 
```
curl http://rewrite.f5demo.local/lab --resolve rewrite.f5demo.local:80:10.1.10.62
curl http://rewrite.f5demo.local/lib --resolve rewrite.f5demo.local:80:10.1.10.62
```

Note that the paths are rewritten from `/lib` to `/library` and from `/lab` to `/laboratory`.  The output should be similar to:

```cmd
Server address: 10.244.140.109:8080
Server name: app2-78c95bccb5-jvfnr
Date: 12/Jul/2022:14:12:25 +0000
URI: /library
Request ID: 0495d6a17797ea9776120d5f4af10c1a
```