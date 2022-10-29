# NGINX Ingress - Custom Templates

The Ingress Controller has two methods which enable users to create custom configurations beyond the out-of-the-box features we provide. They are `snippets` and `custom templates`. The simpler to use is the `snippet` which comes in a couple of different forms, allowing the user to insert code into the `main`, `http`, `server` or `location` contexts. There is also a `stream` snippet for TCP/UDP services. 

If however, the end user needs to modify the behaviour of the NIC (eg change how an existing feature is implemented), then they need `custom templates` with optionally `custom annotations`. There are three templates which can be modified by the end user: `main`, `ingress` and `virtualserver`.

- [NGINX Ingress - Custom Templates](#nginx-ingress---custom-templates)
- [Using Snippets](#using-snippets)
- [Using Custom Templates](#using-custom-templates)
  - [Using templates with Custom Annotations](#using-templates-with-custom-annotations)
- [Examples](#examples)


# Using Snippets

In order to utilize snippets an end-user must pass the `enable-snippets` command line argument to the Ingress Controller deployment. Snippets are disabled by default because they decrease the security and robustness of the Ingress by allowing application developers to inject directives directly into the NGINX Ingress configuration.

A platform operator who is concerned about this can opt to customise NGINX through custom templates and custom annotations instead.

#  Using Custom Templates

Custom templates are less risky than snippets because they can only be applied by the platform operator via the global `ConfigMap`. However they pass the burden of maintaining the customer feature from the application owner to the platform team. The alternative may be to give each application owner their own Ingress Controller.

## Using templates with Custom Annotations

One way a platform team can provide custom functionality is to use a custom template in coordination with custom annotations. This enables the additional functionality in the template to be controlled by the application developer by providing annotations to their Ingress resources.

# Examples

* [OpenID Connect Custom Authentication Flow](custom-oidc-flow/)


