sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/sa.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/sa.yaml


sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/ap-rbac.yaml # Change the namespace to tenant1 on the ClusterRoleBinding
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/ap-rbac.yaml # Change the namespace to tenant2 on the ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t1/rbac/ap-rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t2/rbac/ap-rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-tenant1/' nginx_t1/rbac/ap-rbac.yaml # change ClusterRoleBinding name (adding tenant1)
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-tenant2/' nginx_t2/rbac/ap-rbac.yaml # change ClusterRoleBinding name (adding tenant2)

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/apdos-rbac.yaml # Change the namespace to tenant1 on the ClusterRoleBinding
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/apdos-rbac.yaml # Change the namespace to tenant2 on the ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t1/rbac/apdos-rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t2/rbac/apdos-rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-tenant1/' nginx_t1/rbac/apdos-rbac.yaml # change ClusterRoleBinding name (adding tenant1)
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-tenant2/' nginx_t2/rbac/apdos-rbac.yaml # change ClusterRoleBinding name (adding tenant2)

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/rbac/rbac.yaml # Change the namespace to tenant1 on the ClusterRoleBinding
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/rbac/rbac.yaml # Change the namespace to tenant2 on the ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t1/rbac/rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i -n '/^kind: ClusterRoleBinding$/,$p' nginx_t2/rbac/rbac.yaml # Remove the ClusterRole but keep ClusterRoleBinding
sed -i '4s/name: nginx-ingress/name: nginx-ingress-tenant1/' nginx_t1/rbac/rbac.yaml # change ClusterRoleBinding name (adding tenant1)
sed -i '4s/name: nginx-ingress/name: nginx-ingress-tenant2/' nginx_t2/rbac/rbac.yaml # change ClusterRoleBinding name (adding tenant2)

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/resources/nginx-config.yaml

sed -i 's/namespace: nginx/namespace: tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/namespace: nginx/namespace: tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-tenant2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-tenant1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx-tenant1-plus/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx-tenant2-plus/' nginx_t2/nginx-plus/nginx-plus.yaml

sed -i '4s/name: nginx/name: nginx-tenant1/' nginx_t1/nginx-plus/ingress-class-plus.yaml
sed -i '4s/name: nginx/name: nginx-tenant2/' nginx_t2/nginx-plus/ingress-class-plus.yaml

sed -i 's/nginx-plus/nginx-tenant1/' nginx_t1/nginx-plus/ingress-class-plus.yaml
sed -i 's/nginx-plus/nginx-tenant2/' nginx_t2/nginx-plus/ingress-class-plus.yaml



rm -R nginx_t1/crds
rm -R nginx_t2/crds
rm -R nginx_t1/publish
rm -R nginx_t2/publish
rm nginx_t1/nginx-plus/svc-plus.yaml
rm nginx_t2/nginx-plus/svc-plus.yaml
rm nginx_t1/rbac/ns.yaml
rm nginx_t2/rbac/ns.yaml
rm nginx_t1/README.md
rm nginx_t2/README.md
