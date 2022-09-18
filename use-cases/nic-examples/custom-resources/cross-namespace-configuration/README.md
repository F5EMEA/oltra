# Cross-Namespace Configuration

In this example we use the [VirtualServer and VirtualServerRoute](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resources to configure load balancing for the modified cafe application from the [Basic Configuration](../basic-configuration/) example. We have put the load balancing configuration as well as the deployments and services into multiple namespaces. Instead of one namespace, we now use three: `tea`, `coffee`, and `cafe`.
* In the tea namespace, we create the tea deployment, service, and the corresponding load-balancing configuration.
* In the coffee namespace, we create the coffee deployment, service, and the corresponding load-balancing configuration.
* In the cafe namespace, we create the cafe secret with the TLS certificate and key and the load-balancing configuration for the cafe application. That configuration references the coffee and tea configurations.

## Prerequisites  

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `cross-namespace-configuration`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/cross-namespace-configuration
```

## Step 1 - Create Namespaces

Create the required tea, coffee, and cafe namespaces:
```
kubectl apply -f namespaces.yaml 
```

## Step 2 - Deploy the Cafe Application

Create the tea deployment and service in the tea namespace:
```
kubectl apply -f tea.yaml 
```

Create the coffee deployment and service in the coffee namespace:
```
kubectl apply -f coffee.yaml
```

## Step 3 - Configure Load Balancing and TLS Termination

Create the VirtualServerRoute resource for tea in the tea namespace:
```
kubectl apply -f tea-virtual-server-route.yaml
```

Create the VirtualServerRoute resource for coffee in the coffee namespace:
```
kubectl apply -f coffee-virtual-server-route.yaml
```

Create the secret with the TLS certificate and key in the cafe namespace:
```
kubectl apply -f cafe-secret.yaml
```

Create the VirtualServer resource for the cafe app in the cafe namespace:
```
kubectl apply -f cafe-virtual-server.yaml
```

## Step 4 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServerRoutes and VirtualServer:
```
kubectl describe virtualserverroute tea -n tea
kubectl describe virtualserverroute coffee -n coffee 


####################################     Expected Output    ####################################
. . .
Events:
    Type     Reason                 Age   From                      Message
    ----     ------                 ----  ----                      -------
    Warning  NoVirtualServersFound  2m    nginx-ingress-controller  No VirtualServer references VirtualServerRoute tea/tea
    Normal   AddedOrUpdated         1m    nginx-ingress-controller  Configuration for tea/tea was added or updated

------------------------------------------------------------------------------------------------------------------------------
. . .
Events:
    Type     Reason                 Age   From                      Message
    ----     ------                 ----  ----                      -------
    Warning  NoVirtualServersFound  2m    nginx-ingress-controller  No VirtualServer references VirtualServerRoute coffee/coffee
    Normal   AddedOrUpdated         1m    nginx-ingress-controller  Configuration for coffee/coffee was added or updated

#################################################################################################
```

Access the application using curl. We'll use curl's `--insecure` option to turn off certificate verification of our self-signed certificate and `--resolve` option to set the IP address and HTTPS port of the Ingress Controller to the domain name of the cafe application:
    
To get coffee:
```
curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/coffee --insecure

##########  Expected Output  ############
Server address: 10.244.140.109:8080
Server name: coffee-6f4b79b975-7xkkh
Date: 16/Sep/2022:14:53:53 +0000
URI: /coffee
Request ID: b044a101d3cfdf3be412ec7247ed006c
##########################################
```

If your prefer tea:
```
curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/tea --insecure

##########  Expected Output  ############
Server address: 10.244.196.189:8080
Server name: tea-6fb46d899f-nsjhz
Date: 16/Sep/2022:14:54:27 +0000
URI: /tea
Request ID: d1444af240f8c8ac8a28f39b909b15d2
##########################################
```


***Clean up the environment (Optional)***
```
kubectl delete -f namespaces.yaml 
```    