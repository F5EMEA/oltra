# Working with CRDs

Custom resources are extensions of the Kubernetes API. This page discusses when to add a custom resource to your Kubernetes cluster and when to use a standalone service. It describes the two methods for adding custom resources and how to choose between them.

A resource is an endpoint in the Kubernetes API that stores a collection of API objects of a certain kind; for example, the built-in pods resource contains a collection of Pod objects.

A custom resource is an extension of the Kubernetes API that is not necessarily available in a default Kubernetes installation. It represents a customization of a particular Kubernetes installation. However, many core Kubernetes functions are now built using custom resources, making Kubernetes more modular.

Custom resources can appear and disappear in a running cluster through dynamic registration, and cluster admins can update custom resources independently of the cluster itself. Once a custom resource is installed, users can create and access its objects using kubectl, just as they do for built-in resources like Pods.

During this labs, we will see the value of the CRDs

## Make some mistakes

When using the Native resources of Kubernetes and you do a mistake you get an immediate response on whether the resource has been accepted or not. This is because the value that is inserted is compared to the specification of the resource. 

Lets try some "mistakes"


1. Open the VScode and open a WebSSH session to Master.

2. Go to directory `K8s-fundamentals`.
```
cd ~/oltra/use-cases/workshops/K8s-fundamentals/
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

5. Review the `mistake-ingress.yaml`.
```
cat mistake-ingress.yaml
```
> Did you find the mistake?

If not, apply the configuration and verify the persistence session cookie. 

```
kubectl apply -f mistake-ingress.yaml
```

Verify the Set-Cookie Header

```
curl http://sticky.f5k8s.net/tea -I
```
> Was the Header `Set-Cookie: srv_id=35e80c4cacdfbafc67e984beb2614376; expires=Mon, 04-Sep-23 13:48:08 GMT; max-age=7200; path=/tea` present



## CRD examples with NGINX

VirtualServer CRD examples
  - https://github.com/F5EMEA/oltra/blob/main/use-cases/nic-examples/custom-resources/basic-configuration/README.md

