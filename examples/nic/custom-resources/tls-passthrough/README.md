# TLS Passthrough

In this example, we show how to use a TransportServer resource to configure TLS Passthrough load balancing.

With the TLS Passthrough feature, the Ingress Controller accepts TLS connections on port 443 and routes them to the
corresponding backend services without decryption. The routing is done based on the
[SNI](https://en.wikipedia.org/wiki/Server_Name_Indication), which allows clients to specify a server name (like
`example.com`) during the SSL handshake. At the same time, the Ingress Controller continues to handle regular HTTPS
traffic on the same port 443, terminating TLS connections using the TLS certificate and keys, specified through
[Ingress](https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/basic-configuration/) or
[VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/)
resources.

We will deploy 2 backend applications (we call them the *secure apps*) and expose port 8443 for TLS traffic. Each app will use a different certificate. 
Then we will configure the Ingress Controller to route connections to the secure app using a TransportServer resource.

## About the Secure App

The secure apps are an NGINX pod (not to be confused with the Ingress Controller pod, which also includes NGINX)
configured to serve HTTPS traffic on port 8443. For TLS termination, Let's Encrypt TLS certificates and keys are used. The apps respond to clients HTTPS requests with a simple text response `hello from pod <hostname of the pod>`.

You can see how the Secure App is implemented in the `app-ssl-1.yaml` and `app-ssl-2.yaml` file.

## Prerequisites
 
1. Uncomment the line `#- -enable-tls-passthrough` from the NGINX deployment file `oltra/setup/nginx-ic/nginx-plus/nginx-plus.yaml` and re-apply the configuration
```
k apply -f ~/oltra/setup/nginx-ic/nginx-plus/nginx-plus.yaml
``` 
   More information on TLS-Passthough can be found on [NGINX Docs](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/)
   instructions to deploy the Ingress Controller:
    - As part of Step 2 of those instructions, make sure to deploy the custom resource definition for the
      TransportServer resource.
    - Set the
      [`-enable-custom-resources`](https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/command-line-arguments/#cmdoption-enable-custom-resources)
      and
      [`-enable-tls-passthrough`](https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/command-line-arguments/#cmdoption-enable-tls-passthrough)
      command-line arguments of the Ingress Controller to enable the TLS Passthrough feature.
    - If you would like to use any other port than 443 for TLS Passthrough, set
      the [`-tls-passthrough-port`](https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/command-line-arguments/#cmdoption-tls-passthrough-port)
      command-line argument of the Ingress Controller, and configure the load balancer to forward traffic to that port.

1. Verify that a new NGINX instance has been deployed and proceed with the following steps.
```
k get pods -n nginx
``` 

## Step 1 - Deploy the Secure Apps

Change the working directory to `TransportServer`.
```
cd ~/oltra/use-cases/nic-examples/custom-resources/tls-passthrough
```

Create the namespace `tls-passthrough`:
```console
kubectl create ns tls-passthrough
```

Create the secure app deployment and service:

```console
kubectl apply -f app-ssl-1.yaml
kubectl apply -f app-ssl-2.yaml
```

## Step 2 - Configure Load Balancing

1. Create the TransportServer resource to configure TLS Passthrough:

    ```console
    kubectl apply -f transport-server.yaml
    ```

1. Check that the configuration has been successfully applied by inspecting the events of the TransportServer:

    ```console
    kubectl describe ts ssl-pass-1 -n tls-passthrough
    ```

    ```text
    . . .
    Events:
      Type    Reason          Age   From                      Message
      ----    ------          ----  ----                      -------
      Normal  AddedOrUpdated  9s    nginx-ingress-controller  Configuration for tls-passthrough/ssl-pass-1 was added or updated
    ```

1. Save the Type LB IP that NGINX is using.
```
IP=$(kubectl  get svc nginx-plus -n nginx --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```


## Step 3 - Test the Configuration

Now we access the secure app using *curl* and check the certificate provided.

```console
curl --resolve tls-1.f5k8s.net:443:$IP https://tls-1.f5k8s.net -v
```

```text
 SSL connection using TLSv1.3 / AEAD-AES256-GCM-SHA384
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: CN=*.f5k8s.net             <=======  Cert
*  start date: Aug  7 16:12:21 2023 GMT
*  expire date: Nov  5 16:12:20 2023 GMT
*  subjectAltName: host "tls-1.f5k8s.net" matched cert's "*.f5k8s.net"
*  issuer: C=US; O=Let's Encrypt; CN=R3


hello from F5K8S pod secure-app-1-5548c9d54b-bz9ms
```


Now we access the secure app using *curl* and check the certificate provided.

```console
* SSL connection using TLSv1.3 / AEAD-AES256-GCM-SHA384
* ALPN: server accepted http/1.1
* Server certificate:   
*  subject: CN=*.f5demo.cloud                   <======  Cert
*  start date: Aug  7 16:13:47 2023 GMT
*  expire date: Nov  5 16:13:46 2023 GMT
*  subjectAltName: host "tls-2.f5demo.cloud" matched cert's "*.f5demo.cloud"
*  issuer: C=US; O=Let's Encrypt; CN=R3
*  SSL certificate verify ok.


curl --resolve tls-2.f5demo.cloud:443:$IP https://tls-2.f5demo.cloud/ -v
```

```text
hello from F5CLOUD pod secure-app-2-649d98554d-jvdst0
```