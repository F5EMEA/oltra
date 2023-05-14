# Familiarizing  Kubernetes 
We will first install the NGINX Plus instance with App Protect on an Ubuntu 20.04 Host and run some basic tests.


## Creating a pod

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

1. Open the VScode and open a WebSSH session to Master.

2. Go to directory `~/oltra/workshop/warsaw/day1/`.
```
cd ~/oltra/workshop/warsaw/day1/
```

3. Review the `deploy-pod.yaml`.
```
cat deploy-pod.yaml
```

4. Deploy the manifest
```
kubectl apply -f deploy-pod.yaml
```

5. Verify that the pod is created.
```
kubectl get pod
```

Look out for a pod called `dnsutils`.

6. Kill the pod
```
kubectl delete pod dnsutils
```

7. Verify the status of the pod
```
kubectl get pod
```

> Note: The pod should eventually disappear.


## Creating a deployment


1. Go to directory `~/oltra/workshop/warsaw/day1/`.
```
cd ~/oltra/workshop/warsaw/day1/
```

3. Review the `deployment.yaml`.
```
cat deployment.yaml
```

4. Deploy the manifest
```
kubectl apply -f deployment.yaml
```
> Note: You might see the deployment as unchanged but this is normal as this deployment already exists. (`deployment.apps/app1 unchanged`)

5. Verify that the pods are now running and find their IP 
```
kubectl get pod -o wide
```
You should see something like 

```
NAME                          READY   STATUS    RESTARTS      AGE     IP            NODE                   NOMINATED NODE   READINESS GATES
app1-8744789f8-s2stp          1/1     Running   1 (18m ago)   4d15h   10.42.0.14    lima-rancher-desktop   <none>           <none>
app1-8744789f8-rvmz9          1/1     Running   0             112s    10.42.0.28    lima-rancher-desktop   <none>           <none>
```

6. Using the WebSSH session on the Master access the pods by doing curl on their IP address
```
curl <IP address>.
```

7. Try accessing the pods from the terminal on VScode.
```
curl <IP address>.
```
> Don't be surprised if you weren't able to access it. VSCode runs on a machine that is outside the K8s cluster. So it is unaware of the overlay network the pods are using.

8. Kill one of the pods and observe the bahaviour. 
```
kubectl delete po <pod_name>
```

9. Run multiple times the following command to see the status. 
```
kubectl get pod
```

> The pod has been recreated. 


10. Edit the `deployment.yaml` and change the replica number from 2 to 4. Then re-apply the manifest
```
nano deployment.yaml

--------   Change   ----------
replicas: 2  ===>  replicas: 4
-------------------------------

kubectl apply -f deployment.yaml
```

Review the pods created.
```
kubectl get pod -o wide
```

11. Alternative to scale the pods without changing the deployment, run the following command.
```
kubectl scale deployment my_deployment --replicas=5
```


## Creating a ClusterIP service

1. Open the VScode and open a WebSSH session to Master.

2. Go to directory `~/oltra/workshop/warsaw/day1/`.
```
cd ~/oltra/workshop/warsaw/day1/
```

3. Review the `service-clusterip.yaml`.
```
cat service-clusterip.yaml
```

4. Deploy the manifest
```
kubectl apply -f service-clusterip.yaml
```

5. Verify that the svc are now creating and record its IP 
```
kubectl get svc -o wide
```

6. Review the pods that are part of this service 
```
k describe svc app1-svc
```

7. Using the WebSSH session on the Master access the service
```
curl <IP address>
```
Try multiple times to see that you are getting load balanced to the backend pods


8. Try accessing the pods from the terminal on VScode. Still not accessible
```
curl <IP address>.
```

9. To check the DNS name for this service run an NS lookup command from inside a POD
```
kubectl exec -i -t dnsutils -- nslookup app1-svc.default
```


## Creating a NodePort service

1. Open the VScode and open a WebSSH session to Master.

2. Go to directory `~/oltra/workshop/warsaw/day1/`.
```
cd ~/oltra/workshop/warsaw/day1/
```

3. Review the `service-nodeport.yaml`.
```
cat service-nodeport.yaml
```

4. Deploy the manifest
```
kubectl apply -f service-nodeport.yaml
```

5. Verify that the svc are now creating and record its IP and Port
```
kubectl get svc -o wide
```

6. Review the pods that are part of this service 
```
kubectl describe svc app1-svc-nodeport  
```

7. Using the WebSSH session on the Master access the service (use the ClusterIP)
```
curl <IP address>
```
Try multiple times to see that you are getting load balanced to the backend pods


8. Lets try to access the pods from the terminal on VScode. First we need to find the Node IPs as we already now the Port.
```
kubectl get nodes -o wide

curl <NODE IP>:<Port>
```

9. Add the following line to get a static NodePort port. Add the line below `targetPort`
```
nodePort: 30800
```
Access the service:
```
curl <NODE IP>:30800
```




## Creating a LoadBalancer service

2. Go to directory `~/oltra/workshop/warsaw/day1/`.
```
cd ~/oltra/workshop/warsaw/day1/
```

3. Review the `service-lb.yaml`.
```
cat service-lb.yaml
```

4. Deploy the manifest
```
kubectl apply -f service-lb.yaml
```

5. Verify that the svc are now creating and record its IP and Port
```
kubectl get svc -o wide
```

6. Review the pods that are part of this service 
```
kubectl describe svc app1-svc-nodeport  
```

7. Lets try to access the pods from the terminal on VScode.
```
curl <IP address>
```
Try multiple times to see IF you are getting load balanced to the backend pods


