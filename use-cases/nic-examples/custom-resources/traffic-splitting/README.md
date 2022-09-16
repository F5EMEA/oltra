# Traffic Splitting 

In this example we use the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource to configure traffic splitting for the cafe application from the [Basic Configuration](../basic-configuration/) example, for which we have introduced the following changes:
* Instead of one version of the coffee service, we have two: `coffee-v1-svc` and `coffee-v2-svc`. We send 90% of the coffee traffic to `coffee-v1-svc` and the remaining 10% to `coffee-v2-svc`.
* To simplify the example, we have removed TLS termination and the tea service.

## Prerequisites  

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `rate-limit`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/rate-limit
```

## Step 1 - Deploy the Cafe Application

Create the coffee deployments and services:
```
kubectl create -f cafe.yaml
```

## Step 2 - Configure Load Balancing

Create the VirtualServer resource:
```
kubectl create -f cafe-virtual-server.yaml
```

## Step 3 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe virtualserver cafe

####################################     Expected Output    ####################################
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  5s    nginx-ingress-controller  Configuration for default/cafe was added or updated
```

Access the application using curl. We'll use curl's `--resolve` option to set the IP address and HTTP port of the Ingress Controller to the domain name of the cafe application. Try to get coffee multiple times to see how NGINX sends requests to different versions of the coffee service:
```
curl --resolve cafe.example.com:$IC_HTTP_PORT:$IC_IP http://cafe.example.com:$IC_HTTP_PORT/coffee
```

90% of responses will come from `coffee-v1-svc` and 10 % of responses will come from `coffee-v2-svc`:
