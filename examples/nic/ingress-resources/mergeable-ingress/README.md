# Mergeable Ingress Types Support

You can spread the Ingress configuration for a common host across multiple Ingress resources using Mergeable Ingress resources. Such resources can belong to the same or different namespaces. This enables
easier management when using a large number of paths.

## Syntax and Rules

A Master is declared using `nginx.org/mergeable-ingress-type: master`. A Master will process all configurations at the
host level, which includes the TLS configuration, and any annotations which will be applied for the complete host. There
can only be one ingress resource on a unique host that contains the master value. Paths cannot be part of the
ingress resource.

Masters cannot contain the following annotations:
* nginx.org/rewrites
* nginx.org/ssl-services
* nginx.org/grpc-services
* nginx.org/websocket-services
* nginx.com/sticky-cookie-services
* nginx.com/health-checks
* nginx.com/health-checks-mandatory
* nginx.com/health-checks-mandatory-queue

A Minion is declared using `nginx.org/mergeable-ingress-type: minion`. A Minion will be used to append different
locations to an ingress resource with the Master value. TLS configurations are not allowed. Multiple minions can be
applied per master as long as they do not have conflicting paths. If a conflicting path is present then the path defined
on the oldest minion will be used.

Minions cannot contain the following annotations:
* nginx.org/proxy-hide-headers
* nginx.org/proxy-pass-headers
* nginx.org/redirect-to-https
* ingress.kubernetes.io/ssl-redirect
* nginx.org/hsts
* nginx.org/hsts-max-age
* nginx.org/hsts-include-subdomains
* nginx.org/server-tokens
* nginx.org/listen-ports
* nginx.org/listen-ports-ssl
* nginx.org/server-snippets

Minions inherent the following annotations from the master, unless they override them:
* nginx.org/proxy-connect-timeout
* nginx.org/proxy-read-timeout
* nginx.org/client-max-body-size
* nginx.org/proxy-buffering
* nginx.org/proxy-buffers
* nginx.org/proxy-buffer-size
* nginx.org/proxy-max-temp-file-size
* nginx.org/location-snippets
* nginx.org/lb-method
* nginx.org/keepalive
* nginx.org/max-fails
* nginx.org/fail-timeout

Note: Ingress Resources with more than one host cannot be used.

## Example

In this example we deploy the NGINX Ingress Controller, a simple web application and then configure
load balancing for that application using Ingress resources with the `nginx.org/mergeable-ingress-type` annotations.

## Running the Example

Use the terminal on VS Code. VS Code is under the `Client` on the `Access` drop-down menu. 

Change the working directory to `mergeable-ingress-types`.
```
cd ~/oltra/use-cases/nic-examples/ingress-resources/mergeable-ingress
```

## 1. Deploy the Cafe Application

Create the coffee and the tea deployments and services:
```
kubectl apply -f cafe.yaml
```

## 2. Configure Load Balancing

1. Create a secret with an SSL certificate and a key:
```
kubectl apply -f cafe-secret.yaml
```

2. Create the Master Ingress resource:
```
kubectl apply -f cafe-master.yaml
```

3. Create the Minion Ingress resource for the Coffee Service:
```
kubectl apply -f coffee-minion.yaml
```

4. Create the Minion Ingress resource for the Tea Service:
```
kubectl apply -f tea-minion.yaml
```

## 3. Test the Application

1. To access the application, curl the coffee and the tea services. We'll use ```curl```'s --insecure option to turn off certificate verification of our self-signed
certificate and the --resolve option to set the Host header of a request with ```cafe.example.com```

To get coffee:
```
curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/coffee --insecure


############  Expected Output ############# 
Server address: 10.244.196.190:8080
Server name: coffee-6f4b79b975-l8ht2
Date: 17/Sep/2022:06:05:33 +0000
URI: /coffee
Request ID: 667c72a5a04ae2170abd2ce039888524
```

If you prefer tea:
```
$ curl --resolve cafe.example.com:443:10.1.10.10 https://cafe.example.com:443/tea --insecure


############  Expected Output ############# 
Server address: 10.244.140.77:8080
Server name: tea-6fb46d899f-nvwmw
Date: 17/Sep/2022:06:06:36 +0000
URI: /tea
Request ID: e6e30d9a16755039e74e5d7554a6dd1a
```

## 4. Examine the Configuration

Access the NGINX Pod.
```
kubectl get pods -n nginx

############  Expected Output ############# 
NAME                           READY   STATUS    RESTARTS       AGE
nginx-plus-6d496bdb85-2z8qn    1/1     Running   0              18m
```

2. Examine the NGINX Configuration.
```
kubectl exec -it <NGINX POD NAME> -n nginx-ingress -- cat /etc/nginx/conf.d/default-cafe-ingress-master.conf


# configuration for default/cafe-ingress-master
upstream default-cafe-ingress-coffee-minion-cafe.example.com-coffee-svc-80 {
        zone default-cafe-ingress-coffee-minion-cafe.example.com-coffee-svc-80 512k;
        random two least_conn;
        server 10.244.140.72:8080 max_fails=1 fail_timeout=10s max_conns=0;
        server 10.244.196.190:8080 max_fails=1 fail_timeout=10s max_conns=0;
        keepalive 100;
}
upstream default-cafe-ingress-tea-minion-cafe.example.com-tea-svc-80 {
        zone default-cafe-ingress-tea-minion-cafe.example.com-tea-svc-80 512k;
        random two least_conn;
        server 10.244.140.77:8080 max_fails=1 fail_timeout=10s max_conns=0;
        server 10.244.196.133:8080 max_fails=1 fail_timeout=10s max_conns=0;
        server 10.244.196.151:8080 max_fails=1 fail_timeout=10s max_conns=0;
        keepalive 100;
}
server {
        listen 80;
        listen [::]:80;
        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate /etc/nginx/secrets/default-cafe-secret;
        ssl_certificate_key /etc/nginx/secrets/default-cafe-secret;
        server_tokens "on";
        server_name cafe.example.com;
        status_zone cafe.example.com;
        set $resource_type "ingress";
        set $resource_name "cafe-ingress-master";
        set $resource_namespace "default";
        if ($scheme = http) {
                return 301 https://$host:443$request_uri;
        }
        location /coffee {
                set $service "coffee-svc";
                # location for minion default/cafe-ingress-coffee-minion
                set $resource_name "cafe-ingress-coffee-minion";
                set $resource_namespace "default";
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                proxy_connect_timeout 60s;
                proxy_read_timeout 60s;
                proxy_send_timeout 60s;
                client_max_body_size 1m;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Port $server_port;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_buffering on;
                proxy_pass http://default-cafe-ingress-coffee-minion-cafe.example.com-coffee-svc-80;
        }
        location /tea {
                set $service "tea-svc";
                # location for minion default/cafe-ingress-tea-minion
                set $resource_name "cafe-ingress-tea-minion";
                set $resource_namespace "default";
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                proxy_connect_timeout 60s;
                proxy_read_timeout 60s;
                proxy_send_timeout 60s;
                client_max_body_size 1m;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Port $server_port;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_buffering on;
                proxy_pass http://default-cafe-ingress-tea-minion-cafe.example.com-tea-svc-80;
        }
}
```


***Clean up the environment (Optional)***
```
kubectl delete -f .
```  