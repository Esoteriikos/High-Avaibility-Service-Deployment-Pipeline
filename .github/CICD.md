# CI/CD Setup Guide

This project includes a complete CI/CD pipeline using GitHub Actions.

## 🔧 Setup Instructions

### 1. Configure Docker Hub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add the following secrets:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token

### 2. Configure Kubernetes Secrets (Optional - for auto-deployment)

For staging environment:
- `KUBE_CONFIG_STAGING`: Base64-encoded kubeconfig for staging cluster

For production environment:
- `KUBE_CONFIG_PRODUCTION`: Base64-encoded kubeconfig for production cluster

To get base64-encoded kubeconfig:
```bash
cat ~/.kube/config | base64 -w 0
```

### 3. Update Docker Image Name

In `.github/workflows/deploy.yml`, update:
```yaml
env:
  DOCKER_IMAGE: your-dockerhub-username/fastapi-service
```

### 4. Update Domain Names

Replace placeholder domains in the workflow:
- `staging.your-domain.com` → Your staging domain
- `api.your-domain.com` → Your production domain

## 🚀 Workflow Overview

### Triggers
- **Push to main**: Builds, tests, and deploys to production
- **Push to develop**: Builds, tests, and deploys to staging
- **Pull requests**: Builds and runs tests only
- **Manual**: Can be triggered via "Run workflow" button

### Jobs

1. **Build** 
   - Builds Docker image
   - Pushes to Docker Hub with commit SHA and 'latest' tags
   - Uses build cache for faster builds

2. **Test**
   - Runs unit tests
   - Performs smoke tests on built image

3. **Deploy Staging** (develop branch)
   - Deploys to staging Kubernetes cluster
   - Runs verification checks

4. **Deploy Production** (main branch)
   - Deploys to production Kubernetes cluster
   - Includes monitoring stack (Prometheus/Grafana)
   - Runs smoke tests post-deployment

5. **Load Test** (staging only)
   - Runs Locust load tests
   - Uploads HTML report as artifact

6. **Notify**
   - Sends deployment status notifications

## 🌍 Environment Setup

### Local Development
```bash
git checkout develop
# Make changes
git commit -m "feat: add new feature"
git push origin develop
# Triggers: build → test → deploy-staging → load-test
```

### Production Release
```bash
git checkout main
git merge develop
git push origin main
# Triggers: build → test → deploy-production
```

## 📊 Viewing Results

### Build Artifacts
- Go to Actions tab → Select workflow run
- Download "load-test-report" artifact

### Deployment Logs
- Check "Deploy to Production" job logs
- Monitor pod status in Kubernetes dashboard

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use environment protection rules** for production
3. **Require PR reviews** before merging to main
4. **Enable branch protection** on main/develop
5. **Rotate secrets regularly**

## 🎯 Customization

### Add More Tests
Edit the `test` job in `deploy.yml`:
```yaml
- name: Run unit tests
  run: pytest tests/unit/
```

### Add Notifications
Add notification steps to the `notify` job:
```yaml
- name: Slack notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Add Database Migrations
Add before deployment:
```yaml
- name: Run migrations
  run: kubectl exec deployment/fastapi-deployment -- python manage.py migrate
```

## 🐛 Troubleshooting

### Build Failures
- Check Dockerfile syntax
- Verify dependencies in requirements.txt
- Check GitHub Actions logs

### Deployment Failures
- Verify kubeconfig is correct
- Check Kubernetes cluster connectivity
- Verify image exists in Docker Hub

### Test Failures
- Review test logs in Actions tab
- Run tests locally to reproduce
- Check if services are accessible

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Kubernetes Set Context Action](https://github.com/Azure/k8s-set-context)

---

**Happy Deploying! 🚀**
