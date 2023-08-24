# Upgrade of NGINX Plus IC

## Currently working on version 3.2.1

1. Get a new JWT token. (From salesforce)

1. Delete existing docker registry credentials
    ```
    kubectl delete secrets regcred -n nginx
    ```

1. Create new docker registry credentials
    ```
    kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=<JWT Token> --docker-password=none -n nginx
    ```

1. Clone the NGINX Ingress Controller repository and change into the deployments folder
    ```
    git clone https://github.com/nginxinc/kubernetes-ingress.git --branch vX.X.X
    cd kubernetes-ingress/deployments
    ```

1. Copy the new CRDs to oltra and apply the changes
    ```
    cp common/crds/* /home/ubuntu/oltra/setup/nginx-ic/crds/
    kubectl apply -f /home/ubuntu/oltra/setup/nginx-ic/crds/
    ```

1. Edit (change the namespace from `nginx-ingress` to `nginx`), copy and apply the following files
    ```
    cp rbac/* /home/ubuntu/oltra/setup/nginx-ic/rbac/
    kubectl apply -f /home/ubuntu/oltra/setup/nginx-ic/rbac/rbac.yaml
    kubectl apply -f /home/ubuntu/oltra/setup/nginx-ic/rbac/ap-rbac.yaml
    kubectl apply -f /home/ubuntu/oltra/setup/nginx-ic/rbac/apdos-rbac.yaml
    ```

1. Review the nginx-plus deployment manifest with the existing to see any differences.

1. Change the nginx-plus version from the deployment manifest and re-apply it.
    ```
    k apply -f /home/ubuntu/oltra/setup/nginx-ic/nginx-plus/nginx-plus.yaml
    ```


# Replace the f5k8s.net cert key

1. Get the certs from LetsEncrypt.
1. Base64 encode the values
1. Replace the tls.crt and tls.key on `/home/ubuntu/oltra/setup/nginx-ic/resources/default-server-secret.yaml`
    ```
    tls.crt: LS0tLS1CRU.....
    tls.key: LS0tLS.....
    ```