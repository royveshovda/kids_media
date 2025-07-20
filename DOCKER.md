# Docker Deployment Guide

This document describes how to build and deploy the KidsMedia application using Docker and GitHub Container Registry (GHCR).

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

## GitHub Container Registry (GHCR) Deployment

### GitHub Actions Setup

The repository includes automated workflows for building and deploying to GHCR:

#### 1. Main Branch Deployment (`deploy.yml`)
- Triggers on pushes to `main` branch
- Builds and pushes Docker image to GitHub Container Registry
- Tags images with date-based versioning (YYYY.MM.DD.MMMMM) and `latest`
- Uses GitHub token for authentication

#### 2. PR Validation (`pr.yml`) 
- Triggers on pull requests
- Builds Docker image to verify it compiles successfully
- Uses build cache to speed up builds

### Date-Based Versioning

Images are automatically tagged with a date-based version format:
- **Format**: `YYYY.MM.DD.MMMMM`
- **YYYY**: 4-digit year
- **MM**: 2-digit month
- **DD**: 2-digit day  
- **MMMMM**: Minutes since midnight (allows multiple builds per day)

**Examples**:
- `2024.01.15.825` - Built on January 15, 2024 at 13:45 (825 minutes since midnight)
- `2024.03.22.1200` - Built on March 22, 2024 at 20:00 (1200 minutes since midnight)

### Required GitHub Secrets

Configure these secrets in your GitHub repository:

**Application Configuration:**
- `UNSPLASH_ACCESS_KEY` - Unsplash API key
- `SECRET_KEY_BASE` - Phoenix secret key
- `PHX_HOST` - Production domain name

**Note**: The `GITHUB_TOKEN` is automatically provided by GitHub Actions for container registry access.

### GitHub Container Registry Setup

1. **Enable Container Registry** (if not already enabled):
   - Go to your GitHub repository settings
   - Navigate to "Packages" 
   - Container registry is enabled by default for public repositories

2. **Access Your Images**:
   ```bash
   # Pull the latest image
   docker pull ghcr.io/royveshovda/kids_media:latest
   
   # Pull a specific version
   docker pull ghcr.io/royveshovda/kids_media:2024.01.15.825
   ```

3. **Run the Image**:
   ```bash
   docker run -p 4000:4000 \
     -e SECRET_KEY_BASE=your_secret_key \
     -e UNSPLASH_ACCESS_KEY=your_unsplash_key \
     -e PHX_HOST=your_domain.com \
     ghcr.io/royveshovda/kids_media:latest
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

3. **Build Failures:**
   - Check that all dependencies are properly specified in `mix.exs`
   - Ensure asset compilation succeeds
   - Verify release configuration is correct

4. **Container Registry Access Issues:**
   - Ensure repository has proper package permissions
   - For private repositories, authenticate with GitHub token
   - Check that `GITHUB_TOKEN` has `packages:write` permission

### Logs and Debugging

```bash
# View container logs
docker logs <container-id>

# Run container interactively for debugging
docker run -it ghcr.io/royveshovda/kids_media:latest /bin/bash

# Check GitHub Actions logs in the repository's Actions tab
```

### Manual Docker Operations

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Build and tag locally
docker build -t ghcr.io/royveshovda/kids_media:manual .

# Push manually (if needed)
docker push ghcr.io/royveshovda/kids_media:manual
```

## Security Considerations

- The application runs as a non-root user (`nobody`)
- SSL/TLS is handled by the reverse proxy (load balancer, ingress controller)
- Secrets are managed through GitHub Secrets
- Container images are automatically scanned for vulnerabilities in GitHub Container Registry
- Access to packages can be controlled through GitHub's package permissions