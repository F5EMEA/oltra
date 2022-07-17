sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/ns-and-sa.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/ns-and-sa.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/ap-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/ap-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/apdos-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/apdos-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/nginx-plus/nginx-infra.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-tenant1/' nginx_t1/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-tenant2/' nginx_t2/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-tenant1/' nginx_t1/nginx-plus/ingress-class-infra.yaml
sed -i 's/nginx-infra/nginx-tenant2/' nginx_t2/nginx-plus/ingress-class-infra.yaml
sed -i '38, 38d' nginx_t1/nginx-plus/svc-plus.yaml
sed -i '33, 33d' nginx_t1/nginx-plus/svc-plus.yaml
sed -i '1, 22d' nginx_t1/nginx-plus/svc-plus.yaml 
sed -i '38, 38d' nginx_t2/nginx-plus/svc-plus.yaml
sed -i '33, 33d' nginx_t2/nginx-plus/svc-plus.yaml
sed -i '1, 22d' nginx_t2/nginx-plus/svc-plus.yaml 
sed -i 's/type: NodePort/type: ClusterIP/' nginx_t1/nginx-plus/svc-plus.yaml
sed -i 's/type: NodePort/type: ClusterIP/' nginx_t2/nginx-plus/svc-plus.yaml
sed -i 's/nginx-infra/nginx-tenant-1/' nginx_t1/nginx-plus/svc-plus.yaml
sed -i 's/nginx-infra/nginx-tenant-2/' nginx_t2/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx-tenant-1/' nginx_t1/5-Publish-NGINX-with-CIS/transport.yml
sed -i 's/nginx-plus/nginx-tenant-2/' nginx_t2/5-Publish-NGINX-with-CIS/transport.yml
sed -i 's/namespace: nginx/namespace: tenant-1/' nginx_t1/5-Publish-NGINX-with-CIS/transport.yml
sed -i 's/namespace: nginx/namespace: tenant-2/' nginx_t2/5-Publish-NGINX-with-CIS/transport.yml
sed -i 's/virtualServerAddress: "10.1.10.40"/ipamLabel: "tenant-1"/' nginx_t1/5-Publish-NGINX-with-CIS/transport.yml
sed -i 's/virtualServerAddress: "10.1.10.40"/ipamLabel: "tenant-2"/' nginx_t2/5-Publish-NGINX-with-CIS/transport.yml
mv nginx_t1/nginx-plus/nginx-infra.yaml nginx_t1/nginx-plus/nginx.yaml
mv nginx_t2/nginx-plus/nginx-infra.yaml nginx_t2/nginx-plus/nginx.yaml
mv nginx_t1/nginx-plus/ingress-class-infra.yaml nginx_t1/nginx-plus/ingress-class.yaml
mv nginx_t2/nginx-plus/ingress-class-infra.yaml nginx_t2/nginx-plus/ingress-class.yaml
rm nginx_t1/nginx-plus/nginx-plus.yaml
rm nginx_t2/nginx-plus/nginx-plus.yaml
rm nginx_t1/nginx-plus/ingress-class-plus.yaml
rm nginx_t2/nginx-plus/ingress-class-plus.yaml
mv nginx_t1/nginx-plus/svc-plus.yaml nginx_t1/nginx-plus/svc.yaml
mv nginx_t2/nginx-plus/svc-plus.yaml nginx_t2/nginx-plus/svc.yaml
