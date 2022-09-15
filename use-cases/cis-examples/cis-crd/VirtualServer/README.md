# Ingress Examples
In this section we provide examples for the most common use-cases of VirtualServer CRDs with F5 CIS

* [Basic VirtualServer ](Basic)
* [Wildcard VirtualServer ](Wildcard)
* [Host based routing](HostGroup)
* [Rewrite](Rewrite)
* [HTTP Redirect](httpTraffic)
* [Dynamic IP Allocation (IPAM)](IpamLabel)
* [Health Monitors](HealthMonitor)
* [Wildcard Hostname](Wildcard)
* [TLS VirtualServer](TLS-Termination)
* [Using iRules ](PolicyCRD/README.md#iRules)
* [Managing Persistence](PolicyCRD/README.md#Persistence)
* [Custom HTTP Profile](PolicyCRD/README.md#custom-http-profile)
* [Enable WAF Policies](PolicyCRD/README.md#waf-policies)
* [VirtualServer with custom Port](CustomPort)
* [VirtualServer with IPv6 Address](IPv6)


Before starting with the examples below, please make sure of the following:

-- Apps are running on the default namespace. --
```
kubectl get pod -n default

#### Expected  Result #####
NAME                         READY   STATUS    RESTARTS      AGE
app1-676746bb5c-7c8sb        1/1     Running   2 (51m ago)   5d
app1-676746bb5c-ncrzc        1/1     Running   2 (39m ago)   5d
app2-78c95bccb5-gc7xv        1/1     Running   2 (39m ago)   5d
app2-78c95bccb5-jvfnr        1/1     Running   2 (39m ago)   5d
coffee-v1-75869cf7ff-2hlm9   1/1     Running   2 (39m ago)   5d
coffee-v2-67499ff985-bb5kh   1/1     Running   2 (59m ago)   5d
coredns-bb6d6cc4f-c4dc9      1/1     Running   2 (59m ago)   5d
coredns-bb6d6cc4f-rb8g8      1/1     Running   2 (39m ago)   5d
echo-7449946fc7-nrwrl        1/1     Running   2 (39m ago)   5d
echo-7449946fc7-wjm46        1/1     Running   2 (59m ago)   5d
myapp-6cc75dfc85-msntl       1/1     Running   2 (39m ago)   5d
myapp-6cc75dfc85-qhk5d       1/1     Running   2 (39m ago)   5d
secure-app-8cb576989-b42zc   1/1     Running   2 (59m ago)   5d
tea-6fb46d899f-qsg6k         1/1     Running   2 (39m ago)   5d
tea-post-648dfcdd6c-gmt9v    1/1     Running   2 (39m ago)   5d
```

-- CIS is running --
```
kubectl get pod -n kube-system | grep f5

#### Expected  Result #####
NAME                              READY   STATUS  
f5-cis-crd-588bc4844f-64qjv       1/1     Running   
f5-cis-ingress-84856fd767-rnwd5   1/1     Running  
f5-ipam-5bf9fbdb5-dzqwd           1/1     Running   

```


