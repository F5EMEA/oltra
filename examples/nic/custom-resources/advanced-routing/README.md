# Advanced Routing

In this example we use the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource to configure advanced routing for the cafe application from the [Basic Configuration](../basic-configuration/) example, for which we have introduced the following changes:
* Instead of one version of the tea service, we have two: `tea-post-svc` and `tea-svc`. We send POST requests for tea to `tea-post-svc` and non-POST requests, such as GET requests, to `tea-svc`.
* Instead of one version of the coffee service, we have two: `coffee-v1-svc` and `coffee-v2-svc`. We send requests that include the cookie `version` set to `v2` to `coffee-v2-svc` and all other requests to `coffee-v1-svc`.
* To simplify the example, we have removed TLS termination.

## Prerequisites
Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory on the terminal to match  this folder.


## Step 1 - Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f cafe.yaml
```

## Step 2 - Configure Load Balancing

Create the VirtualServer resource:
```
kubectl apply -f cafe-virtual-server.yaml
```

Eg: udp-transport-server.yml
```yml
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: cafe
spec:
  host: cafe.f5k8s.net
  upstreams:
  - name: tea-post
    service: tea-post-svc
    port: 80
  - name: tea
    service: tea-svc
    port: 80
  - name: coffee-v1
    service: coffee-v1-svc
    port: 80
  - name: coffee-v2 
    service: coffee-v2-svc
    port: 80
  routes:
  - path: /tea
    matches:
    - conditions:
      - variable: $request_method.  
        value: POST
      action:
        pass: tea-post
    action:
      pass: tea
  - path: /coffee
    matches:
    - conditions:
      - cookie: version
        value: v2
      action:
        pass: coffee-v2
    action:
      pass: coffee-v1
```

## Step 3 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe virtualserver.k8s.nginx.org cafe

####################################     Expected Output    ####################################
. . .
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  2s    nginx-ingress-controller  Configuration for default/cafe was added or updated

################################################################################################
```

Access the tea service using curl. We'll use curl's `--resolve` option to set the IP address and HTTP port of the Ingress Controller to the domain name of the cafe application.
    
Send a POST request and confirm that the response comes from `tea-post-svc`:
```
curl http://cafe.f5k8s.net/tea -X POST

####################################     Expected Output    ####################################
Server address: 10.244.140.68:8080
Server name: tea-post-648dfcdd6c-2pzq6
Date: 16/Sep/2022:14:40:56 +0000
URI: /tea
Request ID: 596ac247f4c7289c05f98dffac281dd5
################################################################################################
```

Send a GET request and confirm that the response comes from `tea-svc`:
```
curl http://cafe.f5k8s.net/tea

####################################     Expected Output    ####################################
Server address: 10.244.196.189:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:41:14 +0000
URI: /tea
Request ID: 6efdbecc5320454a68e0a642972f8273
################################################################################################
```

Access the coffee service:
    
Send a request with the cookie `version=v2` and confirm that the response comes from `coffee-v2-svc`:
```
curl http://cafe.f5k8s.net/coffee --cookie "version=v2"

####################################     Expected Output    ####################################
Server address: 10.244.140.86:8080
Server name: coffee-v2-67499ff985-22hrs
Date: 16/Sep/2022:14:41:24 +0000
URI: /coffee
Request ID: 32f990e7e9624d7c1bac3d0735ea1e45
################################################################################################

```

Send a request without the cookie and confirm that the response comes from `coffee-v1-svc`:
```
curl http://cafe.f5k8s.net/coffee

####################################     Expected Output    ####################################
Server address: 10.244.140.73:8080
Server name: coffee-v1-75869cf7ff-b88cz
Date: 16/Sep/2022:14:41:36 +0000
URI: /coffee
Request ID: a9a0a264b02a8697b76e77fd309ac9f0
################################################################################################

```

***Clean up the environment (Optional)***
```
kubectl delete -f cafe-virtual-server.yaml
```
