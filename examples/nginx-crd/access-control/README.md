# Access Control

In this example, we deploy a web application; configure load balancing for it via a VirtualServer; and apply access control policies to deny and allow traffic from a specific subnet.

## Step 1 - Deploy an Access Control Policy

In this step, we create a policy with the name `webapp-policy` that denies requests from clients with an IP that belongs to the subnet `10.0.0.0/8`. This is the subnet that our test client in Steps 4 and 6 will belong to. Make sure to change the `deny` field of the `access-control-policy-deny.yaml` according to your environment (use the subnet of your machine).

Create the policy:
```
$ kubectl apply -f access-control-policy-deny.yaml
```

## Step 2 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
$ kubectl apply -f virtual-server.yaml
```

Note that the VirtualServer references the policy `webapp-policy` created in Step 2.

## Step 3 - Test the Configuration

Let's access the application:
```
$ curl --resolve webapp.f5demo.local:$IC_HTTP_PORT:$IC_IP http://webapp.f5demo.local:$IC_HTTP_PORT
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.17.9</center>
</body>
</html>
```

We got a 403 response from NGINX, which means that our policy successfully blocked our request. 

## Step 4 - Update the Policy

In this step, we update the policy to allow requests from clients from the subnet `10.0.0.0/8`. Make sure to change the `allow` field of the `access-control-policy-allow.yaml` according to your environment. 

Update the policy:
```
$ kubectl apply -f access-control-policy-allow.yaml
```

## Step 5 - Test the Configuration

Let's access the application again:
```
$ curl --resolve webapp.f5demo.local:80:10.1.10.40 http://webapp.f5demo.local
Server address: 10.64.0.13:8080
Server name: app1-5cbbc7bd78-wf85w
```

In contrast with Step 4, we got a 200 response, which means that our updated policy successfully allowed our request.
