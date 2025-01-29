# Rate Limit

In this example, we deploy a web application, configure load balancing for it via a VirtualServer, and apply a rate limit policy.

## Prerequisites

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `rate-limit`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/rate-limit
```

## Step 1 - Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f webapp.yaml
```

## Step 2 - Deploy the Rate Limit Policy

In this step, we create a policy with the name `rate-limit-policy` that allows only 1 request per second coming from a single IP address.

Create the policy:
```
kubectl apply -f rate-limit.yaml
```

## Step 3 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
kubectl apply -f virtual-server.yaml
```

Note that the VirtualServer references the policy `rate-limit-policy` created in Step 2.

## Step 4 - Test the Configuration

Let's test the configuration. If you access the application at a rate less than one request per second, NGINX will allow your requests:
```cmd
for i in {1..10} ; do curl http://rate.f5k8s.net/; sleep 1; done
```

The expected output is:
```
Server address: 10.244.140.104:8080
Server name: webapp-7c6d448df9-c6z64
Date: 17/Sep/2022:04:10:05 +0000
URI: /
Request ID: a8d0428ffc9a9113a81fc3063327897c
```

If you access the application at a rate higher than one request per second, NGINX will start rejecting your requests:
```cmd
for i in {1..10} ; do curl http://rate.f5k8s.net/; done
```

The expected output is:
```
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
```

> Note: The command result is truncated for the clarity of the example.


***Clean up the environment (Optional)***
```
kubectl delete -f .
```    