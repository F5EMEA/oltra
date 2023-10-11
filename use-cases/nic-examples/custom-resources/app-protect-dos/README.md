# DOS

In this example we deploy the NGINX Plus Ingress Controller with [NGINX App Protect DoS](https://www.nginx.com/products/nginx-app-protect-dos/), a simple web application and then configure load balancing and DOS protection for that application using the VirtualServer resource.

## Prerequisites

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `app-protect-dos`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/app-protect-dos
```

## Step 1. Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f webapp.yaml
```

## Step 2 - Deploy the DOS configuration resources

Create the syslog services and pod for the App Protect security and access logs:
```
kubectl apply -f syslog.yaml
kubectl apply -f syslog2.yaml
```

Create the DoS protected resource configuration:
```
kubectl apply -f apdos-protected.yaml
```

Create the App Protect DoS policy and log configuration:
```
kubectl apply -f apdos-policy.yaml
kubectl apply -f apdos-logconf.yaml
```

## Step 3 - Configure Load Balancing

Create the VirtualServer Resource:
```
kubectl apply -f virtual-server.yaml
```
Note the reference to the DOS protected resource in the VirtualServer resource. By specifying the resource it enables DOS protection for the VirtualServer.

## Step 4 - Test the Application

To access the application, curl the Webapp service. We'll use the --resolve option to set the Host header of a request with `webapp.f5k8s.net`

Send a request to the application:
```
curl http://webapp.f5k8s.net/
```

The expected output is:
```
Server address: 10.244.140.79:8080
Server name: webapp-7c6d448df9-l586q
Date: 16/Sep/2022:14:37:57 +0000
URI: /
Request ID: 2a6d7758ed937b3262cd21a6dcfe534d
```

Get the name of the syslog pods that were deployed
```
kubectl get po | grep syslog

#################   Expected Output   ################
syslog-2-785bb59cf9-6d8vd    1/1     Running   0              3m1s
syslog-b8cddb59f-8jptj       1/1     Running   0              3m3s
#####################################################
```

To check the security logs in the syslog pod:
```
kubectl exec -it <SYSLOG_POD> -- cat /var/log/messages
```

To check the access logs in the syslog pod:
```
kubectl exec -it <SYSLOG_POD_2> -- cat /var/log/messages
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```