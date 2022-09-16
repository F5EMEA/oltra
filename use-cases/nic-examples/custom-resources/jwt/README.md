# JWT

In this example, we deploy a web application, configure load balancing for it via a VirtualServer, and apply a JWT policy.

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

## Step 2 - Deploy the JWK Secret

Create a secret with the name `jwk-secret` that will be used for JWT validation:
```
kubectl apply -f jwk-secret.yaml
```

## Step 3 - Deploy the JWT Policy

Create a policy with the name `jwt-policy` that references the secret from the previous step and only permits requests to our web application that contain a valid JWT:
```
kubectl apply -f jwt.yaml
```

## Step 4 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
kubectl apply -f virtual-server.yaml
```

Note that the VirtualServer references the policy `jwt-policy` created in Step 3.

## Step 5 - Test the Configuration

If you attempt to access the application without providing a valid JWT, NGINX will reject your requests for that VirtualServer:
```
curl --resolve webapp.example.com:443:10.1.10.40 http://webapp.example.com:443/
```

The expected output is:
```html
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.19.1</center>
</body>
</html>
```

If you provide a valid JWT, your request will succeed:
```
curl --resolve webapp.example.com:443:10.1.10.40 http://webapp.example.com:443/ -H "token: `cat token.jwt`"
```

The expected output is:
```
Server address: 172.17.0.3:8080
Server name: webapp-7c6d448df9-lcrx6
Date: 10/Sep/2020:18:20:03 +0000
URI: /
Request ID: db2c07ce640755ccbe9f666d16f85620
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```    