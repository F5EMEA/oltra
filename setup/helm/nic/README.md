# Installation

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
kubectl create ns nginx
kubectl apply -f nginx-config.yaml -n nginx
kubectl apply -f default-server-secret.yaml -n nginx
helm install rancher1  nginx-stable/nginx-ingress --namespace nginx -f /home/ubuntu/oltra/setup/helm/nic/values.yml

helm upgrade rancher1  nginx-stable/nginx-ingress --namespace nginx -f /home/ubuntu/oltra/setup/helm/nic/values.yml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v3.4.3/deploy/crds.yaml (check the latest on https://github.com/nginxinc/kubernetes-ingress/tree/main/charts/nginx-ingress)


# Update JWT Token
1. Get a new JWT token. (From salesforce)

1. Delete existing docker registry credentials
    ```
    kubectl delete secrets regcred -n nginx
    ```

1. Create new docker registry credentials
    ```
    kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=<JWT Token> --docker-password=none -n nginx
    ```

    