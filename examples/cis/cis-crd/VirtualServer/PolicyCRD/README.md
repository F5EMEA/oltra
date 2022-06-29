# PolicyCRD Examples

Policy is used to apply existing BIG-IP profiles and policy with Virtual Server and Transport server. The Policy CRD resource defines the profile configuration for a virtual server in BIG-IP.

This section demonstrates the deployment of a Virtual Server with custom HTTP, Persistence, iRule and WAF Profiles with PolicyCRD.

- [PolicyCRD XFF](#policycrd-xff)
- [PolicyCRD WAF](#policycrd-persistence)
- [PolicyCRD WAF](#policycrd-iRule)
- [PolicyCRD WAF](#policycrd-waf)

## PolicyCRD XFF
This section demonstrates the deployment of a Virtual Server with a custom HTTP Profiles that add XFF header.

Eg: policy-vs /policy-crd 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: policy-xff
spec:
  profiles:
    http: /Common/http-xff
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: xff-policy-vs
spec:
  virtualServerAddress: 10.1.10.97
  host: policy.f5demo.local
  policyName: policy-xff
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resources.
```
kubectl apply -f xff-policy.yml
kubectl apply -f vs-with-policy-xff.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP we created a profile called `http-xff` on the common partition that adds the client IP as an HTTP header (x-forwarded-for) before forading the transaction to the backend. This profile has been reference on the PolicyCRD.

Access the service using the following example. 
```
curl -v http://policy.f5demo.local/ --resolve policy.f5demo.local:80:10.1.10.97
```

Verify that the `x-forwarded-for` Header exists and contains the client's actual IP


## PolicyCRD persistence
The default persistence that is configured with CIS is **/Common/cookie**. In this section we will demonstrate the deployment of a Virtual Server with persistence profile set to **None**.

Eg: VirtualServer / PolicyCRD 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: persistence-policy
spec:
  profiles:
    persistenceProfile: none
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: persistence-policy-vs
spec:
  virtualServerAddress: 10.1.10.198
  host: persistence.f5demo.local
  policyName: persistence-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f persistence-policy.yml
kubectl apply -f vs-with-policy-persistence.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

Access the service few times using the following example.
```
curl -v http://persistence.f5demo.local/ --resolve persistence.f5demo.local:80:10.1.10.198
curl -v http://persistence.f5demo.local/ --resolve persistence.f5demo.local:80:10.1.10.198
curl -v http://persistence.f5demo.local/ --resolve persistence.f5demo.local:80:10.1.10.198
```

Verify that the transactions are actually going to multiple backend pods and they dont persist on a single one.



## PolicyCRD iRule
This section demonstrates the deployment of a Virtual Server with a iRules to provide a **Sorry Page**.

Eg: VirtualServer / PolicyCRD 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: irule-policy
spec:
  iRules:
    insecure: /Common/sorry-page
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: irule-policy-vs
spec:
  virtualServerAddress: 10.1.10.199
  host: irule.f5demo.local
  policyName: irule-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f irule-policy.yml
kubectl apply -f vs-with-policy-irule.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP we created an iRule  called **sorry-page**, on the Common Partition, that responds to the user with a "Sorry the page is under maintainance" This iRule has been reference on the PolicyCRD.

Access the service few times using the following example.
```
curl -v http://policy.f5demo.local/ --resolve policy.f5demo.local:80:10.1.10.199
```

Verify that the sorry page is sent back from BIGIP.



## PolicyCRD WAF
This section demonstrates the deployment of a Virtual Server with a WAF policy to protect against Layer 7 threats.

Eg: VirtualServer / PolicyCRD 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: waf-policy
spec:
  l7Policies:
    waf: /Common/basic_waf_policy
  profiles:
    http: /Common/http-xff
    logProfiles:
      - /Common/Log all requests
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: waf-policy-vs
spec:
  virtualServerAddress: 10.1.10.98
  host: waf.f5demo.local
  policyName: waf-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f waf-policy.yml
kubectl apply -f vs-with-policy-waf.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP we created a WAF policy **basic_waf_policy** to block HTTP attacks, so we expect BIGIP to mitigate any L7 attack (according to the WAF policy) that is executed to the services running in K8S. This WAF policy has been reference on the PolicyCRD.

Access the service using the following example that contains a XSS violations. 
```
curl -v "http://waf.f5demo.local/index.php?parameter=<script/>" --resolve waf.f5demo.local:80:10.1.10.98
```

Verify that the  transaction that contains the attack gets blocked by BIGIP WAF.
```html
<html>
  <head>
    <title>Request Rejected</title>
  </head>
  <body>
    The requested URL was rejected. Please consult with your administrator.<br><br>
    Your support ID is: 4045204596866416688<br><br>
    <a href='javascript:history.back();'>[Go Back]</a>
  </body>
</html>
```

