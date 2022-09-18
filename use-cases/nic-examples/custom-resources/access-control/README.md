# Access Control

In this example, we deploy a web application; configure load balancing for it via a VirtualServer; and apply access control policies to deny and allow traffic from a specific subnet.

## Prerequisites
Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `access-control`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/access-control
```

## Step 1 - Deploy a Web Application

Create the application deployment and service:
```
kubectl apply -f webapp.yaml
```

## Step 2 - Deploy an Access Control Policy

In this step, we create a policy with the name `webapp-policy` that denies requests from clients with an IP that belongs to the subnet `10.0.0.0/8`. This is the subnet that our test client in Steps 4 and 6 will belong to. Make sure to change the `deny` field of the `access-control-policy-deny.yaml` according to your environment (use the subnet of your machine).

Create the policy:
```
kubectl apply -f access-control-policy-deny.yaml
```

## Step 3 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
kubectl apply -f virtual-server.yaml
```

> Note that the VirtualServer references the policy `webapp-policy` created in Step 2.

## Step 4 - Test the Configuration

Let's access the application:
```
curl --resolve webapp.example.com:80:10.1.10.10 http://webapp.example.com:80
```

The expected output is:
```html
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.21.5</center>
</body>
</html>
```

We got a 403 response from NGINX, which means that our policy successfully blocked our request. 

## Step 5 - Update the Policy

In this step, we update the policy to allow requests from clients from the subnet `10.0.0.0/8`. Make sure to change the `allow` field of the `access-control-policy-allow.yaml` according to your environment. 

Update the policy:
```
kubectl apply -f access-control-policy-allow.yaml
```

## Step 6 - Test the Configuration

Let's access the application again:
```
curl --resolve webapp.example.com:80:10.1.10.10 http://webapp.example.com:80
```

The expected output is:
```
Server address: 10.244.140.79:8080
Server name: webapp-7c6d448df9-l586q
Date: 16/Sep/2022:14:37:57 +0000
URI: /
Request ID: 2a6d7758ed937b3262cd21a6dcfe534d
```

In contrast with Step 4, we got a 200 response, which means that our updated policy successfully allowed our request.


***Clean up the environment (Optional)***
```
kubectl delete -f .
```
