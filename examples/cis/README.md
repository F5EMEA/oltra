# Reverse Proxy capabilities with CIS

In this section we will be exploring the most common use-cases for the four ways that CIS can be configured for in order to publish Kubernetes services. These include:
- [Ingress Resources](#ingress-resource-examples)
- [VirtualServer CRDs](#virtualserver-crd-examples)
- [TransportServer CRDs](#transportserver-crd-examples)
- [Service Type LoadBalancer](#service-type-loadbalancer-examples)
- [IngressLink](#ingresslink-examples)
- [EDNS](#edns-examples)

<p align="center">
  <img src="cis.png" style="width:100%">
</p>

## Ingress Resource examples
In this section we provide examples for the most common use-cases of Ingress Resources with F5 CIS

* [Basic Ingress](ingress/basic-ingress)
* [Host based routing](ingress/host-routing)
* [Path based routing](ingress/fanout)
* [Health Monitors](ingress/health-monitor)
* [Rewrite](ingress/rewrite)
* [TLS Ingress](ingress/tls)

## VirtualServer CRD examples
In this section we provide examples for the most common use-cases of VirtualServer CRDs with F5 CIS

* [Basic VirtualServer ](crd/VirtualServer/Basic/)
* [Wildcard VirtualServer ](crd/VirtualServer/Wildcard/)
* [Host based routing](crd/VirtualServer/HostGroup)
* [Rewrite](crd/VirtualServer/Rewrite/)
* [HTTP Redirect](crd/VirtualServer/httpTraffic/)
* [Dynamic IP Allocation (IPAM)](crd/VirtualServer/IpamLabel)
* [Health Monitors](crd/VirtualServer/HealthMonitor)
* [Wildcard Hostname](crd/VirtualServer/Wildcard)
* [TLS VirtualServer](crd/VirtualServer/TLS-Termination/)
* [Using iRules ](crd/VirtualServer/PolicyCRD/README.md#iRules)
* [Managing Persistence](crd/VirtualServer/PolicyCRD/README.md#Persistence)
* [Custom HTTP Profile](crd/VirtualServer/PolicyCRD/README.md#custom-http-profile)
* [Enable WAF Policies](crd/VirtualServer/PolicyCRD/README.md#waf-policies)
* [VirtualServer with custom Port](crd/VirtualServer/CustomPort/)
* [VirtualServer with IPv6 Address](crd/VirtualServer/IPv6/)


## TransportServer CRD examples
In this section we provide examples for the most common use-cases of TransportServer CRDs with F5 CIS
- [TCP TransportServer](crd/TransportServer/#tcp-transport-server)
- [TCP TransportServer with IPAM](crd/TransportServer/#tcp-transport-server-with-ipam)
- [UDP TransportServer](crd/TransportServer/#udp-transport-server)

## Service Type LoadBalancer examples
In this section we provide examples for the most common use-cases of service type LoadBalancer with F5 CIS
- [Service Type LoadBalancer](crd/serviceTypeLB/#service-type-loadbalancer)
- [Multiport Type LoadBalancer](crd/serviceTypeLB/#create-multiport-type-loadbalancer)
- [Service Type LoadBalancer with Health monitor](crd/serviceTypeLB/#service-type-loadbalancer-with-health-monitor)

## IngressLink examples
In this section we provide examples for the most common use-cases of IngressLink with F5 CIS
- [IngressLink with static IP](crd/IngressLink/#staticip)
- [IngressLink with dynamic IP](crd/IngressLink/#dynamicip)

## EDNS examples
In this section we provide examples for the most common use-cases of ExternalDNS with F5 CIS
- [Publish FQDN](crd/ExternalDNS/#publish-FQDN)
