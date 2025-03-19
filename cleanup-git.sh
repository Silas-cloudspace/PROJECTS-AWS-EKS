#!/bin/bash
# Comprehensive Git repo cleanup script

# 1. Create a proper .gitignore for Terraform
echo "# Terraform .gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which might contain sensitive data
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI configuration files
.terraformrc
terraform.rc

# Provider lock file
.terraform.lock.hcl

# Local provider binaries
**/.terraform/providers/**
" > .gitignore

# 2. Add and commit the .gitignore file
git add .gitignore
git commit -m "Add comprehensive Terraform .gitignore"

# 3. Use BFG to remove large files (if BFG is installed)
# Uncomment and use this if you have BFG installed
# java -jar bfg.jar --strip-blobs-bigger-than 100M .

# 4. Alternative: Use git filter-repo to remove large files
# This requires git-filter-repo to be installed
# git filter-repo --strip-blobs-bigger-than 100M

# 5. If you don't have the tools above, use git filter-branch
# This can be slow but works without additional tools
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch Dynamic-App-with-Kubernetes-and-EKS/platform/.terraform/providers/registry.terraform.io/hashicorp/aws/5.91.0/windows_amd64/terraform-provider-aws_v5.91.0_x5.exe Dynamic-App-with-Kubernetes-and-EKS/platform/remote_backend/.terraform/providers/registry.terraform.io/hashicorp/aws/5.91.0/windows_amd64/terraform-provider-aws_v5.91.0_x5.exe" \
  --prune-empty --tag-name-filter cat -- --all

# 6. Clean up refs and perform garbage collection
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 7. Force push to remote
git push --force

echo "Cleanup complete! If you still have issues, you may need to use BFG or git-filter-repo tools for a more thorough cleanup."