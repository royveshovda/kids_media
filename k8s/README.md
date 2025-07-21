# Kubernetes Deployment Configuration

This directory contains Kubernetes configuration files for deploying the KidsMedia Phoenix LiveView application.

## Files

- `deployment.yaml` - Main application deployment with secrets
- `service.yaml` - ClusterIP service to expose the application internally
- `ingress.yaml` - Ingress configuration with NGINX and SSL/TLS

## Prerequisites

1. **Kubernetes cluster** with NGINX Ingress Controller installed
2. **cert-manager** (optional, for automatic SSL certificates)
3. **Container registry access** to GitHub Container Registry (GHCR)

## Configuration Steps

### 1. Update Secrets

Edit `deployment.yaml` and replace the placeholder values:

```yaml
stringData:
  secret-key-base: "CHANGE_ME_64_CHAR_SECRET_KEY_BASE_FOR_PHOENIX_APP_SECURITY"
  unsplash-access-key: "YOUR_UNSPLASH_ACCESS_KEY_HERE"
```

Generate a secret key base:
```bash
mix phx.gen.secret
```

### 2. Configure Container Registry Access

If using a private registry, create the Docker config secret:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_TOKEN \
  --docker-email=YOUR_EMAIL
```

For public images, remove the `imagePullSecrets` section from `deployment.yaml`.

### 3. Update Domain

Replace `kids-media.example.com` in both `deployment.yaml` (PHX_HOST) and `ingress.yaml` with your actual domain.

### 4. SSL/TLS Configuration

The ingress is configured for automatic SSL using cert-manager. If you don't have cert-manager:

- Remove the `cert-manager.io/cluster-issuer` annotation
- Remove the `tls` section from ingress
- Set `nginx.ingress.kubernetes.io/ssl-redirect: "false"`

## Deployment

Apply the configurations in order:

```bash
# Apply deployment and service
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Apply ingress
kubectl apply -f k8s/ingress.yaml
```

Or apply all at once:
```bash
kubectl apply -f k8s/
```

## Verification

Check deployment status:
```bash
# Check pods
kubectl get pods -l app=kids-media

# Check service
kubectl get service kids-media-service

# Check ingress
kubectl get ingress kids-media-ingress

# Check logs
kubectl logs -l app=kids-media
```

## Scaling

Scale the application:
```bash
kubectl scale deployment kids-media --replicas=5
```

## Environment Variables

The application uses these environment variables:

- `PORT`: Application port (4000)
- `SECRET_KEY_BASE`: Phoenix secret key base (from secret)
- `UNSPLASH_ACCESS_KEY`: Unsplash API key (from secret)
- `PHX_HOST`: External hostname for Phoenix
- `MIX_ENV`: Elixir environment (prod)

## Resource Limits

Current resource configuration:
- **Requests**: 256Mi memory, 250m CPU
- **Limits**: 512Mi memory, 500m CPU

Adjust based on your cluster capacity and application needs.

## Health Checks

The deployment includes:
- **Liveness probe**: Checks if app is running (restarts if failing)
- **Readiness probe**: Checks if app can receive traffic
- **Startup probe**: Gives extra time during initial startup

## Troubleshooting

Common issues:

1. **ImagePullBackOff**: Check registry credentials and image name
2. **CrashLoopBackOff**: Check logs for application errors
3. **503 errors**: Check service selector and pod labels match
4. **SSL issues**: Verify cert-manager is working and domain is correct

Check application logs:
```bash
kubectl logs -l app=kids-media --tail=100
```

## Production Considerations

- Use a proper secret management solution (e.g., HashiCorp Vault, AWS Secrets Manager)
- Set up monitoring and alerting
- Configure resource limits based on load testing
- Use horizontal pod autoscaling (HPA) for automatic scaling
- Consider using a service mesh for advanced networking features