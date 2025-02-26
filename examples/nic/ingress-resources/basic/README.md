# Example

In this example we deploy the NGINX or NGINX Plus Ingress Controller, a simple web application and then configure load balancing for that application using the Ingress resource.

## Running the Example

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `basic`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/basic
```

## 1. Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f app.yaml
```

## 2. Configure Load Balancing

Review and create the Ingress resource:
```
kubectl apply -f ingress.yaml
```

## 3. Test the Application

To access the application, we will use `curl`. 

```
curl http://basic.f5k8s.net/ 
```

Expected Output
```
Server address: 10.244.196.136:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:50:01 +0000
URI: /
Request ID: 5ca5c11a263c4457ebb8194319fdc19e
```

Test will any other path. All requests should be forwarded to the ingress service that is `tea`. 

```
curl http://basic.f5k8s.net/test 
curl http://basic.f5k8s.net/test/123 
curl http://basic.f5k8s.net/app
curl http://basic.f5k8s.net/demo 
curl http://basic.f5k8s.net/123/123/123
```

Expected Output
```
Server address: 10.244.196.189:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:50:45 +0000
URI: /xyz
Request ID: 76e835733e75a367455566e3cc31c9b5
```


***Clean up the environment (Optional)***
```
kubectl delete -f .
```  