# Familiarizing  Kubernetes 
In this example we will try to familiarize with the fundamental elements of Kubernetes. Things that will be covered from these examples are:
- Running Pods in Kubernetes
- Creating Deployments
- Creating a ClusterIP service
- Creating a NodePort service
- Creating a Load Balancer service

Throughout the session we will try to cover, what is the difference between running Pods and Deployments, what is the difference between the most commonly used services (ClusterIP, NodePort and LB) and when to use which. 


> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

## Running the examples
1. Open the VScode and update the Git contents.
   ```
   cd ~/oltra/
   git pull
   ```

1. Go to directory `K8s-fundamentals`.
   ```
   cd ~/oltra/use-cases/workshops/K8s-fundamentals/
   ```

## Creating a pod
More information about pods can be found on <a href="https://kubernetes.io/docs/concepts/workloads/pods/"> here </a>


1. Review the `deploy-pod.yaml`.
   ```
   cat deploy-pod.yaml
   ```

1. Deploy the manifest
   ```
   kubectl apply -f deploy-pod.yaml
   ```

1. Verify that the pod is created.
   ```
   kubectl get pod
   ```

1. Get the extended details about the pod. 
   ```
   kubectl get pod
   ```
   > Note: Look out for a pod called `dnsutils`.

1. Execute a command from the pod.
   ```
   kubectl exec dnsutils -- nslookup www.google.com
   ```

1. Kill the pod
   ```
   kubectl delete pod dnsutils
   ```

1. Verify the status of the pod
   ```
   kubectl get pod
   ```

> Note: The pod should eventually disappear.


## Creating a deployment
More information about deployments can be found on <a href="https://kubernetes.io/docs/concepts/workloads/controllers/deployment/"> here </a>

1. Review the `deployment.yaml`.
   ```
   cat deployment.yaml
   ```

1. Deploy the manifest
   ```
   kubectl apply -f deployment.yaml
   ```
   > Note: You might see the deployment as unchanged but this is normal as this deployment already exists. (`deployment.apps/app1 unchanged`)


1. Verify that the pods are now running and find their IP 
   ```
   kubectl get pod -o wide
   ```

   You should see something like 

   ```
   NAME                          READY   STATUS    RESTARTS      AGE     IP            NODE                   NOMINATED NODE   READINESS GATES
   app1-8744789f8-s2stp          1/1     Running   1 (18m ago)   4d15h   10.42.0.14    lima-rancher-desktop   <none>           <none>
   app1-8744789f8-rvmz9          1/1     Running   0             112s    10.42.0.28    lima-rancher-desktop   <none>           <none>
   ```

1. Open a WebSSH session on the Rancher1 in order to access the pods by doing curl on their IP address
   ```
   curl <IP address>.
   ```

1. Try accessing the pods from the terminal on VScode.
   ```
   curl <IP address>.
   ```
   > Don't be surprised if you weren't able to access it. VSCode runs on a machine that is outside the K8s cluster and just communicates with the . So it is unaware of the overlay network the pods are using.


1. Kill one of the pods and observe the bahaviour. 
   ```
   kubectl delete po <pod_name>
   ```

1. Run the following command to see the status of the pod. 
   ```
   kubectl get pod -w
   ```

   > The pod has been recreated.


1. Edit the `deployment.yaml` and change the replica number from 2 to 4. Then re-apply the manifest
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

1. Alternative to scale the pods without changing the deployment, run the following command.
   ```
   kubectl scale deployment my_deployment --replicas=5
   ```


## Creating a ClusterIP service
More information about services can be found on <a href="https://kubernetes.io/docs/concepts/services-networking/service/"> here </a>

1. Open the VScode and open a WebSSH session to Rancher1.

1. Review the `service-clusterip.yaml`.
   ```
   cat service-clusterip.yaml
   ```

1. Deploy the manifest
   ```
   kubectl apply -f service-clusterip.yaml
   ```

1. Verify that the svc are now creating and record its IP 
   ```
   kubectl get svc -o wide
   ```

1. Review the pods that are part of this service 
   ```
   k describe svc app1-svc
   ```

1. Using the WebSSH session on the Master access the service
   ```
   curl <IP address>
   ```
Try multiple times to see that you are getting load balanced to the backend pods


1. Try accessing the pods from the terminal on VScode. Still not accessible
   ```
   curl <IP address>.
   ```

1. To check the DNS name for this service run an NS lookup command from inside a POD
   ```
   kubectl exec -i -t dnsutils -- nslookup app1-svc.default
   ```
> Note: ClusterIP services can be accessed ONLY from inside the cluster. 

## Creating a NodePort service

1. Review the `service-nodeport.yaml`.
```
cat service-nodeport.yaml
```

1. Deploy the manifest
```
kubectl apply -f service-nodeport.yaml
```

1. Verify that the svc are now creating and record its IP and Port
```
kubectl get svc -o wide
```

1. Review the pods that are part of this service 
```
kubectl describe svc app1-svc-nodeport  
```

1. Using the WebSSH session on Rancher1, access the service using CURL (use the ClusterIP)
```
curl <IP address>
```
Try multiple times to see that you are getting load balanced to the backend pods


8. Lets try to access the pods from the terminal on VScode. First we need to find the Node IPs as we already now the Port.
```
kubectl get nodes -o wide

curl <NODE IP>:<Port>
```

9. Add the following line to get a static NodePort port. Add the line below `targetPort` on the file `service-nodeport.yaml`

   ```
   nano service-nodeport.yaml

   ## Add the following line.
   nodePort: 30800
   ```

Re-apply the configuration and access the services.
   ```
   kubectl apply -f service-nodeport.yaml
   curl <NODE IP>:30800
   ```




## Creating a LoadBalancer service

1. Review the `service-lb.yaml`.
```
cat service-lb.yaml
```

1. Deploy the manifest
```
kubectl apply -f service-lb.yaml
```

1. Verify that the svc are now creating and record its IP and Port
```
kubectl get svc -o wide
```

1. Review the pods that are part of this service 
```
kubectl describe svc app1-svc-nodeport  
```

1. Lets try to access the pods from the terminal on VScode.
```
curl <IP address>
```
Try multiple times to see IF you are getting load balanced to the backend pods


