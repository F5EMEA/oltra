# Working with NGINX Ingress
We already have NGINX+ running on our environment. In lab we will run mulitple examples on how to publish resources with NGINX Ingress.

## Review the environment

1. Let's find the deployment for NGINX
```
kubectl get deploy -n nginx
```

1. Review the deployment configuration for NGINX. 
```
kubectl describe deploy nginx-plus -n nginx
```
Pay close attention to the arguments that we have used for this environment and get more details about them from the following <a href="https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/command-line-arguments/"> link </a>
```
    Args:
      -nginx-plus
      -nginx-configmaps=$(POD_NAMESPACE)/nginx-config
      -default-server-tls-secret=$(POD_NAMESPACE)/default-server-secret
      -wildcard-tls-secret=$(POD_NAMESPACE)/default-server-secret
      -ingress-class=nginx-plus
      -enable-app-protect
      -enable-app-protect-dos
      -report-ingress-status
      -nginx-status-allow-cidrs=10.0.0.0/8
      -nginx-status
      -enable-service-insight
      -external-service=nginx-plus
      -enable-prometheus-metrics
      -enable-latency-metrics
      -global-configuration=$(POD_NAMESPACE)/nginx-configuration

```

1. Get the NGINX+ pods running and the service used for publishing the NGINX pods. 
```
kubectl get po -n nginx -o wide
```

```
kubectl get svc -n nginx
```

Verify that the service is of Type Load Balancer and includes an External-IP.
```
NAME                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                    AGE
nginx-plus           LoadBalancer   10.43.140.146   10.1.10.10     80:31797/TCP,443:30135/TCP,8080:31704/TCP,9114:30226/TCP   6d3h
```

1. Get the configured Ingress Classes


```
kubectl get ingressclass

#######################  Expected Output  ###################################
NAME         CONTROLLER                     PARAMETERS                     AGE
f5           f5.com/cntr-ingress-svcs       <none>                         10d
nginx-plus   nginx.org/ingress-controller   IngressParameters/nginx-plus   10d
```

1. Describe `nginx-plus` IngressClass

```
kubectl describe ingressclass nginx-plus

#######################  Expected Output  ###################################

Name:         nginx-plus
Labels:       <none>
Annotations:  ingressclass.kubernetes.io/is-default-class: true
Controller:   nginx.org/ingress-controller
Parameters:
  Kind:  IngressParameters
  Name:  nginx-plus
Events:  <none>
```

## Ingress examples with NGINX

Try doing the following examples

- [Basic Ingress](https://github.com/F5EMEA/oltra/tree/main/use-cases/nic-examples/ingress-resources/basic)
- [Path Based](https://github.com/F5EMEA/oltra/tree/main/use-cases/nic-examples/ingress-resources/path-based)
- [TLS Termination](https://github.com/F5EMEA/oltra/tree/main/use-cases/nic-examples/ingress-resources/tls)
- [Persistence](https://github.com/F5EMEA/oltra/tree/main/use-cases/nic-examples/ingress-resources/persistence)
- [Basic Authentication](https://github.com/F5EMEA/oltra/tree/main/use-cases/nic-examples/ingress-resources/auth-basic)

