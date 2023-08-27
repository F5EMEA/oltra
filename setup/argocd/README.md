1. kubectl create namespace argocd

2. kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.2/manifests/install.yaml

3. Get the password

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

4. Publish the services.

