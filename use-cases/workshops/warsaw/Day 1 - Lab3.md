# Working with CRDs
During this labs, we will see the value of the CRDs

## Make some mistakes

When using the Native resources of Kubernetes and you do a mistake you get an immediate response on whether the resource has been accepted or not. This is because the value that is inserted is compared to the specification of the resource. 

Lets try some "mistakes"


1. Open the VScode and open a WebSSH session to Master.

2. Go to directory `~/oltra/use-cases/workshops/warsaw/day1`.
```
cd ~/oltra/use-cases/workshops/warsaw/day1
```

3. Review the `mistake-1.yaml`.
```
cat mistake-1.yaml
```

4. Deploy the manifest
```
kubectl apply -f mistake-1.yaml
```
> Check the reason of the error.

Do the same for `mistake-2.yaml`

## CRD examples with CIS

VirtualServer CRD examples
 - https://github.com/F5EMEA/oltra/tree/main/use-cases/cis-examples/cis-crd/VirtualServer/Basic

TransportServer CRD examples
 - https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/cis-crd/TransportServer/


## CRD examples with NGINX

VirtualServer CRD examples
  - https://github.com/F5EMEA/oltra/blob/main/use-cases/nic-examples/custom-resources/basic-configuration/README.md

