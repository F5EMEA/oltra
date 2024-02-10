# Gitlab

## update Gitlab

Update

Change the image on the docker-compose.yaml
run again the following command
```bash
docker-compose up -d
```


## Installation (already done)

Here's a basic outline of how you can set it up:

Create a docker-compose.yaml
```yaml
version: '3.6'
services:
  web:
    image: 'gitlab/gitlab-ce:16.3.5-ce.0'
    restart: always
    hostname: 'git.f5k8s.net'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://git.f5k8s.net'
        registry_external_url 'https://registry.f5k8s.net'
        nginx['enable'] = true
        nginx['client_max_body_size'] = '250m'
        nginx['redirect_http_to_https'] = true
        nginx['ssl_certificate'] = "/etc/gitlab/ssl/f5k8s.crt"
        nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/f5k8s.key"
        nginx['ssl_ciphers'] = "HIGH:!aNULL:!MD5;"
        nginx['ssl_protocols'] = "TLSv1.1 TLSv1.2"
        registry_nginx['enable'] = true
        registry_nginx['redirect_http_to_https'] = true
        registry_nginx['listen_port'] = 443
        registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/f5k8s.crt"
        registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/f5k8s.key"
        # Add any other gitlab.rb configuration here, each on its own line
    ports:
      - '10.1.20.30:80:80'
      - '10.1.20.30:443:443'
      - '10.1.20.30:22:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
    shm_size: '256m'
```
