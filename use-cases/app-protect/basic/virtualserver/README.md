# Enabling WAF policies on Virtual Server CRDs

In this example we are using [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/) as part of an `Virtual Server` CRD to protect a Web Application running inside Kubernetes.

## Prerequisites

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `virtualserver`.
```
cd ~/oltra/use-cases/app-protect/basic/virtualserver
```

## Step 1. Deploy a Web Application

Deploy the application manifest and service:
```
kubectl create namespace nap
kubectl apply -f app.yml
```

## Step 2 - Deploy the AP Policy
APPolicy manifest helps you create your App Protect WAF policies that you will later reference to your VirtualServer, VirtualServerRoute, or Ingress resources. To enable/disable features you have to add the desired policy to the spec field in the APPolicy resource.

> Note: The relationship between the Policy JSON and the resource spec is 1:1.

Eg: APPolicy.yml
```yml
apiVersion: appprotect.f5.com/v1beta1
kind: APPolicy
metadata:
  name: nap-vs
  namespace: nap
spec:
  policy:
    applicationLanguage: utf-8
    enforcementMode: blocking
    name: nap-vs
    template:
      name: POLICY_TEMPLATE_NGINX_BASE
```

In this example we will be using a simple NAP policy that references mainly the Base template. More information on AP Policies can be found <a href="https://docs.nginx.com/nginx-app-protect/configuration-guide/configuration/#policy-configuration-overview"> here </a>. 

Create the App Protect policy.
```
kubectl apply -f appolicy.yml
```

## Step 3 - Deploy the AP Log
`APLogConf` resource helps you define the logging profile that will be used along with the APPolicy. You would define that config in the spec of your APLogConf resource as follows::

Eg: APLogConf.yml
```yml
apiVersion: appprotect.f5.com/v1beta1
kind: APLogConf
metadata:
  name: logconf
  namespace: nap
spec:
  content:
    format: default
    max_message_size: 10k
    max_request_size: any
  filter:
    request_type: all
```

Create APLogConf resource:
```
kubectl apply -f log.yml
```

## Step 4 - Deploy the NGINX Policy
NGINX Policy is where you define as part of the `waf` spec the APPolicy, the APLogConf profile and the log destination that you would like to use.

Eg: Policy.yml
```yml
apiVersion: k8s.nginx.org/v1
kind: Policy
metadata:
  name: waf-policy-vs
  namespace: nap
spec:
  waf:
    enable: true
    apPolicy: "nap-vs"
    securityLogs:
    - enable: true
      apLogConf: "logconf"
      logDest: "syslog:server=10.1.20.20:8515"
```

Create the NGINX policy to reference the AP Policy, the AP Log profile and the log destination.
```
kubectl apply -f policy.yml
```

## Step 5 - Configure the VirtualServer resource
On the VirtualServer resource we reference the NGINX policy we just created, in order for NGINX APP Protect to be enforced. 

Eg: VirtualServer.yml
```yml
apiVersion: k8s.nginx.org/v1
kind: VirtualServer
metadata:
  name: webapp
  namespace: nap
spec:
  host: nap-vs.f5k8s.net
  policies:
  - name: waf-policy
  upstreams:
  - name: webapp
    service: webapp-svc
    port: 80
  routes:
  - path: /
    action:
      pass: webapp
```

Create the VirtualServer resource:
```
kubectl apply -f virtual-server.yml
```

## Step 6 - Test the Application

To access the application, curl the webapp service.

Send a request to the application:
```
curl http://nap-vs.f5k8s.net/

#####################  Expected output  #######################
Server address: 10.244.140.109:8080
Server name: webapp-7586895968-r26zn
Date: 12/Sep/2022:14:12:25 +0000
URI: /
Request ID: 0495d6a17797ea9776120d5f4af10c1a
```

Now, let's try to send a malicious request to the application:
```
curl "http://nap-vs.f5k8s.net/<script>"

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

To review the logs login to Grafana and search with the support ID. More information regarding NAP Grafana Dashboard can be found on the [**NAP Dashboard**](https://github.com/F5EMEA/oltra/tree/main/use-cases/app-protect/monitoring) lab


***Clean up the environment (Optional)***
```
kubectl delete -f .
```
