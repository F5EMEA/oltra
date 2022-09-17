# Basic Configuration

In this example we configure load balancing with TLS termination for a simple web application using the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource. The application, called cafe, lets you get either tea via the tea service or coffee via the coffee service. You indicate your drink preference with the URI of your HTTP request: URIs ending with `/tea` get you tea and URIs ending with `/coffee` get you coffee.

The example is similar to the [complete example](../../examples/complete-example/README.md). However, instead of the Ingress resource, we use the VirtualServer.

## Prerequisites  

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `basic-configuration`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/basic-configuration
```

## Step 1 - Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f cafe.yaml
```

## Step 2 - Configure Load Balancing and TLS Termination

Create the secret with the TLS certificate and key:
```
kubectl apply -f cafe-secret.yaml
```

Create the VirtualServer resource:
```
kubectl apply -f cafe-virtual-server.yaml
```

## Step 3 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe virtualserver cafe

####################################     Expected Output    ####################################
. . .
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  7s    nginx-ingress-controller  Configuration for default/cafe was added or updated
```

Access the application using curl. We'll use curl's `--insecure` option to turn off certificate verification of our self-signed certificate and `--resolve` option to set the IP address and HTTPS port of the Ingress Controller to the domain name of the cafe application:
    
To get coffee:
```
curl --resolve cafe.example.com:443:10.1.10.40 https://cafe.example.com:443/coffee --insecure

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
curl --resolve cafe.example.com:443:10.1.10.40 https://cafe.example.com:443/tea --insecure


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
kubectl delete -f cafe-secret.yaml
```    