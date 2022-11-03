# Enable Multiple WAF on different URL Paths 

In this example we define different WAF Policies for different URL Path of the application that we have published through NGINX+ IC VirtualServer resources. The configuration would be as follows:
- For path **/tea** we will use policy **nap-tea**
- For path **/coffee** we will use policy **nap-coffee**
- For everything else we will use policy **nap-cocoa**


## Prerequisites

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `path-based`.
```
cd ~/oltra/use-cases/app-protect/path-based
```

## Step 1. Deploy a Web Application

Create the application deployment and service:
```
kubectl create namespace nap
kubectl apply -f apps.yml
```

## Step 2 - Create 3 different NAP Policies
We will create 3 NAP policies. To easily differentiate the three policies, each policy will have a different blocking message that will mention the policy name. 
The blocking message will be similar to **Blocked from NAP policy: <Policy_name>.** 

```
kubectl apply -f appolicy-coffee.yml
kubectl apply -f appolicy-tea.yml
kubectl apply -f appolicy-cocoa.yml
```

## Step 3 - Deploy the NAP Log
Create 1 log configuration for all policies:
```
kubectl apply -f log.yml
```

## Step 4 - Deploy the NGINX Policy

Create the policy to reference the AP Policy that will reference the AP policy, the AP Log profile and the log destination.
```
kubectl apply -f policy-coffee.yml
kubectl apply -f policy-tea.yml
kubectl apply -f policy-cocoa.yml
```

## Step 5 - Configure VirtualServer resource

We will create the VirtualServer resource with the following configuration:
- For path **/tea** go to service tea and use WAF policy **nap-tea**
- For path **/coffee** go to service tea and use WAF policy **nap-coffee**
- For everything else go to service cocoa and use WAF policy **nap-cocoa**
```yml
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: nap-cafe
  namespace: nap-vs
spec:
  host: nap-cafe.f5demo.cloud
  policies:
  - name: cocoa-policy     <----  Catch-all NAP Policy
  upstreams:
  - name: cocoa
    service: cocoa-svc
    port: 80
  - name: coffee
    service: coffee-svc
    port: 80
  - name: tea
    service: tea-svc
    port: 80    
  routes:
  - path: /
    action:
      pass: webapp
  - path: /tea
    policies:
    - name: tea-policy            <---- NAP Policy for path /tea
    action:
      pass: webapp
  - path: /coffee
    policies:
    - name: coffee-policy         <---- NAP Policy for path /coffee
    action:
      pass: webapp
```

Create the VirtualServer resource 
```
kubectl apply -f virtual-server.yml
```

## Step 6 - Test the Application

To access the application, curl the coffee and the tea services. 

Send a malicious request to the path /tea:
```
curl "http://nap-cafe.f5demo.cloud/tea/?user=<script>"

#####################  Expected output  #######################
<html>
  <head>
    <title>Request Rejected</title>
  </head>
  <body>
    Blocked from NAP policy: NAP-TEA.<br><br>       <==== Verify the Policy name
    Your support ID is: 4045204596866416688<br><br>
  </body>
</html>
```

Send a malicious request to the path /tea:
```
curl "http://nap-cafe.f5demo.cloud/coffee/?user=<script>"

#####################  Expected output  #######################
<html>
  <head>
    <title>Request Rejected</title>
  </head>
  <body>
    Blocked from NAP policy: NAP-COFFEE.<br><br>       <==== Verify the Policy name
    Your support ID is: 4045204596866416688<br><br>
  </body>
</html>
```

Send a malicious request to a path other than `/tea` or `/coffee`:
```
curl "http://nap-cafe.f5demo.cloud/unknown/?user=<script>"

#####################  Expected output  #######################
<html>
  <head>
    <title>Request Rejected</title>
  </head>
  <body>
    Blocked from NAP policy: NAP-COCOA.<br><br>       <==== Verify the Policy name
    Your support ID is: 4045204596866416688<br><br>
  </body>
</html>
```

## Step 7 - Review Logs

To review the logs login to Grafana and search with the support ID. More information regarding NAP Grafana Dashboard can be found on the [**NAP Dashboard**](https://github.com/F5EMEA/oltra/tree/main/use-cases/app-protect/monitoring) lab

***Clean up the environment (Optional)***
```
kubectl delete -f .
```
