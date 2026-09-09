#!/bin/bash

ansible-playbook -i ansible/step-inventory.yaml ansible/step-simdb-vm.yaml -e @simdb_vm_secrets.yaml
