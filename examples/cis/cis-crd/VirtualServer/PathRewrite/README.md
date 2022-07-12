# Rewrite Examples

In this section we provide 2 rewrite examples. One for AppRoot rewrite and another for URI Path rewrite.

- [AppRoot rewrite (rewriteAppRoot)](#approot-rewrite)
- [URI Path rewrite (rewrite)](#uri-path-rewrite)


## AppRoot rewrite
Redirecting the application to specific path when request made with root path "/".
The path changes, but the pool with path "/" gets served.

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

Create the CRD resource.
```
kubectl apply -f approot.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service using curl. 
```
curl -v http://approot.f5demo.local/ --resolve approot.f5demo.local:80:10.1.10.61
```

You should receive a 302 redirect from BIGIP with Location Header set as `/home`.


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


Create the CRD resource.
```
kubectl apply -f rewrite.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service using curl. 
```
curl http://rewrite.f5demo.local/lab --resolve rewrite.f5demo.local:80:10.1.10.62
curl http://rewrite.f5demo.local/lib --resolve rewrite.f5demo.local:80:10.1.10.62
```

Note that the paths are rewritten from `/lib` to `/library` and from `/lab` to `/laboratory`
