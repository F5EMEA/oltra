# CIS CRDs
In this section we will be exploring the different CRDs provided by CIS. These include:

- [VirtualServer CRDs](#virtualserver-crd-examples)
- [TransportServer CRDs](#transportserver-crd-examples)
- [Service Type LoadBalancer](#service-type-loadbalancer-examples)
- [IngressLink](#ingresslink-examples)
- [EDNS](#edns-examples)


## VirtualServer CRD examples
In this section we provide examples for the most common use-cases of VirtualServer CRDs with F5 CIS

* [Basic VirtualServer ](VirtualServer/Basic/)
* [Wildcard VirtualServer ](VirtualServer/Wildcard/)
* [Host based routing](VirtualServer/HostGroup)
* [Rewrite](VirtualServer/Rewrite/)
* [HTTP Redirect](VirtualServer/httpTraffic/)
* [Dynamic IP Allocation (IPAM)](VirtualServer/IpamLabel)
* [Health Monitors](VirtualServer/HealthMonitor)
* [Wildcard Hostname](VirtualServer/Wildcard)
* [TLS VirtualServer](VirtualServer/TLS-Termination/)
* [Using iRules ](VirtualServer/PolicyCRD/README.md#iRules)
* [Managing Persistence](VirtualServer/PolicyCRD/README.md#Persistence)
* [Custom HTTP Profile](VirtualServer/PolicyCRD/README.md#custom-http-profile)
* [Enable WAF Policies](VirtualServer/PolicyCRD/README.md#waf-policies)
* [VirtualServer with custom Port](VirtualServer/CustomPort/)
* [VirtualServer with IPv6 Address](VirtualServer/IPv6/)


## TransportServer CRD examples
In this section we provide examples for the most common use-cases of TransportServer CRDs with F5 CIS
- [TCP TransportServer](TransportServer/#tcp-transport-server)
- [TCP TransportServer with IPAM](TransportServer/#tcp-transport-server-with-ipam)
- [UDP TransportServer](TransportServer/#udp-transport-server)

## Service Type LoadBalancer examples
In this section we provide examples for the most common use-cases of service type LoadBalancer with F5 CIS
- [Service Type LoadBalancer](serviceTypeLB/#service-type-loadbalancer)
- [Multiport Type LoadBalancer](serviceTypeLB/#create-multiport-type-loadbalancer)
- [Service Type LoadBalancer with Health monitor](serviceTypeLB/#service-type-loadbalancer-with-health-monitor)

## IngressLink examples
In this section we provide examples for the most common use-cases of IngressLink with F5 CIS
- [IngressLink with static IP](IngressLink/#staticip)
- [IngressLink with dynamic IP](IngressLink/#dynamicip)


## EDNS examples
In this section we provide examples for the most common use-cases of ExternalDNS with F5 CIS
- [Publish FQDN](ExternalDNS/#publish-fqdn)
