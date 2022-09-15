# Integration with Nginx Ingress Controller
In this section we provide examples for the most common use-cases of IngressLink with F5 CIS
- [IngressLink with static IP](cis-crd/IngressLink/#staticip)
- [IngressLink with dynamic IP](cis-crd/IngressLink/#dynamicip)


F5 IngressLink is the first true integration between BIG-IP and NGINX technologies. F5 IngressLink was built to support customers with modern, container application workloads that use both BIG-IP Container Ingress Services and NGINX Ingress Controller for Kubernetes. It’s an elegant control plane solution that offers a unified method of working with both technologies from a single interface—offering the best of BIG-IP and NGINX and fostering better collaboration across NetOps and DevOps teams. The diagram below demonstrates this use-case.

<img src="ingresslink.png">



### How does it work
IngressLink specification contains a label selector. The same label needs to exist on the service that is publishing the NGINX+ Ingress Controller. Only when there is a match, CIS will create a Layer 4 VirtualServer on the BIGP either with a staic or a dynamic IP address.

In the following manifests you can see the matchLabels selector on the IngressLink matching the label set on the NGINX+ service.
Eg: ingresslink.yml / nginx-svc.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: IngressLink
metadata:
  name: nginx-ingress
  namespace: nginx
spec:
  ipamLabel: "dev"
  selector:
    matchLabels:
      app: ingresslink    <==== Label to match
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-plus
  namespace: nginx
  labels:
    app: ingresslink     <==== Label on NGINX+ svc
spec:
  type: ClusterIP 
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    app: nginx-plus
```


## Configuration

Verify that the NGINX+ IC is running 


Deploy a new service that will contain the label which IngressLink will match. In this case we are using the following label `app: ingresslink`
```
kubectl apply -f svc_nginx.yaml
```

Deploy the IngressLink resource.
```
kubectl apply -f ingresslink.yaml
```


### 5. Create an IngressLink Resource

* Download the sample IngressLink Resource:

  ```curl -OL https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/doc/docs/config_examples/crd/IngressLink/ingresslink.yaml```

* Update the "virtualServerAddress" parameter in the ingresslink.yaml resource. This IP address will be used to configure the BIG-IP device. It will be used to accept traffic and load balance it among the NGINX Ingress Controller pods.

  ```kubectl apply -f ingresslink.yaml```

##### Note:
1. The name of the app label selector in IngressLink resource should match the labels of the service which exposes the NGINX Ingress Controller.
2. The service which exposes the NGINX Ingress Controller should be of type nodeport.

### 6. Test the Integration

Now to test the integration let's deploy a sample application.

    kubectl apply -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/doc/docs/config_examples/crd/IngressLink/ingress-example/cafe.yaml
    kubectl apply -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/doc/docs/config_examples/crd/IngressLink/ingress-example/cafe-secret.yaml
    kubectl apply -f https://raw.githubusercontent.com/F5Networks/k8s-bigip-ctlr/doc/docs/config_examples/crd/IngressLink/ingress-example/cafe-ingress.yaml

The Ingress Controller pods are behind the IP configured in Step 5 (virtualServerAddress parameter).

Let's test the traffic (in this example we used 192.168.10.5 as our VirtualServerAddress):

    $ curl --resolve cafe.example.com:443:192.168.10.5 https://cafe.example.com:443/coffee --insecure
    Server address: 10.12.0.18:80
    Server name: coffee-7586895968-r26zn
    ...

Also, if you check the status of the cafe-ingress, you will see the IP of the VirtualServerAddress (in this example we used 192.168.10.5 as our VirtualServerAddress):
```
$ kubectl get ing cafe-ingress
NAME           HOSTS              ADDRESS         PORTS     AGE
cafe-ingress   cafe.example.com   192.168.10.5    80, 443   115s
```