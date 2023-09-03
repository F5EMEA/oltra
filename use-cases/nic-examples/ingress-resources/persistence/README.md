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

Change the working directory to `basic`.
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

To access the application, curl the coffee and the tea services. We'll use ```-v``` option to inspect the HTTP headers

To get coffee:
```
curl http://cafe.f5k8s.net/coffee -v
```

 Expected Output
```
< HTTP/1.1 200 OK
< Server: nginx/1.25.1
< Date: Sun, 03 Sep 2023 16:45:01 GMT
< Content-Type: text/plain
< Content-Length: 156
< Connection: keep-alive
< Set-Cookie: srv_id=a982a744ee40c846fe0addafff80fc92; expires=Sun, 03-Sep-23 18:45:01 GMT; max-age=7200; path=/tea.  <======== Set Cookie
< Expires: Sun, 03 Sep 2023 16:45:00 GMT
< Cache-Control: no-cache
< 
Server address: 10.221.23.127:8080
Server name: tea-df5655878-7cgp4
Date: 03/Sep/2023:16:45:01 +0000
URI: /tea
Request ID: 21f5a5f8fc5d1d9e7f29f346b5bb1e2a
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```  