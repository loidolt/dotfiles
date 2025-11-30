# Infrastructure Project Template

This template provides a complete infrastructure development environment using devbox.

## Tools Included

- **ansible** - IT automation platform
- **ansible-lint** - Ansible playbook linter
- **yamllint** - YAML linter
- **terraform** - Infrastructure as Code tool
- **packer** - Automated image builder
- **jq** - JSON processor

## Quick Start

1. Copy `devbox.json` to your infrastructure project root
2. Run `devbox shell` to enter the environment
3. All tools will be available in your PATH

## Usage

### Enter the development shell
```bash
devbox shell
```

### Ansible workflows
```bash
# Check playbook syntax
devbox run ansible-check

# Lint playbooks
devbox run ansible-lint

# Lint YAML files
devbox run yaml-lint

# Run playbook
ansible-playbook -i inventory.ini playbook.yml

# Run with check mode (dry run)
ansible-playbook -i inventory.ini playbook.yml --check

# Run specific tags
ansible-playbook -i inventory.ini playbook.yml --tags "web,db"
```

### Terraform workflows
```bash
# Initialize
devbox run tf-init

# Plan changes
devbox run tf-plan

# Format code
devbox run tf-fmt

# Validate configuration
devbox run tf-validate

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Manual commands in shell
```bash
devbox shell

# Ansible
ansible all -m ping -i inventory.ini
ansible-playbook site.yml
ansible-galaxy install -r requirements.yml

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy

# Packer
packer build template.pkr.hcl
packer validate template.pkr.hcl
```

## Project Structure

### Ansible project
```
.
├── devbox.json
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── roles/
│   └── common/
│       ├── tasks/
│       ├── handlers/
│       ├── templates/
│       └── vars/
└── group_vars/
    └── all.yml
```

### Terraform project
```
.
├── devbox.json
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Example Configurations

### .yamllint
```yaml
extends: default

rules:
  line-length:
    max: 120
    level: warning
  indentation:
    spaces: 2
```

### ansible.cfg
```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
retry_files_enabled = False
```

## Customization

Edit `devbox.json` to:
- Add cloud CLI tools (e.g., `awscli2`, `google-cloud-sdk`, `azure-cli`)
- Add other IaC tools (e.g., `pulumi`, `opentofu`)
- Add configuration management tools (e.g., `chef`, `puppet`)
- Modify scripts for your workflow

Search for packages at: https://search.nixos.org/packages

## Security Notes

**Never commit sensitive data:**
- Add to `.gitignore`:
  ```
  *.tfvars
  *.tfstate
  *.tfstate.backup
  .terraform/
  vault-password.txt
  *.pem
  *.key
  ```
- Use environment variables or secret management tools
- Use Ansible Vault for encrypted variables
- Use Terraform encrypted backends
