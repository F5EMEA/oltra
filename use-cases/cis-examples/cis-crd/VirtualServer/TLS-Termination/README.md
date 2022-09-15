# Secure TLS Virtual Server
This section demonstrates the three option to configure VirtualServer TLS termination:
 - [Edge TLS](#edge-tls-termination)
 - [Re-Encrypt TLS](#re-encrypt-tls-termination)
 - [Passthrough TLS](#passthrough-tls-termination)
 - [Certificate as K8s secret](#certificate-as-k8s-secret)


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
    - edge.f5demo.local
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
  host: edge.f5demo.local
  tlsProfileName: edge-tls
  virtualServerAddress: 10.1.10.68
  virtualServerName: "edge-tls-vs"
  pools:
      path: /
      service: echo-svc
      servicePort: 80
```

Access the terminal on the VS Code.
<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:20%">

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f edge-tls.yml
kubectl apply -f edge-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs edge-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -vk https://edge.f5demo.local/ --resolve edge.f5demo.local:443:10.1.10.68
```

## Re-Encrypt TLS Termination
This section demonstrates how to configure VirtualServer with re-encrypt TLS termination.
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
    - reencrypt.f5demo.local
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
  host: reencrypt.f5demo.local
  tlsProfileName: reencrypt-tls
  virtualServerAddress: 10.1.10.69
  virtualServerName: "reencrypt-tls-vs"
  pools:
      path: /
      service: echo-svc
      servicePort: 80
```

Access the terminal on the VS Code.
<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:20%">

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f reencrypt-tls.yml
kubectl apply -f reencrypt-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs reencrypt-tls-vs
```

Access the `secure-app` service using the following example. 
```
curl -vk https://reencrypt.f5demo.local/ --resolve reencrypt.f5demo.local:443:10.1.10.69
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
    - passthrough.f5demo.local
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
  host: passthrough.f5demo.local
  tlsProfileName: passthrough-tls
  virtualServerAddress: 10.1.10.70
  virtualServerName: "passthrough-tls-vs"
  pools:
      path: /
      service: echo-svc
      servicePort: 80
```

Access the terminal on the VS Code.
<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:20%">

Change the working directory to `TLS-Termination`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/TLS-Termination
```

Create the TLSProfile and VirtualServer resources.
```
kubectl apply -f passthrough-tls.yml
kubectl apply -f passthrough-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs passthrough-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -vk https://passthrough.f5demo.local/ --resolve passthrough.f5demo.local:443:10.1.10.70
```

## Certificate as K8s secret
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
    - k8s.f5demo.local
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: k8s-tls-vs
  namespace: default
spec:
  host: k8s.f5demo.local
  virtualServerAddress: 10.1.10.71
  virtualServerName: "k8s-tls-vs"
  tlsProfileName: k8s-tls
  pools:
    - path: /
      service: echo-svc
      servicePort: 80
```

Access the terminal on the VS Code.
<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:20%">

Create the K8s secret, TLSProfile and VirtualServer resources.
```
kubectl apply -f reference-secret.yml
kubectl apply -f reference-tls.yml
kubectl apply -f reference-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs k8s-tls-vs
```

Access the `echo-svc` service using the following example. 
```
curl -vk https://k8s.f5demo.local/ --resolve k8s.f5demo.local:443:10.1.10.71
```
