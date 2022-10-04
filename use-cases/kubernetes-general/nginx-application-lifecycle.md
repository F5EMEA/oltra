# Managing the Application Lifecycle in Kubernetes with NGINX

A guide to managing application routing with NGINX Ingress Controller

The latest [F5 State of Application Strategy Report (2022)](https://www.f5.com/state-of-application-strategy-report) highlighted that 90% of organizations are executing on a Digital Transformation strategy. Those efforts proceed through the stages of Automation, Digital Expansion, and AI-assisted Business.

Kubernetes and micro-services architectures in general play a key role in achieving success in the Digital Expansion phase of that transformation. 

- [Managing the Application Lifecycle in Kubernetes with NGINX](#managing-the-application-lifecycle-in-kubernetes-with-nginx)
- [Applications in Kubernetes](#applications-in-kubernetes)
  - [Containers and Pods](#containers-and-pods)
- [Deployments and ReplicaSets](#deployments-and-replicasets)
  - [Upgrades and Rollbacks](#upgrades-and-rollbacks)
- [The Application Life Cycle](#the-application-life-cycle)
  - [Canary 🐦](#canary-)
  - [Blue/Green Updates](#bluegreen-updates)
- [Examples](#examples)
  - [Available Examples](#available-examples)
  - [Canary Example (CRD)](#canary-example-crd)
  - [Canary Example (Ingress)](#canary-example-ingress)
  - [Blue / Green (CRD)](#blue--green-crd)
  - [Blue / Green (Ingress)](#blue--green-ingress)
  - [Further Reading](#further-reading)

# Applications in Kubernetes

Kubernetes provides an orchestration platform for running OCI compatible containers and their supporting services. A container is an application bundled into an immutable image which is guaranteed to run the same way on any OCI runtime environment. This gives the application developers confidence that if the application runs in development, that it will run in production the same way.

The Kubernetes platform has emerged as the defacto container orchestration system, and most customers are using Kubernetes or some variant of it (OpenShift, Rancher, AKS, EKS, etc) to run their applications. Containers provide the image format and the execution specification and Kubernetes provides everything else: a network so containers can communicate with each other, an ingress so that services can be made available externally, secrets management, access to storage, security, service discovery, etc. All of which are configured through a declarative (and extensible) API.

One of the primary goals of Digital Transformation is to make services available digitally, and improve the speed to market for new services. Increasing speed to market requires organizations to adopt DevOps practices to automate the building, testing, and delivery of applications to production. Usually this also involves adopting a micro-services architecture so that containers can be built for discrete tasks, enabling them to be updated and tested independently of other parts of the application.

## Containers and Pods

As we've said a `container` is an immutable image containing an application. When the application container is executed it will typically get its own secure sandbox providing isolation from other container processes, network services, etc.

Kubernetes doesn't deal with containers directly, it deals with the secure sandboxes they execute in, and these are called pods. 

A `pod` is the smallest compute unit you can deal with in Kubernetes. It includes a list of containers to run in the pod, requirements the pod has around scheduling, resources, storage requirements, environment variables, security context, and health checks.

Pods can also include a special type of container called an InitContainer, these are normal containers which are designed to execute a task and then exit prior to the main application containers being started.

> ### TIP
> The pod model is what enables the sidecar patterns often used in Kubernetes Service Mesh. In NGINX Service Mesh we auto-inject both a side-car (an additional application container) and an InitContainer into each pod deployed within a meshed namespace.

# Deployments and ReplicaSets

A SRE will rarely deploy a pod into Kubernetes directly. It's far more likely they will create a `Deployment` which includes a `PodTemplate` embedded in the definition, and the number of `replicas` (number of pods to deploy).

The `Deployment` in turn creates a `ReplicaSet` which is tied to a specific version of the Deployment and it owns and manages the pods created from the PodTemplate.

There are also: `DaemonSet` and `StatefulSet` which also use PodTemplates to create and manage pods. The DaemonSet creates a pod on every node in the kubernetes cluster, and the StatefulSet offers a predictable naming and scaling convention for the pods.

## Upgrades and Rollbacks

When you create a Deployment, a ReplicaSet is created to manage the pods for you. If you subsequently make a change to the PodTemplate a new ReplicaSet will be created automatically and a rolling update will be performed until the new ReplicaSet has the desired number of replicas and the old set has scaled back to 0.

> ### TIP
>This rolling update functionality is rarely used on a deployment which has live traffic, instead this will be used to update the non-live arm in combination with a blue/green deployment process.

In a similar fashion to containers being immutable, so are ReplicaSets. Kubernetes will (by default) keep a backlog of the last 10 ReplicaSets for each Deployment. This is to enable `rollbacks`. If a rolling update should fail or need to be reverted for any reason, a SRE can rollback to any of the previous 10 ReplicaSets.

# The Application Life Cycle

Kubernetes provides a number of features which aid the application owner or Site Reliability Engineer (SRE) to manage the application life-cycle. 

The `rolling update` and `roll back` features can be used out-of-the-box with live services, but that's *a bit like sticking your head in the water to see if the sharks have gone*.

Those features can be used, but will be used in combination with `Canary` testing and `blue/green` updates.

## Canary 🐦

A `Canary Release` is when you provide access to a new or alternative version of an application or service to a limited set of clients. This is commonly used for doing a full functionality test of an update in production prior to rolling out the upgrade more widely.

> ### TIP
> Blue/Green updates are sometimes also referred to as `Weighted Canary`.

## Blue/Green Updates

The `Blue/Green update` process is where the new version of an application is gradually introduced into service. This is commonly achieved by `traffic splitting`; where an initially small percentage of traffic is sent to the new release, and gradually increased while monitoring for issues. Eventually all the traffic is migrated to the new version. 

The blue/green name comes from a physical computing practice where an enterprise would have two complete production capable stacks, and the live stack would alternate between the two. The non-live stack would generally be used for staging the new release and testing in preperation for the next blue/green transition.

# Examples

The Ingress examples below make use of snippets, and so require snippets to be enabled on the Ingress Controller, otherwise they wont work. Where possible chose the CRD alternative.

## Available Examples

The Canary use-case is essentially advanced routing, so take a look at the following example walk-throughs in the `nic-examples` folder:

* [Advanced Routing CRDs](../../use-cases/nic-examples/custom-resources/advanced-routing/README.md)

## Canary Example (CRD)

The VirtualServer and VirtualServerRoute custom resources both support conditional routing, which is a fundamental requirement for Canary releases. 

In the example below we route to either the main application service `app-svc` or the canary `app-canary-svc` depending on the existence and value of a HTTP header called `my-header`. If it exists and has a value of `always` we send the request to the canary, otherwise it goes to the main application service.

```yaml
    path: /
    matches:
    - conditions:
      - header: my-header
        value: never
      action:
        pass: app-svc
    - conditions:
      - header: my-header
        value: always
      action:
        pass: app-canary-svc
    action:
      pass:  app-svc
```


## Canary Example (Ingress)

> ### WARNING
> We strongly urge you to make use of the VirtualServer (CRD) for advanced load balancing use-cases like Canary. See the CRD example above.

The example below shows how you can achieve a Canary setup based on an incoming header called `my-header`. We use two snippets via annotations (`nginx.org/server-snippet` and `nginx.org/location-snippet`), and a third snippet in the NGINX `ConfigMap` to set a `http-snippet`.

The `http-snippet` in the ConfigMap sets up an NGINX https://nginx.org/r/map[map] directive to associate our header `my-header` with a custom `$access_canary` variable. If the header is set to `always` then the access variable is set to 1, else it is set to 0.

The two annotations on the Ingress resource set up an internal location within NGINX at the path `/canary` which load balances (`proxy_pass`) to a named canary service.

| | |
|---|---|
|**Annotations**| nginx.org/server-snippets *and* nginx.org/location-snippets
|**ConfigMap**| Required


**annotations:**
```yaml
    nginx.org/server-snippets:
      location /canary {
        internal;
        set $service <canary-service>;
        proxy_pass http://<ns>-<ingress>-<hostname>-<service>-<port>/
      }
    nginx.org/location-snippets: \|
      if ( $access_canary = 1 ) {
        rewrite ^(.*)$ /canary/$1 last;
      }
```

**configmap**
```yaml
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: nginx-config
      namespace: nginx-ingress
    data:
      http-snippets: \|
        map $http_my_header $access_canary {
          default          0;
          never            0;
          always           1;
        }
```

## Blue / Green (CRD)

In this example we are passing 10% of the traffic to the new version of the application in the `myapp-new` upstream, and 90% to the current `myapp` upstream.

```yaml
    spec:
    ...
    routes:
      splits:
      - weight: 10
        action:
          pass myapp-new
      - weight: 90
        action:
          pass: myapp
```

An SRE would need to update the VS or VSR resources periodically to gradually increase the amount of traffic being sent to the new application until the update is complete.

## Blue / Green (Ingress)

This Ingress example is very similar to the canary example above. The main difference is the ConfigMap has changed the http-snippet to use a split_clients directive instead of the map used previously.

Also there is a `set` in the server-snippet which selects the variable to use as context for the splitting. In this case we're using the `$request_id` which is the same variable the CRDs use.

| | |
|---|---|
|Annotations | nginx.org/server-snippets *and* nginx.org/location-snippets
|ConfigMap  | Required

**annotations:**
```yaml
    nginx.org/server-snippets: \|
      set $split_var $request_id;
      location /canary {
        internal;
        set $service <canary-service>;
        proxy_pass http://<ns>-<ingress>-<hostname>-<service>-<port>/
      }
    nginx.org/location-snippets: \|
      if ( $access_canary = 1 ) {
        rewrite ^(.*)$ /canary/$1 last;
      }
```
**configmap:**
```yaml
    kind: ConfigMap
    apiVersion: v1
    metadata:
      name: nginx-config
      namespace: nginx-ingress
    data:
      http-snippets: \|
        split_clients $split_var $access_canary {
          10%              1;
          *                0;
        }
```

> ### NOTE
>The `$request_id` is a unique identifier for each request, and so there is no persistence for the client. In the case of Ingress we can chose to use a different variable (eg a cookie), but we don't have that option with the CRD.

## Further Reading

* [An Illustrated Guide to Kubernetes](https://www.cncf.io/phippy/)
* [NGINX Custom Resources](https://www.nginx.com/products/nginx-ingress-controller/nginx-ingress-resources/)
