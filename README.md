# Infra Setup and Details:

The Infrastructure is configured  using Opensource IAAC and Configuration management tools and hosted in AWS.

## Summary:
- **Terraform** to create  cloud infrastructure
- **Ansible** to provision Virtual Machines and set up the **Docker Swarm** cluster
- **Ansible** again to deploy docker stacks

#### Infra Tech Stack:

|  Cloud |  AWS   |
| ------------ | ------------ |
| IAAC  | [Terraform](https://www.terraform.io/ "Terraform") |
| Configuration Management  | [Ansible](https://www.ansible.com/ "Ansible") |
| Container Engine  | [Docker](https://www.docker.com/ "Docker")  |
|  Container Orchestration  |  [Docker-Swarm](https://docs.docker.com/engine/swarm/ "Docker-Swarm") |
| Reverse Proxy  |  [Traefik](https://containo.us/traefik/ "Traefik") |
| SSL   |  [LetsEncrypt](https://letsencrypt.org/ "LetsEncrypt") |
| CI/CD   | [GoCD](https://www.gocd.org/ "GoCD") |

###  Ansible Folder Details:
**files**  ==> Static files that are copied to destination servers based on playbook tasks are placed here.

**group_vars**  ==> Variables need for ansible tasks/roles are defined here.

**inventories ** ==> Ansible Inventory folder where terraform writes the host details after infra is provisioned.

**roles**  ==> Docker-Stack,MongoDB Configuration are defined here.

 **stacks** ==> Services to be deployed in Docker Swarm are placed here, Docker-Stack Role reads the files and deploy it to Swarm Cluster.

**vault** ==> Stores the Ansible Vault Key. Used to Encrypt Files. **[Keep it secure]**

### Terraform Folder Details:
**environments** ==> Different Environments can be setup in AWS by creating folders like production,staging etc..  

**production** ==> Creating a production infrastrucure in AWS using aws module in modules folder

**modules** ==> Contains Terraform modules to setup infra.

### Infra-Automation :

On top of that, it features:

- A companion CLI (`./infra-automation`), which is a wrapper around Terraform and Ansible commands. For example: `ansible-playbook -i inventories/production -D --vault-id production@vault_keys/production deploy.yml` becomes `./infra-automation ansible-playbook production deploy`. **More convenient**

- Docker Swarm Compose files templated with Jinja2, so you can define your services once, while being able to customize them in each environment, from the same file

- AES-256 encryption of your production credentials with ansible-vault

## :rocket: Quick start

### 1. Make this repository yours

Clone this repo,

```bash
git clone --single-branch https://github.com/dhileepbalaji/docker-swarm-terraform-ansible
cd docker-swarm-terraform-ansible
git remote set-url origin <YOUR_REPO_URL>
git push
```

### 2. Install the required dependencies

This will install Ansible and Terraform on your local machine:

```bash
./infra-automation install-dependencies
```

You can also manually install the dependencies if your preferer.

### 3. Edit and encrypt  production environment variables

Before going further, you should edit your production group_vars files:

- `ansible/group_vars/production.yml`
- `ansible/group_vars/production_encrypted.yml`
  
When you are done, **do not commit `production_encrypted.yml`**! You have to encrypt it first:

- `./infra-automation ansible-vault production init-key`
- `./infra-automation  ansible-vault production encrypt ansible/group_vars/production_encrypted.yml`

The first command has generated a random key in `ansible/vault_keys/production`.
You must not commit this file. You should keep it in a safe place, and share it with  authorized team members securely.
**If you lose it, you won't be able to decrypt your files anymore.** 
The second command has encrypted your file with AES-256. You can now commit it.

You can still edit this file by running `./infra-automation ansible-vault production edit ansible/group_vars/production_encrypted.yml`. Always check that you do not commit an unencrypted version of this file by mistake.

### 4. Create, provision and deploy  production environment with Terraform

Its time to create and deploy  production environment!

The `terraform/environments/production` is an AWS Cloud Setup
To make it work, you should:

- Have a working SSH key pair
- [Install AWS CLI](https://docs.aws.amazon.com/fr_fr/cli/latest/userguide/cli-chap-install.html): `pip3 install awscli --upgrade --user`
- Configure your credentials: `aws configure`

Terraform will use this default profile credentials.

Then, you can run `./infra-automation terraform production init` and `./infra-automation terraform production apply`.

This will create:

- A custom VPC
- 3 subnets into separate Availability Zones, for high availability
- 1 manager node and 2 worker nodes (with spread placement groups, for high availability)
- S3 Bucket for Docker Registry
- IAM roles for S3 bucket access from nodes

The CLI will also create the corresponding Ansible inventory  in `ansible/inventories/production` from Terraform outputs. 

Finally,  run `./infra-automation ansible-playbook production all`  to setup docker swarm,MongoDB,GoCD and Traefik.






## :question: FAQ

### Where is the Infra-Automation CLI documentation? <!-- omit in toc -->

There is no documentation of the CLI since you will probably modify it, or add new commands!
To get some help, just run `./infra-automation`. Do not hesitate also to have a look at the source into the `scripts` directory. This CLI is just a wrapper of Terraform, Ansible and Vagrant commands.

