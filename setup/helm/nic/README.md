# Installation

helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
kubectl create ns nginx
helm install rancher1  nginx-stable/nginx-ingress --namespace nginx -f /home/ubuntu/oltra/setup/helm/nic/values.yml
helm upgrade rancher1  nginx-stable/nginx-ingress --namespace nginx -f /home/ubuntu/oltra/setup/helm/nic/values.yml

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