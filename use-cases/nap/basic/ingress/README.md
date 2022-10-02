# WAF

In this example we deploy the NGINX Plus Ingress Controller with [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/), a simple web application and then configure load balancing and WAF protection for that application using the Ingress resource.

## Prerequisites

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `virtualserver`.
```
cd ~/oltra/use-cases/nap/basic/virtualserver
```

## Step 1. Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f apps.yaml
```

## Step 2 - Deploy the AP Policy
In this example we will be using a simple NAP policy that references mainly the Base template. More information on AP Policies can be found <a href="https://docs.nginx.com/nginx-app-protect/configuration-guide/configuration/#policy-configuration-overview"> here </a>. Create the App Protect policy.
```
kubectl apply -f appolicy.yml
```

## Step 3 - Deploy the AP Log
Create log configuration resource:
```
kubectl apply -f log.yml
```

## Step 4 - Deploy the Ingress resource
Create the Ingress resource:
```
kubectl apply -f virtual-server.yaml
```

> *Note that on the Ingress annotations we specify the NAP Policy and Log profile we created in Step 3-4 and we specified the log destination (Elasticsearch).*

## Step 5 - Test the Application

To access the application, curl the coffee and the tea services. We'll use the --resolve option to set the Host header of a request with `webapp.f5demo.local`

Send a request to the application:
```
curl --resolve webapp.f5demo.local:80:10.1.10.10 http://webapp.f5demo.local/

#####################  Expected output  #######################
Server address: 10.244.140.109:8080
Server name: webapp-7586895968-r26zn
Date: 12/Sep/2022:14:12:25 +0000
URI: /
Request ID: 0495d6a17797ea9776120d5f4af10c1a
```

Now, let's try to send a malicious request to the application:
```
curl --resolve webapp.f5demo.local:80:10.1.10.10 "http://webapp.f5demo.local/<script>"

#####################  Expected output  #######################
<html>
  <head>
    <title>Request Rejected</title>
  </head>
  <body>
    The requested URL was rejected. Please consult with your administrator.<br><br>
    Your support ID is: 4045204596866416688<br><br>
    <a href='javascript:history.back();'>[Go Back]</a>
  </body>
</html>
```

## Step 6 - Review Logs

To review the logs login to Grafana and search with the support ID. More information regarding NAP Grafana Dashboard can be found on the <a href="link"> monitoring </a> lab


***Clean up the environment (Optional)***
```
kubectl delete -f .
```