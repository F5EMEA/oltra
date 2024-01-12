# updating certs

## Gitlab
update the f5k8s.net certs that are located on 

`/srv/gitlab/ssl`

- /srv/gitlab/config/ssl/f5k8s.key 
- /srv/gitlab/config/ssl/f5k8s.crt 

docker exec gitlab_web_1 gitlab-ctl reconfigure
docker exec gitlab_web_1 gitlab-ctl restart

Redeploy gitlab


1. Update app-ssl-1.yaml and app-ssl-2.yaml with the f5demo and f5k8s certs. The location is on `oltra/use-cases/nic-examples/custom-resources/tls-passthrough``
1. Update NGINX
