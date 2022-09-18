# ServiceType LoadBalancer
This section demonstrates three options on how to configure Service TypeLB (LoadBalancer).

- [Service Type LoadBalancer](#service-type-loadbalancer)
- [MultiPort Type LoadBalancer](#multiport-type-loadbalancer)
- [Service Type LoadBalancer with Health monitor](#service-type-loadbalancer-with-health-monitor)

A service of type LoadBalancer is the simplest and the fastest way to expose a service inside a Kubernetes cluster to the external world. You only need to specify the service type as type=LoadBalancer in the service definition.

Services of type LoadBalancer are natively supported in Kubernetes deployments. When you create a service of type LoadBalancer it spins up service in integration with F5 IPAM Controller which allocates an IP address that will forward all traffic to your service.

For services of the type LoadBalancer, the controller deployed inside the Kubernetes cluster configures a service type LB. Using CIS, you can load balance the incoming traffic to the Kubernetes cluster. CIS manages IP addresses using FIC so you can maximize the utilization of load balancer resources and significantly reduce your operational expenses.

The mandatory parameter for service type LoadBalancer to work alongside CIS is to add the annotation `cis.f5.com/ipamLabel` on the service you want to publish.

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

### Verify IPAM status
To verify that IPAM is running, run the following command.

```
kubectl get po -n bigip | grep f5-ipam

**************** Expected Result ****************
NAME                                      READY   STATUS    RESTARTS       AGE
f5-ipam-5bf9fbdb5-dzqwd                    1/1     Running   12 (39h ago)   18d
```

Review the IPAM configured IP ranges.

```
kubectl -n bigip describe deployment f5-ipam

**************** Expected Result ****************
...
...
    Command:
      /app/bin/f5-ipam-controller
    Args:
      --orchestration=kubernetes
      --ip-range='{"dev":"10.1.10.150-10.1.10.169","prod":"10.1.10.170-10.1.10.189","tenant1":"10.1.10.190-10.1.10.192","tenant2":"10.1.10.193-10.1.10.195"}'
      --log-level=DEBUG
...
...
```


## Service Type LoadBalancer

This section demonstrates the deployment of a service as Type LoadBalancer. 

Eg: service-type-lb.yml

```yml
apiVersion: v1
kind: Service
metadata:
  annotations:
    cis.f5.com/ipamLabel: prod
  labels:
    app: svc-lb1
  name: svc-lb1
  namespace: default
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: echo
  type: LoadBalancer
```

Create the Application deployment and service: 
```
kubectl apply -f ~/oltra/setup/apps/my-echo.yml
```

Change the working directory to `serviceTypeLB`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/serviceTypeLB
```

Create the K8s service. 
```
kubectl apply -f serviceTypeLB.yml
```

Confirm that the service has a LoadBalancer IP assigned to it.
```
kubectl get svc svc-lb-ipam
```

Save the IP adresses that was assigned by the IPAM for this service
```
IP=$(kubectl get svc svc-lb-ipam --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Try accessing the service with curl as per the examples below. 
```
curl http://$IP
```

The output should be similar to:
```json
{
    "Server Name": "10.1.10.171",
    "Server Address": "10.244.140.88",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"host":"10.1.10.171","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "51550",
    "Timestamp": "1657781705",
    "Data": "0"
}
```

***Clean up the environment (Optional)***
```
kubectl delete -f serviceTypeLB.yml
```

## Service Type LoadBalancer with Health Monitor

This section demonstrates the deployment of a service as Type LoadBalancer with a Health Monitor on the BIGIP pool. Options which can be used to configure health monitor:
```
monitor:
    interval: 
    timeout: 
```

Eg: service-type-lb.yml
```yml
apiVersion: v1
kind: Service
metadata:
  annotations:
    cis.f5.com/health: '{"interval": 3, "timeout": 10}'
    cis.f5.com/ipamLabel: Prod
  labels:
    app: svc-health-1
  name: svc-health-1
  namespace: default
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: echo
  type: LoadBalancer
```

Create the Application deployment and service: 
```
kubectl apply -f ~/oltra/setup/apps/my-echo.yml
```

Change the working directory to `serviceTypeLB`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/serviceTypeLB
```

Create the K8s service. 
```
kubectl apply -f healthMonitor-serviceTypeLB.yml
```

Confirm that the service has a LoadBalancer IP assigned to it.
```
kubectl get svc svc-health-1
```

Save the IP adresses that was assigned by the IPAM for this service
```
IP=$(kubectl get svc svc-health-1 --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Try accessing the service with curl as per the examples below. 
```
curl http://$IP
```

Go to the F5 GUI and make sure that the pool created is now marked as Green by the monitor.


***Clean up the environment (Optional)***
```
kubectl delete -f healthMonitor-serviceTypeLB.yml
```

## MultiPort Type LoadBalancer

This section demonstrates the deployment of a multi port service as Type LoadBalancer that will create two Virtual Servers with different ports on BIG-IP. 

Eg: multiport-serviceTypeLB.yml

```yml
apiVersion: v1
kind: Service
metadata:
  annotations:
    cis.f5.com/ipamLabel: Prod
  labels:
    app: nginx-plus-lb
  name: nginx-plus-lb
  namespace: nginx
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
    - name: https
      port: 443
      protocol: TCP
      targetPort: 443
  selector:
    app: nginx-plus
  type: LoadBalancer
```

Create the Application deployment and service: 
```
kubectl apply -f ~/oltra/setup/apps/my-echo.yml
```

Create the K8s service. 
```
kubectl apply -f multiport-serviceTypeLB.yml
```

Confirm that the VS CRD is deployed correctly. You should see the Load Balancer IP address on the service that was just created..
```
kubectl get svc -n nginx
```

Confirm that the service has a LoadBalancer IP assigned to it.
```
kubectl get svc nginx-plus-lb
```

Save the IP adresses that was assigned by the IPAM for this service
```
IP=$(kubectl get svc nginx-plus-lb --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Try accessing the service with curl as per the examples below. 
```
curl http://$IP
curl -k https://$IP
```

***Clean up the environment (Optional)***
```
kubectl delete -f multiport-serviceTypeLB.yml
```
