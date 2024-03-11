# Secure TLS Virtual Server
This section demonstrates the four options to configure VirtualServer TLS termination:
 - [Edge TLS](#edge-tls-termination)
 - [Re-Encrypt TLS](#re-encrypt-tls-termination)
 - [Passthrough TLS](#passthrough-tls-termination)
 - [Certificate as K8s secret](#certificate-as-k8s-secret)

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

## Edge TLS Termination 
This section demonstrates how to configure VirtualServer with edge TLS termination.
For this configuration we will need 2 custom resources; TLSProfile and VirtualServer. Please find the yaml examples below

Eg: edge-tls.yml / edge-vs.yml
```yml
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  name: edge-tls
  labels:
    f5cr: "true"
spec:
  hosts:
    - edge.f5k8s.net
  tls:
    termination: edge
    clientSSL: /Common/clientssl
    reference: bigip
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: edge-tls-vs
spec:
  host: edge.f5k8s.net
  tlsProfileName: edge-tls
  virtualServerAddress: 10.1.10.68
  virtualServerName: "edge-tls-vs"
  pools:
      path: /
      service: echo-svc
      servicePort: 80
```

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f edge-tls.yml
kubectl apply -f edge-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs edge-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -vk https://edge.f5k8s.net/
```

Verify that the Pod that we are load balancing listens on HTTP and not HTTPS
```
< HTTP/1.1 200 OK
< Date: Tue, 17 Jan 2023 13:25:24 GMT
< Server: Apache/2.4.51 (Debian)
< X-Powered-By: PHP/8.1.0
< Content-Length: 389
< Content-Type: application/json
< Set-Cookie: BIGipServer~cis-crd~Shared~echo_svc_80_default_edge_f5demo_local=2044457994.20480.0000; path=/; Httponly; Secure
< 
{
  "Server Name": "edge.f5k8s.net",
  "Server Address": "10.244.219.121",
  "Server Port": "80",                    <========  Plain HTTP 
  "Request Method": "GET",
  "Request URI": "/",
  "Query String": "",
  "Headers": [{"host":"edge.f5k8s.net","user-agent":"curl\/7.58.0","accept":"*\/*"}],
  "Remote Address": "10.1.20.5",
  "Remote Port": "33955",
  "Timestamp": "1673961924",
  "Data": "0"
}

```

***Clean up the environment (Optional)***
```
kubectl delete -f edge-tls.yml
kubectl delete -f edge-vs.yml
```

## Re-Encrypt TLS Termination
This section demonstrates how to configure VirtualServer with re-encrypt TLS termination. Please notice that the pod listens on port `8443` that runs on top of SSL.
For this configuration we will need 2 custom resources; TLSProfile and VirtualServer. Please find the yaml examples below

Eg: re-encrypt-tls.yml / re-encrypt-vs.yml
```yml
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  name: reencrypt-tls
  labels:
    f5cr: "true"
spec:
  hosts:
    - reencrypt.f5k8s.net
  tls:
    termination: reencrypt
    clientSSL: /Common/clientssl
    serverSSL: /Common/serverssl
    reference: bigip
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: reencrypt-tls-vs
spec:
  host: reencrypt.f5k8s.net
  tlsProfileName: reencrypt-tls
  virtualServerAddress: 10.1.10.69
  virtualServerName: "reencrypt-tls-vs"
  pools:
  - path: /
    service: secure-app
    servicePort: 8443
```

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f reencrypt-tls.yml
kubectl apply -f reencrypt-vs.yml
```

Confirm that the VirtualServer resource is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs reencrypt-tls-vs
```

Access the `secure-app` service using the following example. 
```
curl -k https://reencrypt.f5k8s.net/ 
```

Verify that the pod responded with the following text 
```
hello from pod secure-app-8cb576989-vnvh7
```

***Clean up the environment (Optional)***
```
kubectl delete -f reencrypt-tls.yml
kubectl delete -f reencrypt-vs.yml
```

## Passthrough TLS Termination
This section demonstrates how to configure VirtualServer with passthrough TLS termination.
For this configuration we will need 2 custom resources; TLSProfile and VirtualServer. Please find the yaml examples below

Eg: passthrough-tls.yml / passthrough-vs.yml
```yml
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  name: passthrough-tls
  labels:
    f5cr: "true"
spec:
  hosts:
    - passthrough.f5k8s.net
  tls:
    termination: passthrough
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: passthrough-tls-vs
spec:
  host: passthrough.f5k8s.net
  tlsProfileName: passthrough-tls
  virtualServerAddress: 10.1.10.70
  virtualServerName: "passthrough-tls-vs"
  pools:
  - path: /
    service: secure-app
    servicePort: 8443
```

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.


Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f passthrough-tls.yml
kubectl apply -f passthrough-vs.yml
```

Confirm that the VirtualServer resource is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs passthrough-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -k https://passthrough.f5k8s.net/ 
```

Verify that the pod responded with the following text 
```
hello from pod secure-app-8cb576989-vnvh7
```

***Clean up the environment (Optional)***
```
kubectl delete -f passthrough-tls.yml
kubectl delete -f passthrough-vs.yml
```

## Certificate as K8s secret with TLS Edge
This section demonstrates how to configure VirtualServer with edge TLS termination and the certificate stored as K8s secret.
For this configuration we will need 1 secret to hold the TLS certificate and 2 custom resources; TLSProfile and VirtualServer. Please find the yaml examples below

Eg: reference-secret.yml / reference-tls.yml / reference-vs.yml
```yml
apiVersion: v1
kind: Secret
metadata:
  name: k8s-tls-secret
  namespace: default
data:
  tls.crt: certificate_in_base64.........
  tls.key: key_in_base64.................
type: kubernetes.io/tls
---
apiVersion: cis.f5.com/v1
kind: TLSProfile
metadata:
  name: k8s-tls
  labels:
    f5cr: "true"
spec:
  tls:
    termination: edge
    clientSSL: k8s-tls-secret
    reference: secret
  hosts:
    - k8s-tls.f5k8s.net
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: k8s-tls-vs
  namespace: default
spec:
  host: k8s-tls.f5k8s.net
  virtualServerAddress: 10.1.10.71
  virtualServerName: "k8s-tls-vs"
  tlsProfileName: k8s-tls
  pools:
    - path: /
      service: echo-svc
      servicePort: 80
```
Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```

> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.


Create the K8s secret, TLSProfile and VirtualServer resources.
```
kubectl apply -f reference-secret.yml
kubectl apply -f reference-tls.yml
kubectl apply -f reference-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs k8s-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -k https://k8s-tls.f5k8s.net/
```

Verify that the Pod that we are load balancing listens on HTTP and not HTTPS

```
< HTTP/1.1 200 OK
< Date: Tue, 17 Jan 2023 13:25:24 GMT
< Server: Apache/2.4.51 (Debian)
< X-Powered-By: PHP/8.1.0
< Content-Length: 389
< Content-Type: application/json
< Set-Cookie: BIGipServer~cis-crd~Shared~echo_svc_80_default_edge_f5demo_local=2044457994.20480.0000; path=/; Httponly; Secure
< 
{
  "Server Name": "k8s-tls.f5k8s.net",
  "Server Address": "10.244.219.121",
  "Server Port": "80",                    <========  Plain HTTP 
  "Request Method": "GET",
  "Request URI": "/",
  "Query String": "",
  "Headers": [{"host":"k8s-tls.f5k8s.net","user-agent":"curl\/7.58.0","accept":"*\/*"}],
  "Remote Address": "10.1.20.5",
  "Remote Port": "33955",
  "Timestamp": "1673961924",
  "Data": "0"
}

```


***Clean up the environment (Optional)***
```
kubectl delete -f reference-secret.yml
kubectl delete -f reference-tls.yml
kubectl delete -f reference-vs.yml
```