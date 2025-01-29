# Traffic Splitting 

In this example we use the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource to configure traffic splitting for the cafe application from the [Basic Configuration](../basic-configuration/) example, for which we have introduced the following changes:
* Instead of one version of the coffee service, we have two: `coffee-v1-svc` and `coffee-v2-svc`. We send 90% of the coffee traffic to `coffee-v1-svc` and the remaining 10% to `coffee-v2-svc`.
* To simplify the example, we have removed TLS termination and the tea service.

## Prerequisites  

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `traffic-splitting`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/traffic-splitting
```

## Step 1 - Deploy the Cafe Application

Create the app deployments and services:
```
kubectl apply -f app.yaml
```

## Step 2 - Configure Load Balancing

Create the VirtualServer resource:
```
kubectl apply -f virtual-server.yaml
```

## Step 3 - Test the Configuration

Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
```
kubectl describe vs traffic-splitting

####################################     Expected Output    ####################################
Events:
    Type    Reason          Age   From                      Message
    ----    ------          ----  ----                      -------
    Normal  AddedOrUpdated  5s    nginx-ingress-controller  Configuration for default/cafe was added or updated
```

```cmd
for i in {1..20} ; do curl -s http://ab.f5k8s.net/app | grep app-v.; done
```

80% of responses will come from `app-v1-svc` and 20 % of responses will come from `app-v2-svc`:

***Clean up the environment (Optional)***
```
kubectl delete -f cafe-virtual-server.yaml
```    