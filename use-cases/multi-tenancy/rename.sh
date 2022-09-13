sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/ns-and-sa.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx_t1/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx_t2/rbac/ns-and-sa.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/ap-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx_t1/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx_t2/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-tenant1/' nginx_t1/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-tenant2/' nginx_t2/rbac/ap-rbac.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/apdos-rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx_t1/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx_t2/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-tenant1/' nginx_t1/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-tenant2/' nginx_t2/rbac/apdos-rbac.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/rbac.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/rbac.yaml
sed -i '1, 126d' nginx_t1/rbac/rbac.yaml
sed -i '1, 126d' nginx_t2/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-tenant1/' nginx_t1/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-tenant2/' nginx_t2/rbac/rbac.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/nginx-config.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-infra/name: nginx-tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-infra/name: nginx-tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-infra/app: nginx-tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-infra/app: nginx-tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/nginx-plus/nginx-tenant1/' nginx_t1/nginx-plus/ingress-class-plus.yaml
sed -i 's/nginx-plus/nginx-tenant2/' nginx_t2/nginx-plus/ingress-class-plus.yaml

sed -i '16, 16d' nginx_t1/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx_t1/nginx-plus/svc-plus.yaml
sed -i '16, 16d' nginx_t2/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx_t2/nginx-plus/svc-plus.yaml
sed -i 's/type: NodePort/type: ClusterIP/' nginx_t1/nginx-plus/svc-plus.yaml
sed -i 's/type: NodePort/type: ClusterIP/' nginx_t2/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx-tenant1/' nginx_t1/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx-tenant2/' nginx_t2/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/nginx-plus/svc-plus.yaml


rm -R nginx_t1/crds
rm -R nginx_t2/crds
rm -R nginx_t1/publish
rm -R nginx_t2/publish
rm nginx_t1/nginx-plus/svc-plus.yaml
rm nginx_t2/nginx-plus/svc-plus.yaml