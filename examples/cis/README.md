# Reverse Proxy capabilities with CIS

In this section we will be exploring five modes that CIS can be configured for in order to publish Kubernetes services; Ingress and VirtualServer CRD.
The following examples can be used to demonstrate the most common functionality for Ingress Services with CIS. The examples include:
- Ingress Resource examples
- VirtualServer CRD examples
- TransportServer CRD examples
- Service Type LoadBalancer examples
- EDNS examples

<p align="center">
  <img src="cis.png" style="width:85%">
</p>

## Ingress Resource examples

In this section we provide examples for the most common use-cases of Ingress Resources with F5 CIS

* [Basic Ingress](cis-ingress/basic-ingress)
* [Host based routing](cis-ingress/host-routing)
* [Path based routing](cis-ingress/fanout)
* [Health Monitors](cis-ingress/health-monitor)
* [Rewrite](cis-ingress/rewrite)
* [TLS Ingress](cis-ingress/tls)

## VirtualServer CRD examples

* [Basic VirtualServer ](cis-crd/VirtualServer/Basic/)
* [Host based routing](cis-crd/VirtualServer/HostGroup)
* [Rewrite](cis-crd/VirtualServer/PathRewrite/)
* [HTTP Redirect](cis-crd/VirtualServer/hhtpTraffc/)
* [Dynamic IP Allocation (IPAM)](cis-crd/VirtualServer/IpamLabel)
* [Health Monitors](cis-crd/VirtualServer/HealthMonitor)
* [Wildcard Hostname](cis-crd/VirtualServer/Wildcard)
* [TLS VirtualServer](cis-crd/VirtualServer/TLS-termination/)
* [Using iRules ](cis-crd/VirtualServer/PolicyCRD/#policycrd-iRules)
* [Managing Persistence](cis-crd/VirtualServer/PolicyCRD/#policycrd-persistence)
* [Custom HTTP Profile](cis-crd/VirtualServer/PolicyCRD/#policycrd-xff)
* [VirtualServer with custom Port](cis-crd/VirtualServer/CustomPort/)

## TransportServer CRD examples


## Service Type LoadBalancer examples


## EDNS examples
