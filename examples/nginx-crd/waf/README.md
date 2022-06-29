# WAF

In this example we deploy the NGINX Plus Ingress controller with [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/), a simple web application and then configure load balancing and WAF protection for that application using the VirtualServer resource.

## Prerequisites

1. Follow the installation [instructions](https://docs.nginx.com/nginx-ingress-controller/installation) to deploy the Ingress controller with NGINX App Protect.
1. Save the public IP address of the Ingress Controller into a shell variable:
    ```
    $ IC_IP=XXX.YYY.ZZZ.III
    ```
1. Save the HTTP port of the Ingress Controller into a shell variable:
    ```
    $ IC_HTTP_PORT=<port number>
    ```

## Step 1. Deploy a Web Application

Create the application deployment and service:
```
$ kubectl apply -f webapp.yaml
```

## Step 2 - Deploy the AP Policy

1. Create the syslog service and pod for the App Protect security logs:
    ```
    $ kubectl apply -f syslog.yaml
    ```
1. Create the User Defined Signature, App Protect policy and log configuration:
    ```
    $ kubectl apply -f ap-apple-uds.yaml
    $ kubectl apply -f ap-dataguard-alarm-policy.yaml
    $ kubectl apply -f ap-logconf.yaml
    ```

## Step 3 - Deploy the WAF Policy

1. Create the WAF policy
    ```
    $ kubectl apply -f waf.yaml
    ```

Note the App Protect configuration settings in the Policy resource. They enable WAF protection by configuring App Protect with the policy and log configuration created in the previous step.

## Step 4 - Configure Load Balancing

1. Create the VirtualServer Resource:
    ```
    $ kubectl apply -f virtual-server.yaml
    ```

Note that the VirtualServer references the policy `waf-policy` created in Step 3.

## Step 5 - Test the Application

To access the application, curl the coffee and the tea services. We'll use the --resolve option to set the Host header of a request with `webapp.example.com`

1. Send a request to the application:
    ```
    $ curl --resolve webapp.example.com:$IC_HTTP_PORT:$IC_IP http://webapp.example.com:$IC_HTTP_PORT/
    Server address: 10.12.0.18:80
    Server name: webapp-7586895968-r26zn
    ...
    ```

1. Now, let's try to send a request with a suspicious URL:
    ```
    $ curl --resolve webapp.example.com:$IC_HTTP_PORT:$IC_IP "http://webapp.example.com:$IC_HTTP_PORT/<script>"
    <html><head><title>Request Rejected</title></head><body>
    ...
    ```
1. Lastly, let's try to send some suspicious data that matches the user defined signature.
    ```
    $ curl --resolve webapp.example.com:$IC_HTTP_PORT:$IC_IP -X POST -d "apple" http://webapp.example.com:$IC_HTTP_PORT/
    <html><head><title>Request Rejected</title></head><body>
    ...
    ```
    As you can see, the suspicious requests were blocked by App Protect

1. To check the security logs in the syslog pod:
    ```
    $ kubectl exec -it <SYSLOG_POD> -- cat /var/log/messages
    ```
