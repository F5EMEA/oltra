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

-- CIS and IPAM are running --
```
kubectl get pod -n bigip | grep f5

#### Expected  Result #####
NAME                              READY   STATUS  
f5-cis-crd-588bc4844f-64qjv       1/1     Running   
f5-cis-ingress-84856fd767-rnwd5   1/1     Running  
f5-ipam-5bf9fbdb5-dzqwd           1/1     Running   
```

If not deploy CIS and IP from the setup folder.
```
kubectl apply -f ~/oltra/setup/cis
```


