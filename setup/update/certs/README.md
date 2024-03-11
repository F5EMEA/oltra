# updating certs

## Gitlab
update the f5k8s.net certs that are located on https://github.com/skenderidis/certs (private repo)

`/srv/gitlab/ssl`

- /srv/gitlab/config/ssl/f5k8s.key 
- /srv/gitlab/config/ssl/f5k8s.crt 

docker exec gitlab_web_1 gitlab-ctl reconfigure

docker exec gitlab_web_1 gitlab-ctl restart

Redeploy gitlab

## NGINX Ingress

Get the base64 for the certificate and the key 

cat f5k8s.key | base64  | tr -d '\n'

cat f5k8s.crt | base64  | tr -d '\n'

Replace the values on the following files

- setup/nginx-ic/resources/default-server-secret.yaml
- use-cases/nic-examples/ingress-resources/tls/secret.yaml
- setup/apps/apps.yml

- /home/ubuntu/oltra/use-cases/nic-examples/custom-resources/tls/cafe-secret.yaml
