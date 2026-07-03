# SimDB maintenance documentation

## Deployment

The SimDB deployment requires the configuring the following services:
- Nginx: used to proxy-forward requests to the SimDB Gunicorn service
- SimDB Gunicorn service: systemd service which runs the Gunicorn workers with the simdb WSGI app
- Postgresql: database service used to store the metadata catalogue
- Database backup: cronjob which dumps the database to an off-VM location

## Files

The following files can be found in this directory:
- ansible:
  - deploy.yaml: Ansible script for deploying SimDB
  - inventory.yaml: Ansible inventory
- app-*.cfg: SimDB configuration files for develop and prod deployments
- nginx_simdb.conf: Nginx configuration script
- simdb.socket & simdb-*.service: Systemd configuration scripts for running simdb service
- validation*.yaml: SimDB validation rulesets.

## VM configuration

The deployment scripts require a VM with the following configuration
- localadmin user with sudo privileges:
  - `systemctl [start|stop|status|enable] nginx`
  - `systemctl [start|stop|status|enable] simdb`
  - Write access to `/etc/nginx/conf.d`
  - Write access to `/etc/systemd/system`
  - Packages installed:
    - gcc
    - openldap-devel
    - openssl-devel
    - python3-devel
    - python3.14-devel
    - sqlite
  - Data storage mounted

## Ansible playbook

```bash
ansible-playbook ansible/deploy.yaml --extra-vars "ansible_password=<localadmin password> ansible_become_password=<localadmin password> target=[develop|prod]"
```
