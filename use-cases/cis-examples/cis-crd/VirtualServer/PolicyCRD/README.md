# PolicyCRD Examples

Policy is used to apply existing BIG-IP profiles and policy with Virtual Server and Transport server. The Policy CRD resource defines the profile configuration for a virtual server in BIG-IP.

This section demonstrates the deployment of a Virtual Server with custom HTTP, Persistence, iRule and WAF Profiles with PolicyCRD.

- [HTTP Profile](#custom-http-profile)
- [Persistence](#persistence)
- [iRules](#iRules)
- [WAF Policies](#waf-policies)

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

## Custom HTTP Profile
This section demonstrates the deployment of a Virtual Server with a custom HTTP Profiles that add XFF header.

Eg: xff-policy.yml / vs-with-policy-xff.yml
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
  virtualServerAddress: 10.1.10.66
  host: policy.f5k8s.net
  policyName: policy-xff
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Change the working directory to `PolicyCRD`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/PolicyCRD
```

> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the PolicyCRD and VirtualServerCRD resources.
```
kubectl apply -f xff-policy.yml
kubectl apply -f vs-with-policy-xff.yml
```

Confirm that the VirtualServer resources is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

On the BIGIP we created a profile called `http-xff` on the common partition that adds the client IP as an HTTP header (x-forwarded-for) before forading the transaction to the backend. This profile has been reference on the PolicyCRD.

Access the service using the following example. 
```
curl http://policy.f5k8s.net/ 
```

Verify that the `x-forwarded-for` Header exists and contains the client's actual IP
```json

{
   "Project": "My Echo Project",
   "Project": "https://github.com/skenderidis/docker-images/echo",
   "Server Address": "10.244.140.117",
   "Server Port": "80",
   "Request Method": "GET",
   "Request URI": "/",
   "Query String": "",
   "Headers": [{"x-forwarded-for":"10.1.10.4","accept":"*\/*","user-agent":"curl\/7.58.0","host":"policy.f5k8s.net","content-length":"","content-type":""}],  <-----x-forwarded-for
   "Remote Address": "10.1.20.5",
   "Remote Port": "51082",
   "Timestamp": "1692863626",
   "Data": "0"
}
```

***Clean up the environment (Optional)***
```
kubectl delete -f xff-policy.yml
kubectl delete -f vs-with-policy-xff.yml
```

## Persistence
The default persistence that is configured with CIS is **/Common/cookie**. In this section we will demonstrate the deployment of a Virtual Server with persistence profile set to **None**.

Eg: persistence-policy.yml / vs-with-policy-persistence.yml 
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
  virtualServerAddress: 10.1.10.64
  host: persistence.f5k8s.net
  policyName: persistence-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Change the working directory to `PolicyCRD`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/PolicyCRD
```

> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f persistence-policy.yml
kubectl apply -f vs-with-policy-persistence.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

Access the service few times using the following example.
```
curl http://persistence.f5k8s.net/ 
```

Verify that the transactions are actually going to multiple backend pods and they dont persist on a single one.
```json
{
  "Server Name": "persistence.f5k8s.net",
  "Server Address": "10.244.219.102",    <=========  POD IP
  "Server Port": "80",
  "Request Method": "GET",
  "Request URI": "/",
  "Query String": "",
  "Headers": [{"host":"persistence.f5k8s.net","user-agent":"curl\/7.58.0","accept":"*\/*"}],
  "Remote Address": "10.1.20.5",
  "Remote Port": "55764",
  "Timestamp": "1673876853",
  "Data": "0"
}
```
***Clean up the environment (Optional)***
```
kubectl delete -f persistence-policy.yml
kubectl delete -f vs-with-policy-persistence.yml
```

## iRules
This section demonstrates the deployment of a Virtual Server with a iRules to provide a **Sorry Page**.

Eg: irule-policy.yml / vs-with-policy-irule.yml 
```yml
apiVersion: cis.f5.com/v1
kind: Policy
metadata:
  labels:
    f5cr: "true"
  name: irule-policy
spec:
  iRules:
    insecure: /Common/sorry_page
---
apiVersion: cis.f5.com/v1
kind: VirtualServer
metadata:
  labels:
    f5cr: "true"
  name: irule-policy-vs
spec:
  virtualServerAddress: 10.1.10.63
  host: irule.f5k8s.net
  policyName: irule-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Change the working directory to `PolicyCRD`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/PolicyCRD
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f irule-policy.yml
kubectl apply -f vs-with-policy-irule.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

On the BIGIP we created an iRule  called **sorry-page**, on the Common Partition, that responds to the user with a "Sorry the page is under maintainance" This iRule has been reference on the PolicyCRD.

Access the service few times using the following example.
```
curl http://irule.f5k8s.net/
```

Verify that the sorry page is sent back from BIGIP.

***Clean up the environment (Optional)***
```
kubectl delete -f irule-policy.yml
kubectl delete -f vs-with-policy-irule.yml
```

## WAF Policies
This section demonstrates the deployment of a Virtual Server with a WAF policy to protect against Layer 7 threats.

Eg: waf-policy.yml / vs-with-policy-waf.yml
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
  virtualServerAddress: 10.1.10.65
  host: waf.f5k8s.net
  policyName: waf-policy
  snat: auto
  pools:
    path: /
    service: echo-svc
    servicePort: 80
```

Change the working directory to `PolicyCRD`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/PolicyCRD
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the PolicyCRD and VirtualServerCRD resource.
```
kubectl apply -f waf-policy.yml
kubectl apply -f vs-with-policy-waf.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

On the BIGIP we created a WAF policy **basic_waf_policy** to block HTTP attacks, so we expect BIGIP to mitigate any L7 attack (according to the WAF policy) that is executed to the services running in K8S. This WAF policy has been reference on the PolicyCRD.

Access the service using the following example that contains a XSS violations. 
```
curl "http://waf.f5k8s.net/index.php?parameter=<script/>"
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

***Clean up the environment (Optional)***
```
kubectl delete -f waf-policy.yml
kubectl delete -f vs-with-policy-waf.yml
```