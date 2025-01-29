# Basic Configuration

In this example we configure load balancing with TLS termination for a simple web application using the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource. The application, called cafe, lets you get either tea via the tea service or coffee via the coffee service. You indicate your drink preference with the URI of your HTTP request: URIs ending with `/tea` get you tea and URIs ending with `/coffee` get you coffee.


## Prerequisites  

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `basic`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/basic
```

## Step 1 - Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f app.yaml
```

## Step 2 - Configure Load Balancing

> No need to create a secret as we will be using the default wildcard cert configured on NGINX:

Create the VirtualServer resource:
```
kubectl apply -f virtual-server.yaml
```

## Step 3 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe virtualserver basic

####################################     Expected Output    ####################################
. . .
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  7s    nginx-ingress-controller  Configuration for default/cafe was added or updated
```

  
To get coffee:
```
curl http://basic-vs.f5k8s.net/coffee

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
curl http://basic-vs.f5k8s.net/tea


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
kubectl delete -f cafe-virtual-server.yaml
```    