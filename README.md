# rupert-infra
Responsible for deploying Ruperts infrastructure

## Ansible Info

### Vault

You will need to generated an encrypted ansible vault and store the value of ansible_become_pass.

```bash
# Create vault and add values for ansible_become_pass, tinytuya_api_key, and tinytuya_api_secret
ansible-vault create inventories/<env>/group_vars/all/vault.yaml
```

```bash
# Store the value for ansible_become_pass
ansible-vault edit inventories/<env>/group_vars/all/vault.yaml
```

```bash
# Decrypt and view the vault in plain text
ansible-vault view inventories/<env>/group_vars/all/vault.yaml
```

### Version updates

Many software and library versions can be updated by editing the values in playbooks/group_vars/all.yaml

### Basic ansible usage commands to deploy

```bash
# Check for what updates may occur
ansible-playbook -i inventories/<env> playbooks/<playbook>.yaml --check 
```

```bash
# Install a playbook
ansible-playbook -i inventories/<env> playbooks/<playbook>.yaml
```

```bash
# Uninstall a playbook
ansible-playbook -i inventories/<env> playbooks/<playbook>.yaml -e deploy=absent
```

```bash
# Install everything
ansible-playbook -i inventories/<env> playbooks/install.yaml
```

```bash
# Uninstall everything
ansible-playbook -i inventories/<env> playbooks/uninstall.yaml
```

## Rupert Infrastructure Dependencies

These Ansible playbooks are meant to be used against Raspberry PI 4 hardware running Ubuntu 24.04.

### System Packages

 - Python 3.12
 - Python3.12 Venv
 - Open JDK 2.1 JRE Headless
 - VLC Media Player

### Other Software

 - Kafka 2.13-4.20
 - Unit

### Python Modules

  - [beartype ~= 0.22.0](https://pypi.org/project/beartype/)
  - [confluent_kafka ~= 2.14.0](https://pypi.org/project/confluent-kafka/)
  - [flask ~= 3.1.0](https://pypi.org/project/Flask/)
  - [python-vlc ~= 3.0.0](https://pypi.org/project/python-vlc/)
  - [tinytuya ~= 1.17.0](https://pypi.org/project/tinytuya/)
	- [loguru ~= 0.7.0](https://github.com/Delgan/loguru)

## Gists

These are just some additional information saved in an easy place to access and update.  Anything from how something works to commands I found useful.

- [Ansible](https://gist.github.com/biggiebk/82a6a10b1ea1b4f39f0c248f4417685a)
- [Kafka](https://gist.github.com/biggiebk/ee08bec483732e4a19d7c067e0a1c708)
- [Unit](https://gist.github.com/biggiebk/a50952a5ad2fe537ef6fb4834f707ffe)
