# Example

This example demonstrates how to achieve session affinity using cookies.
It is often required that the requests from a client are always passed to the same backend container. You can enable such behavior with Session Persistence, available in the NGINX Plus Ingress Controller.

NGINX Plus supports the sticky cookie method. With this method, NGINX Plus adds a session cookie to the first response from the backend container, identifying the container that sent the response. When a client issues the next request, it will send the cookie value and NGINX Plus will route the request to the same container.

## Syntax

To enable session persistence for one or multiple services, add the **nginx.com/sticky-cookie-services** annotation to
your Ingress resource definition. The annotation specifies services that should have session persistence enabled as well
as various attributes of the cookie. The annotation syntax is as follows:

```yaml
nginx.com/sticky-cookie-services: "service1[;service2;...]"
```

Here each service follows the following syntactic rule:

```text
serviceName=serviceName cookieName [expires=time] [domain=domain] [httponly] [secure] [path=path]
```

The syntax of the *cookieName*, *expires*, *domain*, *httponly*, *secure* and *path* parameters is the same as for the
[sticky directive](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#sticky) in the NGINX Plus configuration.


## Running the Example


Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `persistence`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/persistence
```

## 2. Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f app.yaml
```

## 3. Configure Load Balancing

Create an Ingress resource:
```
kubectl apply -f ingress.yaml
```

## 4. Test the Application

Access the coffee service, validate that the `Set-Cookie` header exists and the `max-age` is set to 1 hour:
```
curl http://sticky.f5k8s.net/coffee -I
```

Expected Output
```
HTTP/1.1 200 OK
Server: nginx/1.25.1
Date: Mon, 04 Sep 2023 08:48:16 GMT
Content-Type: text/plain
Content-Length: 160
Connection: keep-alive
Set-Cookie: srv_id=6fe4ec8d2bbe8cd5338e4f31095affed; expires=Mon, 04-Sep-23 09:48:16 GMT; max-age=3600; path=/coffee
Expires: Mon, 04 Sep 2023 08:48:15 GMT
Cache-Control: no-cache
```

Access the tea service, validate that the `Set-Cookie` header exists and the `max-age` is set to 2 hours:
```
curl http://sticky.f5k8s.net/tea -I
```

 Expected Output
```
HTTP/1.1 200 OK
Server: nginx/1.25.1
Date: Mon, 04 Sep 2023 08:49:33 GMT
Content-Type: text/plain
Content-Length: 154
Connection: keep-alive
Set-Cookie: srv_id=35e80c4cacdfbafc67e984beb2614376; expires=Mon, 04-Sep-23 10:49:33 GMT; max-age=7200; path=/tea
Expires: Mon, 04 Sep 2023 08:49:32 GMT
Cache-Control: no-cache
```


***Clean up the environment (Optional)***
```
kubectl delete -f .
```  