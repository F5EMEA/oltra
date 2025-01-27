# Rewrite Support

You can configure NGINX to rewrite the URI of a request before sending it to the application. For example, `/v1/app`
can be rewritten to `/app`.

To configure URI rewriting you need to use the
[ActionProxy](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/#action-proxy)
of the [VirtualServer or
VirtualServerRoute](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/).

## Example with a Prefix Path

In the following example we load balance two applications that require URI rewriting using prefix-based URI matching:

```yaml
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: api-gw
spec:
  host: api-gw.f5k8s.net
  upstreams:
  - name: app1
    service: app1-svc
    port: 80
  - name: app2
    service: app2-svc
    port: 80
  routes:
  - path: /v1/
    action:
      proxy:
        upstream: app1
        rewritePath: /
  - path: /v2/
    action:
      proxy:
        upstream: app2
        rewritePath: /
```

Below are the examples of how the URI of requests to the *app1-svc* and *app2-svc* are rewritten (Note that the `/v1` requests are
redirected to `/v1/`).

- `/v1/` -> `/`
- `/v1/abc` -> `/abc`
- `/v2/` -> `/`
- `/v2/abc` -> `/abc`



### Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe virtualserver api-gw

####################################     Expected Output    ####################################
. . .
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  7s    nginx-ingress-controller  Configuration for default/cafe was added or updated
```

To get v1:
```
curl -L http://api-gw.f5k8s.net/v1
curl http://api-gw.f5k8s.net/v1/
curl http://api-gw.f5k8s.net/v1/abc

###########  Expected Output  ##########
URI: /
URI: /
URI: /abc
########################################
```

If your prefer v2:
```
curl -L http://api-gw.f5k8s.net/v2
curl http://api-gw.f5k8s.net/v2/
curl http://api-gw.f5k8s.net/v2/etc


###########  Expected Output  ##########
URI: /
URI: /
URI: /etc
########################################
```




## Example with Regular Expressions

If the route path is a regular expression instead of a prefix or an exact match, the `rewritePath` can include capture
groups with `$1-9`, for example:

```yaml
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: api-gw-re
spec:
  host: api-gw-re.f5k8s.net
  upstreams:
  - name: app1
    service: app1-svc
    port: 80
  routes:
  - path: ~ /v1/?(.*)
    action:
      proxy:
        upstream: app1
        rewritePath: /$1
```

Note the capture group in the path `(.*)` is used in the rewritePath `/$1`. This is needed in order to pass the rest of
the request URI (after `/v1`).

Below are the examples of how the URI of requests to the *tea-svc* are rewritten.

- `/v1` -> `/`
- `/v1/` -> `/`
- `/v1/abc` -> `/abc`
