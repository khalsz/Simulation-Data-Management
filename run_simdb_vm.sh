#!/bin/bash

ansible-playbook -i ansible/inventory.yaml ansible/step-simdb-vm.yaml -e @simdb_vm_secrets.yaml
