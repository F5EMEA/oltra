# OpenID Connect Custom Authorization Flow

This use-case comes from a prospect providing a SaaS based scheduling and people management solution in the health sector. The requirement was for a Kubernetes Ingress solution which could integrate with a customers iDP and provide OIDC authentication information to an API services pods.

- [OpenID Connect Custom Authorization Flow](#openid-connect-custom-authorization-flow)
- [The problem](#the-problem)
- [](#)

# The problem

The OIDC authentication requirements for a service/location wouldn't be known prior to accessing the API, so the customer only wanted the OIDC flow to operate when the Ingress received a `HTTP 401` response from the API pod. In other words we needed to pass through a request to the upstream as-is, and only kick off OIDC if the backend denied the request. This is not how the out-of-the-box templates operate. Customization would be required.

The default OIDC location authentication directives would attempt to authorize inbound connections with `auth_jwt` and kick off OIDC via `@do_oidc_flow` if the authorization failed. This is the behaviour we needed to change.

```yml
    {{ if $l.OIDC }}
        auth_jwt "" token=$session_jwt;
        error_page 401 = @do_oidc_flow;
        auth_jwt_key_request /_jwks_uri;
        {{ $proxyOrGRPC }}_set_header username $jwt_claim_sub;
    {{ end }}
```
> source: [NGINX Plus virtualserver template](https://github.com/nginxinc/kubernetes-ingress/blob/main/internal/configs/version2/nginx-plus.virtualserver.tmpl)

# The Solution

We needed to control when the OIDC flow was started. The solution was to pass all unauthenticated requests to the backend, but to validate JWTs on requests which already had tokens. In the event that an unauthenticated client recieved a `HTTP 401`, then we start the OIDC flow. This required adding a `map` to the server context:

```yml
    {{ with $oidc := $s.OIDC }}
    map $session_jwt $do_oidc_auth {
      default   "";
      ""        "off";
    }
    {{ end }}
```

This sets a variable called `$do_oidc_auth` which would either be empty if a `$session_jwt` variable existed (indicating a token was present), or set to "off" if no such token existed. With this added to the server block, we could modify the location template to look like this:

```yml
    {{ if $l.OIDC }}
        {{ $proxyOrGRPC }}_intercept_errors on;
        auth_jwt $do_oidc_auth token=$session_jwt;
        error_page 401 = @do_oidc_flow;
        auth_jwt_key_request /_jwks_uri;
        {{ $proxyOrGRPC }}_set_header username $jwt_claim_sub;
        {{ $proxyOrGRPC }}_set_header jwtToken $session_jwt;
    {{ end }}
```
Now the `jwt_auth` directive uses the `$do_oidc_auth` variable to determine whether to authenticate the user or not, and the `proxy_intercept_errors` directive is required for the `@do_oidc_auth` flow to operate in the case where a `HTTP 401` is received from the upstream. We also pass through the full JWT Token to the upstream in a header called jwtToken.

With these few changes we were able to completely change the way the OIDC flow was implemented in the Ingress Controller.
