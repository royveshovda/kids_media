# Docker Deployment Guide

This document describes how to build and deploy the KidsMedia application using Docker and Google Container Registry (GCR).

## Docker Build

The application includes a multi-stage Dockerfile optimized for Phoenix applications:

### Local Development
```bash
# Build the Docker image
docker build -t kids-media:local .

# Run the container (requires environment variables)
docker run -p 4000:4000 \
  -e SECRET_KEY_BASE=your_secret_key \
  -e UNSPLASH_ACCESS_KEY=your_unsplash_key \
  -e PHX_HOST=localhost \
  kids-media:local
```

### Environment Variables

The following environment variables are required for production deployment:

- `SECRET_KEY_BASE` - Phoenix secret key (generate with `mix phx.gen.secret`)
- `UNSPLASH_ACCESS_KEY` - Unsplash API access key
- `PHX_HOST` - Domain name for the application
- `PORT` - Port number (default: 4000)

## Google Container Registry (GCR) Deployment

### GitHub Actions Setup

The repository includes automated workflows for building and deploying to GCR:

#### 1. Main Branch Deployment (`deploy.yml`)
- Triggers on pushes to `main` branch
- Builds and pushes Docker image to GCR
- Tags images with both commit SHA and `latest`
- Optionally deploys to Google Cloud Run

#### 2. PR Validation (`pr.yml`) 
- Triggers on pull requests
- Builds Docker image to verify it compiles successfully
- Uses build cache to speed up builds

### Required GitHub Secrets

Configure these secrets in your GitHub repository:

**Google Cloud Authentication:**
- `GCP_PROJECT_ID` - Your Google Cloud project ID
- `WIF_PROVIDER` - Workload Identity Federation provider
- `WIF_SERVICE_ACCOUNT` - Service account for deployment

**Application Configuration:**
- `UNSPLASH_ACCESS_KEY` - Unsplash API key
- `SECRET_KEY_BASE` - Phoenix secret key
- `PHX_HOST` - Production domain name

**Optional Configuration:**
- `GAR_LOCATION` - Google Artifact Registry location (default: us-central1)
- `DEPLOY_REGION` - Cloud Run deployment region (default: us-central1)

### Google Cloud Setup

1. **Create a Google Cloud Project**
2. **Enable Required APIs:**
   ```bash
   gcloud services enable artifactregistry.googleapis.com
   gcloud services enable run.googleapis.com
   ```

3. **Create Artifact Registry Repository:**
   ```bash
   gcloud artifacts repositories create kids-media \
     --repository-format=docker \
     --location=us-central1
   ```

4. **Setup Workload Identity Federation:**
   ```bash
   # Create service account
   gcloud iam service-accounts create github-actions
   
   # Grant permissions
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:github-actions@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/artifactregistry.writer"
   
   # Create workload identity pool and provider
   gcloud iam workload-identity-pools create "github-pool" \
     --location="global"
   
   gcloud iam workload-identity-pools providers create-oidc "github-provider" \
     --location="global" \
     --workload-identity-pool="github-pool" \
     --issuer-uri="https://token.actions.githubusercontent.com" \
     --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"
   ```

## Docker Image Structure

The Dockerfile uses a multi-stage build:

1. **Builder Stage** (`hexpm/elixir` image):
   - Installs build dependencies
   - Downloads and compiles Elixir dependencies
   - Compiles assets (CSS, JS)
   - Creates production release

2. **Runtime Stage** (`debian:bookworm-slim`):
   - Minimal runtime environment
   - Only includes compiled release
   - Runs as non-root user for security
   - Optimized for small size and security

## Troubleshooting

### Common Issues

1. **SSL Certificate Errors in Local Build:**
   - This can occur in containerized environments
   - The issue does not affect GitHub Actions builds
   - Use `--network host` flag if needed locally

2. **Missing Environment Variables:**
   - Ensure all required environment variables are set
   - Check GitHub secrets configuration
   - Verify Workload Identity Federation setup

3. **Build Failures:**
   - Check that all dependencies are properly specified in `mix.exs`
   - Ensure asset compilation succeeds
   - Verify release configuration is correct

### Logs and Debugging

```bash
# View container logs
docker logs <container-id>

# Run container interactively for debugging
docker run -it kids-media:local /bin/bash

# Check GitHub Actions logs in the repository's Actions tab
```

## Security Considerations

- The application runs as a non-root user (`nobody`)
- SSL/TLS is handled by the reverse proxy (Cloud Run, load balancer)
- Secrets are managed through GitHub Secrets and Google Secret Manager
- Container images are scanned for vulnerabilities in Google Container Registry