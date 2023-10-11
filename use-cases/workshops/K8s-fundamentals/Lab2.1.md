# Working with F5 Ingress
We already have CIS and NGINX+ running on our environment.

## Review the environment

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

1. On the terminal run the following command to review the IngressClasses configured
```
kubectl get ingressclass
```
You should see an ingress class with the name `f5` that corresponds to CIS and `nginx-plus` that corresponds to NGINX.

3. Let's find the deployment for CIS
```
kubectl get deploy -n bigip -o 
```

4. Review the deployment configuration for CIS. 
```
kubectl get deploy f5-cis-crd -n bigip -o yaml
```

## Ingress examples with CIS
Go to the following links for the 3 examples
 - https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/cis-ingress/fanout/README.md
 - https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/cis-ingress/host-routing/README.md
 - https://github.com/F5EMEA/oltra/blob/main/use-cases/cis-examples/cis-ingress/tls/README.md



