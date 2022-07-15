# Ingress Examples

In this section we provide examples for the most common use-cases of Ingress Resources with F5 CIS

- [Basic-Ingress](basic-ingress)
- [FQDN-Based-Routing](host-routing)
- [Fan-out/Path-Based-Routing](fanout)
- [Health Monitor](health-monitor)
- [AppRoot/URL Rewrite](rewrite)
- [TLS Ingress Examples](tls)

Before starting with the examples below, please make sure of the following:

-- Apps are running on the default namespace. --
```
kubectl get pod -n default

#### Expected  Result #####
NAME                     READY   STATUS    
app1-676746bb5c-4h26n    1/1     Running   
app1-676746bb5c-thph5    1/1     Running   
app2-78c95bccb5-6r85l    1/1     Running   
app2-78c95bccb5-9r2qx    1/1     Running  
echo-7449946fc7-hg4ff    1/1     Running   
echo-7449946fc7-nn82f    1/1     Running  
myapp-6cc75dfc85-755qb   1/1     Running 
myapp-6cc75dfc85-z6cst   1/1     Running

```

-- CIS is running --
```
kubectl get pod -n kube-system | grep f5

#### Expected  Result #####
NAME                              READY   STATUS  
f5-cis-crd-588bc4844f-64qjv       1/1     Running   
f5-cis-ingress-84856fd767-rnwd5   1/1     Running  
f5-ipam-5bf9fbdb5-dzqwd            1/1     Running   

```
