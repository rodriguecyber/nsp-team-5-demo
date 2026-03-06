# AWS OIDC setup for GitHub Actions

The CI pipeline uses **OIDC** to assume an IAM role (no long-lived access keys in GitHub).

## 1. Create GitHub OIDC provider in IAM (one-time per account)

- IAM → Identity providers → Add provider
- **Provider type:** OpenID Connect
- **Provider URL:** `https://token.actions.githubusercontent.com`
- **Audience:** `sts.amazonaws.com`

## 2. Create IAM role for the workflow

Create a role that GitHub Actions can assume.

**Trust policy** (replace `ORG` and `REPO` with your GitHub org/owner and repo name):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:*"
        }
      }
    }
  ]
}
```

To restrict to `main` only, use:

```json
"token.actions.githubusercontent.com:sub": "repo:ORG/REPO:ref:refs/heads/main"
```

**Permissions:** Attach a policy (or inline) that allows:

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`, `ecr:GetDownloadUrlForLayer`, `ecr:BatchGetImage`
- `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`
- `ecs:UpdateService`, `ecs:DescribeServices` (for the ECS deploy step)

Or attach **AmazonEC2ContainerRegistryPowerUser** (or **AmazonEC2ContainerRegistryFullAccess**) + **AmazonECS_FullAccess** (or a custom ECS update-only policy).

## 3. Create ECR repository

If it doesn’t exist:

```bash
aws ecr create-repository --repository-name communityboard-backend
```

## 4. GitHub repository secrets

In the repo: **Settings → Secrets and variables → Actions**, add:

| Secret           | Description                                      |
|------------------|--------------------------------------------------|
| `AWS_ROLE_ARN`   | ARN of the IAM role (e.g. `arn:aws:iam::123456789012:role/github-actions-ecr`) |
| `AWS_REGION`     | Region for ECR/ECS (e.g. `us-east-1`)            |

No `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` needed when using OIDC.
