# Health Monitors

This section demonstrates the option to configure health monitors for kubernetes services that BIGIP will use to monitor the availability of services.
Heath monitors need to be defined per pool. 

Eg: health-vs
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: health-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.58"
  host: health.f5demo.local
  pools:
  - path: /app1
    service: app1-svc
    servicePort: 8080
    monitor:
      type: http
      send: "GET /app1/index.html HTTP/1.1\r\nHost: health.f5demo.local\r\nConnection: Close\r\n\r\n"
      recv: "200 OK"
      interval: 3
      timeout: 10
  - path: /app2
    service: app2-svc
    servicePort: 8080
    monitor:
      type: http
      send: "GET /app2/index.html HTTP/1.1\r\nHost: health.f5demo.local\r\nConnection: Close\r\n\r\n"
      recv: "200 OK"
      interval: 3
      timeout: 10
```

Create the CRD resource.
```
kubectl apply -f health-monitor.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```

On the BIGIP UI, you should see the application pool marked as green and a custom monitor assigned to the pool

| BIGIP Pool             |  Pool Details |
:-------------------------:|:-------------------------:
![health-monitor-bigip-1](images/health-monitor-bigip-1.png)  |  ![health-monitor-bigip-2](images/health-monitor-bigip-2.png)


