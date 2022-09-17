# Basic Authentication

NGINX supports authenticating requests with [ngx_http_auth_basic_module](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html).
In this example, we deploy a web application, configure load balancing for it via a VirtualServer, and apply a Basic Auth policy.

## Prerequisites

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `basic-auth`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/basic-auth
```

## Step 1 - Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f cafe.yaml
```

## Step 2 - Deploy the Basic Auth Secret

Create a secret of type `nginx.org/htpasswd` with the name `cafe-passwd` that will be used for Basic Auth validation. It contains a list of user and base64 encoded password pairs:
```
kubectl apply -f cafe-passwd.yaml
```

## Step 3 - Deploy the Basic Auth Policy

Create a policy with the name `basic-auth-policy` that references the secret from the previous step and only permits requests to our web application that contain a valid user:password auth:
```
kubectl apply -f basic-auth-policy.yaml
```

## Step 4 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
kubectl apply -f cafe-virtual-server.yaml
```

Note that the VirtualServer references the policy `basic-auth-policy` created in Step 3.

## Step 5 - Test the Configuration

If you attempt to access the application without providing a valid user and password, NGINX will reject your requests for that VirtualServer:
```
curl --resolve cafe.example.com:80:10.1.10.40 http://cafe.example.com:80/


####################################     Expected Output    ####################################
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.21.5</center>
</body>
</html>
################################################################################################
```

If you provide a valid user and password, your request will succeed:
```
curl --resolve cafe.example.com:443:10.1.10.40 https://cafe.example.com:443/coffee --insecure -u foo:bar

####################################     Expected Output    ####################################
Server address: 10.244.0.6:8080
Server name: coffee-7b9b4bbd99-bdbxm
Date: 20/Jun/2022:11:43:34 +0000
URI: /coffee
Request ID: f91f15d1af17556e552557df2f5a0dd2
################################################################################################
```


***Clean up the environment (Optional)***
```
kubectl delete -f .
```