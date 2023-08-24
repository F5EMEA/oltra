# Using custom ports

This section demonstrates the option to configure VirtualAddress with custom HTTP/HTTPS port numbers.  
For this example section CIS will create a Virtual Server on BIG-IP with custom port (8080). To achieve this we will add `virtualServerHTTPPort` parameter on the VirtualServer resource with the port that we want BIGIP VIP to listen to. 

Eg: reference-vs.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: custom-port-http-vs
  labels:
    f5cr: "true"
spec:
  host: custom-port.f5k8s.net
  virtualServerAddress: "10.1.10.57"
  virtualServerName: "custom-port-http-vs"
  virtualServerHTTPPort: 8080
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```
> **Note:** for HTTPS VirtualServer the parameter name is `virtualServerHTTPSPort`

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*


Change the working directory to `CustomPort`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/CustomPort
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the VirtualServer resource.
```
kubectl apply -f custom-http-port.yml
```
CIS will create a Virtual Server on BIG-IP with VIP `10.1.10.57` and attaches a policy which forwards all traffic to pool echo-svc when the Host Header is equal to `custom.f5k8s.net`.   


Confirm that the VirtualServer resource is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs custom-port-http-vs
```

Expected output 
```
NAME                  HOST                    TLSPROFILENAME   HTTPTRAFFIC   IPADDRESS    IPAMLABEL   IPAMVSADDRESS   STATUS   AGE
custom-port-http-vs   custom-port.f5k8s.net                                  10.1.10.57               10.1.10.57      Ok       7s
```

Try accessing the service with curl as per the examples below. 
```
curl http://custom-port.f5k8s.net:8080
```

You should be able to access the service running in K8s. The output should be similar to:
```json
{
    "Project": "My Echo Project",
    "Project": "https://github.com/skenderidis/docker-images/echo",
    "Server Address": "10.244.140.117",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"accept":"*\/*","user-agent":"curl\/7.58.0","host":"custom-port.f5k8s.net:8080","content-length":"","content-type":""}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "57524",
    "Timestamp": "1692859065",
    "Data": "0"
}
```

***Clean up the environment (Optional)***
```
kubectl delete -f custom-http-port.yml
```