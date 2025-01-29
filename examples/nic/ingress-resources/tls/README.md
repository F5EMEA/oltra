# Example

In this example we deploy the NGINX or NGINX Plus Ingress Controller, a simple web application and then configure load balancing for that application using the Ingress resource.

## Running the Example

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `complete-example`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/tls
```

## 1. Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f app.yaml
```

## 2. Configure Load Balancing

Create a secret with an SSL certificate and a key:
```
kubectl apply -f secret.yaml
```

Create an Ingress resource:
```
kubectl apply -f ingress.yaml
```

## 3. Test the Application

To access the application, curl the coffee and the tea services.


To get coffee:
```
curl https://tls.f5k8s.net/coffee -k

###########  Expected Output  ##########
Server address: 10.244.196.136:8080
Server name: coffee-6f4b79b975-l8ht2
Date: 16/Sep/2022:14:50:01 +0000
URI: /coffee
Request ID: 5ca5c11a263c4457ebb8194319fdc19e
########################################
```

If your prefer tea:
```
curl https://tls.f5k8s.net:443/tea -k

###########  Expected Output  ##########
Server address: 10.244.196.189:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:50:45 +0000
URI: /tea
Request ID: 76e835733e75a367455566e3cc31c9b5
########################################
```

