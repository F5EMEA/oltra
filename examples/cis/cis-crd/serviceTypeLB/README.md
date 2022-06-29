# ServiceType LoadBalancer

This section demonstrates three options on how to configure Service TypeLB (LoadBalancer).

- Simple TypeLB
- Multiport TypeLB
- Health Monitor

Service TypeLB relies on F5 IPAM to provide automatically IP addresses for the published services, by adding the annotation `cis.f5.com/ipamLabel`
In order for the `ipamLabel` to provide an IP address, you need to have a F5 IPAM controller running and with the defined Labels/IP-ranges.

First lets verify that the IPAM is running.

```
kubectl get po -n kube-system | grep f5ipam

**************** Expected Result ****************
NAME                                      READY   STATUS    RESTARTS       AGE
f5ipam-5bf9fbdb5-dzqwd                    1/1     Running   12 (39h ago)   18d
```

Review the IPAM IP ranges.

```
kubectl -n kube-system describe deployment f5ipam

**************** Expected Result ****************
...
...
    Command:
      /app/bin/f5-ipam-controller
    Args:
      --orchestration=kubernetes
      --ip-range='{"dev":"10.1.10.150-10.1.10.169","prod":"10.1.10.170-10.1.10.189"}'
      --log-level=DEBUG
...
...
```

## Create a Simple Type LoadBalancer

This section demonstrates the deployment of a service as Type LoadBalancer. 

Eg: service-type-lb.yml

```yml
apiVersion: v1
kind: Service
metadata:
  annotations:
    cis.f5.com/ipamLabel: Prod
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

Create the K8s service. 
```
kubectl apply -f serviceTypeLB.yml
```

Confirm that the VS CRD is deployed correctly. You should see the Load Balancer IP address on the service that was just created..
```
kubectl get svc 
```

Try accessing the service with curl as per the examples below. 
```
curl http://<IP address provided from IPAM>
```



## Create a Simple Type LoadBalancer with Health Monitor

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

Create the K8s service. 
```
kubectl apply -f healthMonitor-serviceTypeLB.yml
```

Confirm that the VS CRD is deployed correctly. You should see the Load Balancer IP address on the service that was just created..
```
kubectl get svc 
```

Try accessing the service with curl as per the examples below. 
```
curl http://<IP address provided from IPAM>
```

Go to the F5 GUI and make sure that the pool created is now marked as Green by the monitor.



## Create a MultiPort Type LoadBalancer

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

Create the K8s service. 
```
kubectl apply -f multiport-serviceTypeLB.yml
```

Confirm that the VS CRD is deployed correctly. You should see the Load Balancer IP address on the service that was just created..
```
kubectl get svc -n nginx
```

Try accessing the service with curl as per the examples below. 
```
curl http://<IP address provided from IPAM>
curl -k https://<IP address provided from IPAM>
```


