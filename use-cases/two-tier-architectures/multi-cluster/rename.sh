sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/rbac/ns-and-sa.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx_t1/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx_t2/rbac/ns-and-sa.yaml

sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/rbac/ap-rbac.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx_t1/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx_t2/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-cluster1/' nginx_t1/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-cluster2/' nginx_t2/rbac/ap-rbac.yaml

sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/rbac/apdos-rbac.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx_t1/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx_t2/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-cluster1/' nginx_t1/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-cluster2/' nginx_t2/rbac/apdos-rbac.yaml

sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/rbac/rbac.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/rbac/rbac.yaml
sed -i '1, 126d' nginx_t1/rbac/rbac.yaml
sed -i '1, 126d' nginx_t2/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-cluster1/' nginx_t1/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-cluster2/' nginx_t2/rbac/rbac.yaml

sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/resources/nginx-config.yaml

sed -i 's/namespace: nginx/namespace: cluster1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-cluster1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-cluster2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-cluster1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-cluster2/' nginx_t2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-cluster1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx-cluster1/' nginx_t1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx-cluster2/' nginx_t2/nginx-plus/nginx-plus.yaml

sed -i '4s/name: nginx/name: nginx-cluster1/' nginx_t1/nginx-plus/ingress-class-plus.yaml
sed -i '4s/name: nginx/name: nginx-cluster2/' nginx_t2/nginx-plus/ingress-class-plus.yaml

sed -i 's/nginx-plus/nginx-cluster1/' nginx_t1/nginx-plus/ingress-class-plus.yaml
sed -i 's/nginx-plus/nginx-cluster2/' nginx_t2/nginx-plus/ingress-class-plus.yaml

sed -i '16, 16d' nginx1/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx1/nginx-plus/svc-plus.yaml
sed -i '16, 16d' nginx2/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx2/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx1-plus/' nginx1/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx2-plus/' nginx2/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: cluster1/' nginx1/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: cluster2/' nginx2/nginx-plus/svc-plus.yaml


rm -R nginx_t1/crds
rm -R nginx_t2/crds
rm -R nginx_t1/publish
rm -R nginx_t2/publish
