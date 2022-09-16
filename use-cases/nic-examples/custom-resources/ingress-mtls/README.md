# Ingress MTLS

In this example, we deploy a web application, configure load balancing for it via a VirtualServer, and apply an Ingress MTLS policy.

## Prerequisites

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `ingress-mtls`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/ingress-mtls
```

## Step 1 - Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f webapp.yaml
```

## Step 2 - Deploy the Ingress MTLS Secret

Create a secret with the name `ingress-mtls-secret` that will be used for Ingress MTLS validation:
```
kubectl apply -f ingress-mtls-secret.yaml
```

## Step 3 - Deploy the Ingress MTLS Policy

Create a policy with the name `ingress-mtls-policy` that references the secret from the previous step:
```
kubectl apply -f ingress-mtls.yaml
```

## Step 4 - Configure Load Balancing and TLS Termination
Create the secret with the TLS certificate and key:
```
kubectl create -f tls-secret.yaml
```

Create a VirtualServer resource for the web application:
```
kubectl apply -f virtual-server.yaml
```

> Note that the VirtualServer references the policy `ingress-mtls-policy` created in Step 3.

## Step 5 - Test the Configuration

If you attempt to access the application without providing a valid Client certificate and key, NGINX will reject your requests for that VirtualServer:
```
curl --insecure --resolve webapp.example.com:443:10.1.10.40 https://webapp.example.com:443/
```

The expected output is:
```html
<html>
<head><title>400 No required SSL certificate was sent</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<center>No required SSL certificate was sent</center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
```

If you provide a valid Client certificate and key, your request will succeed:
```
curl --insecure --resolve webapp.example.com:443:10.1.10.40 https://webapp.example.com:443/ --cert ./client-cert.pem --key ./client-key.pem
```

The expected output is:
```
Server address: 10.244.0.8:8080
Server name: webapp-7c6d448df9-9ts8x
Date: 23/Sep/2020:07:18:52 +0000
URI: /
Request ID: acb0f48057ccdfd250debe5afe58252a
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```    