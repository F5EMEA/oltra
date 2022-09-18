# VirtualServer with Dynamic IP Allocation (IPAM)

This section demonstrates the F5 IPAM functionality, where teh VirtualServer IP Address is dynamically provieded by the IPAM Controller. 

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

Change the working directory to `IpamLabel`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/IpamLabel
```

Verify that the IPAM is running.

```
kubectl get po -n bigip | grep f5-ipam

**************** Expected output ****************
NAME                                      READY   STATUS    RESTARTS       AGE
f5-ipam-5bf9fbdb5-dzqwd                    1/1     Running   12 (39h ago)   18d
```

Review the IPAM IP ranges.

```
kubectl -n bigip describe deployment f5-ipam

**************** Expected output ****************
...
...
    Command:
      /app/bin/f5-ipam-controller
    Args:
      --orchestration=kubernetes
      --ip-range='{"dev":"10.1.10.181-10.1.10.190","prod":"10.1.10.191-10.1.10.200"}'
      --log-level=DEBUG
...
...
```

Create the Application deployment and service: 
```
kubectl apply -f ~/oltra/setup/apps/my-echo.yml
```

Create the VirtualServer resource. 
```
kubectl apply -f virtual-with-ipamLabel.yml
```

Confirm that the VS CRDs is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs 
```

Save the IP adresses that was assigned by the IPAM for this VirtualServer
```
IP=$(kubectl get f5-vs ipam-vs --output=jsonpath='{.status.vsAddress}')
```

Try accessing the service as per the example below. 
```
curl http://ipam.f5demo.local/ --resolve ipam.f5demo.local:80:$IP
```

The output should be similar to:
```
{
    "Server Name": "ipam.f5demo.local",
    "Server Address": "10.244.196.135",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"host":"ipam.f5demo.local","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "58038",
    "Timestamp": "1657611589",
    "Data": "0"
}
```


***Clean up the environment (Optional)***
```
kubectl delete -f virtual-with-ipamLabel.yml
```
