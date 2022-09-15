# ExternalDNS
In this section we provide examples for the most common use-cases of ExternalDNS with F5 CIS:
- [Publish FQDN](#publish-fqdn)

ExternalDNS is a Kubernetes add-on that allows you to control DNS records of F5 DNS servers with information about exposed Kubernetes services through VirtualServer, TransportServer or IngressLink CRDs.

### How does it work
ExternalDNS has on its specification the `host` parameter that defines the FQDN that user wants to publish. In order for CIS to establish a link between the ExternalDNS resources, that holds the wideIP information, and the VirtualServer, that holds the IP that the users should connect to, it looks for a match on Host parameter that exists on both resources. If a match is established, then CIS creates a `wideIP` on F5 DNS with the pool member IP being the VirtualServer IP address. The same applies for TransportServer and IngressLink.

In the following manifests you can see the host parameter on VirtualServer matching the host parameter on ExternalDNS.
```yml
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: sample-virtual
spec:
  host: www.f5demo.cloud       <==== Hostname (FQDN)
  virtualServerAddress: 10.1.10.240
  pools:
  - monitor:
      interval: 20
      recv: ""
      send: /
      timeout: 10
      type: http
    path: /
    service: svc-1
    servicePort: 80
```
An **ExternalDNS** Custom Resource must be created that will have the same hostname as with Custom Resource (VS/TS/IL) we created earlier.
```yml
apiVersion: "cis.f5.com/v1"
kind: ExternalDNS
metadata:
  name: exdns
  labels:
    f5cr: "true"
spec:
  domainName: www.f5demo.cloud     <==== Hostname matches with pervious CR
  dnsRecordType: A
  loadBalanceMethod: round-robin
  pools:
  - name: www-primary-k8s
    dnsRecordType: A
    loadBalanceMethod: round-robin
    dataServerName: /Common/GSLBServer
    monitor:
      type: https
      send: "GET /"
      recv: ""
      interval: 10
      timeout: 10
```

> Note: The `dataServerName` parameter, which in the above example has the value of `/Common/GSLBServer` referes to the BIGIP device that holds the VirtualServer that has been confiured through the CRDs. This is to be manual configured prior to the ExternalDNS configuration. More information on ExternalDNS can be found on <a href="https://clouddocs.f5.com/containers/latest/userguide/crd/externaldns.html">here</a>


## Publish FQDN
This section demonstrates how publish a DNS records of a service that is publish with TransportServer resource.

Eg: tcp-transport-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: TransportServer
metadata:
  labels:
    f5cr: "true"
  name: tcp-ts
spec:
  virtualServerAddress: "10.1.10.74"
  virtualServerPort: 80
  virtualServerName: tcp-ts
  mode: standard
  snat: auto
  pool:
    service: myapp-svc
    servicePort: 8080
    monitor:
      type: tcp
      interval: 3
      timeout: 10
```
1. Access the VS Code on the UDF

<p align="center">
  <img src="cicd.png" style="width:85%">
</p>


1. Change the working directory to `TransportServer`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/ExternalDNS
```

2. Deploy TransportServer for `app1-svc` with host vaule of `edns.f5demo.local`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/ExternalDNS/ts-fqdn.yml
```

3. Confirm that the TS CRD is deployed correctly. You should see `Ok` under the Status column for the TransportServer that was just deployed.
```
kubectl get ts edns-app1
```

4. Save the IP adresses that was assigned by the IPAM for this TS
```
IP=$(kubectl get ts edns-app1 --output=jsonpath='{.status.vsAddress}')
```

5. Try accessing the service as per the example below. 
```
curl http://$IP/
```

6. The output should be similar to:
```cmd
Server address: 10.244.140.103:8080
Server name: app1-6cc75dfc85-qhk5d
Date: 14/Jul/2022:06:17:19 +0000
URI: /
Request ID: 18c2b70bcca18c590a0125db04be5661
```
