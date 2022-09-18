# Example

In this example we deploy the NGINX or NGINX Plus Ingress Controller, a simple web application and then configure load balancing for that application using the Ingress resource.

## Running the Example

## 1. Deploy the Ingress Controller

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `complete-example`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/complete-example
```

## 2. Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f cafe.yaml
```

## 3. Configure Load Balancing

Create a secret with an SSL certificate and a key:
```
kubectl apply -f cafe-secret.yaml
```

Create an Ingress resource:
```
kubectl apply -f cafe-ingress.yaml
```

## 4. Test the Application

To access the application, curl the coffee and the tea services. We'll use ```curl```'s --insecure option to turn off certificate verification of our self-signed
certificate and the --resolve option to set the Host header of a request with ```cafe.example.com```

To get coffee:
```
curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/coffee --insecure

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
$ curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/tea --insecure

###########  Expected Output  ##########
Server address: 10.244.196.189:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:50:45 +0000
URI: /tea
Request ID: 76e835733e75a367455566e3cc31c9b5
########################################
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```  