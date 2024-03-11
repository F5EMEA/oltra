# Support for Type ExternalName Services
The Ingress Controller supports routing requests to services of the type [ExternalName](https://kubernetes.io/docs/concepts/services-networking/service/#externalname).

An ExternalName service is defined by an external DNS name that is resolved into the IP addresses, typically external to the cluster. This enables to use the Ingress Controller to route requests to the destinations outside of the cluster.

**Note:** This feature is only available in NGINX Plus.


## Prerequisites
To use ExternalName services, first you need to configure one or more resolvers using the ConfigMap. NGINX Plus will use those resolvers to resolve DNS names of the services. This is already configured on our NGINX Ingress Controller

For example, the following ConfigMap configures one resolver:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-config
  namespace: nginx-ingress
data:
  resolver-addresses: "10.0.0.10"
```

Additional resolver parameters, including the caching of DNS records, are available. Check the corresponding [ConfigMap](https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource/) section.

## Running the Example

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `externalname`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/externalname
```

## 1. Create the service
Create the service with the name `httpbin` that will map to the external service **httpbin.org**:
```
kubectl apply -f service.yaml
```

## 2. Create the Ingress
Create the Ingress to publish the service under **externalname.f5k8s.net**.
```
kubectl apply -f ingress.yaml
```

As a result, NGINX Plus will route requests for **externalname.f5k8s.net** to the website behind the DNS name **httpbin.org** that is defined on the service `httpbin`.


## 3. Compare the response if you access the website directly or through the ingress
Review the response you will get when you access the **httpbin.org** diretly or through the ingress 

Directly
```
curl httpbin.org/uuid -H "accept: application/json"
curl httpbin.org/stream/1 -H "accept: application/json"
```

Through Ingress
curl externalname.f5k8s.net/uuid -H "accept: application/json"
curl externalname.f5k8s.net/stream/1 -H "accept: application/json"

The only difference should be on the hostname .

