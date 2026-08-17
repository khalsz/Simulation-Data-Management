# STEP data management deployment scripts

## SimDB

SimDB is configured via Ansible.

Details can be found in the [SimDB](simdb) directory.


```bash
pip -m venv venv
source venv/bin/activate
pip install ansible passlib
ansible-galaxy collection install community.crypto

# Provision the VM
ansible-playbook -i inventory.yml ansible/step-dev-vm.yaml

# Install SimDB and UI
ansible-playbook -i inventory.yml ansible/step-dev-simdb.yaml
```
