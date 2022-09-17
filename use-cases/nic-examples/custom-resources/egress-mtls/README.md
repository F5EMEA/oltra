# Egress MTLS

In this example, we deploy a secure web application, configure load balancing for it via a VirtualServer, and apply an Egress MTLS policy.

## Prerequisites

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `egress-mtls`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/egress-mtls
```

## Step 1 - Deploy a Secure Web Application
The application requires clients to use TLS and present a client TLS certificate which it will verify.

Create the application deployment, service and secret:
```
kubectl apply -f secure-app.yaml
```

## Step 2 - Deploy the Egress MTLS Secret

Create a secret with the name `egress-mtls-secret` that will be used for authentication to application:
```
kubectl apply -f egress-mtls-secret.yaml
```

## Step 3 - Deploy the Trusted CA Secret

Create a secret with the name `egress-trusted-ca-secret` that will be used to verify the certificate of the application:
```
kubectl apply -f egress-trusted-ca-secret.yaml
```

## Step 4 - Deploy the Egress MTLS Policy

Create a policy with the name `egress-mtls-policy` that references the secrets from the previous steps:
```
kubectl apply -f egress-mtls.yaml
```

## Step 5 - Configure Load Balancing

Create a VirtualServer resource for the web application:
```
kubectl apply -f virtual-server.yaml
```

Note that the VirtualServer references the policy `egress-mtls-policy` created in Step 4.

## Step 6 - Test the Configuration

Access the secure backend with the following command:
```
curl --resolve webapp.example.com:80:10.1.10.40 http://webapp.example.com/:80

########    Expected Output    ########
hello from pod secure-app-8cb576989-7hdhp
```

***Clean up the environment (Optional)***
```
kubectl delete -f .
```    