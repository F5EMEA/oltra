# Enabling WAF policies on Ingress Resources

In this example we using [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/) as part of an `Ingress Resource` to protect a Web Application running inside Kubernetes.

## Prerequisites

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `ingress`.
```
cd ~/oltra/use-cases/nap/basic/ingress
```

## Step 1. Deploy a Web Application

Deploy the application manifest and service:
```
kubectl apply -f apps.yaml
```

## Step 2 - Deploy the AP Policy
APPolicy manifest helps you create your App Protect WAF policies that you will later reference to your VirtualServer, VirtualServerRoute, or Ingress resources. To enable/disable features you have to add the desired policy to the spec field in the APPolicy resource.

> Note: The relationship between the Policy JSON and the resource spec is 1:1.

Eg: APPolicy.yml
```yml
apiVersion: appprotect.f5.com/v1beta1
kind: APPolicy
metadata:
  name: nap-demo
  namespace: nap-ingress
spec:
  policy:
    applicationLanguage: utf-8
    enforcementMode: blocking
    name: nap-demo
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
  namespace: nap-ingress
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

## Step 4 - Deploy the Ingress resource
The APProtect policies, Logging Profiles and Logging destinations are defined as Annotations on Ingress Resources.

Eg: ingress.yml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nap-ingress
  namespace: nap-ingress
  annotations:
    appprotect.f5.com/app-protect-policy: "app-protect/www"
    appprotect.f5.com/app-protect-enable: "True"                              
    appprotect.f5.com/app-protect-security-log-enable: "True"                 
    appprotect.f5.com/app-protect-security-log: "app-protect/logconf" 
    appprotect.f5.com/app-protect-security-log-destination: "syslog:server=10.1.1.7:515"
spec:
  ingressClassName: nginx-plus
  rules:
  - host: nap-ingress.f5demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: www-svc
            port:
              number: 80
```      

Create the Ingress resource:
```
kubectl apply -f virtual-server.yaml
```

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

To review the logs login to Grafana and search with the support ID. More information regarding NAP Grafana Dashboard can be found on the [**NAP Dashboard**](https://github.com/F5EMEA/oltra/tree/main/use-cases/nap/monitoring) lab


***Clean up the environment (Optional)***
```
kubectl delete -f .
```
