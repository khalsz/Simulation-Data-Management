# STEP data management deployment scripts

## SimDB

SimDB and the STEP SimDB UI is provisioned via Ansible.

```bash
pip -m venv venv
source venv/bin/activate
pip install ansible passlib
ansible-galaxy collection install community.crypto

# Provision SimDB and UI
./run_simdb_vm.sh

# this runs the following command:
ansible-playbook -i ansible/step-inventory.yaml ansible/step-simdb-vm.yaml -e @simdb_vm_secrets.yaml
```

### Secrets

Running the ansible command requires a secrets file `simdb_vm_secrets.yaml`:

```yaml
dev_vm_password: "..."        # VM password for the dev VM
dev_db_password: "..."        # DB password for the dev VM
prod_vm_password: "..."       # VM password for the prod VM
prod_db_password: "..."       # DB password for the prod VM
simdb_git_token: "..."        # Git token for the SimDB repository
simdb_ui_gitlab_token: "..."  # GitLab token for the SimDB UI
```

### Dependencies

The provisioning scripts expect the following VM set up:
- **Users**:
  - localadmin: Provisioning user with limited sudo privileges
    - rw access to /data/sim
    - r access to /opt/simdb
    - rw access to /etc/nginx/conf.d
    - sudo privileges to run systemctl commands for nginx, postgresql and simdb services
  - sim: Service account with no sudo privileges
    - rw access to /opt/simdb
    - rw access to /common/step-simdb/[dev-]simulations
    - rw access to /common/step-simdb/db-backups
    - rw access to /data/sim
  - postgres: PostgreSQL service account
    - rw access to /data/pgsql
- **Services**:
  - PostgreSQL: PostgreSQL database service
  - Nginx: Nginx web server
- **Packages**:
  - gcc
  - openldap-devel
  - openssl-devel
  - python3-devel
  - python3.14-devel
  - nginx
  - git
  - postgresql-server
  - unzip
  - python3-psycopg2 # needed by ansible
- **Directories**:
  - /opt/simdb: SimDB installation directory - owned by sim user
  - /common/step-simdb: SimDB data mount
  - /common/step-simdb/dev-simulations or /common/step-simdb/simulations: Mounted simulations directory
  - /common/step-simdb/db-backups: Mounted database backups directory
  - /data/sim: Directory for moving data between localadmin and sim users
  - /data/pgsql/data: PostgreSQL data directory
- **SSL certificates**:
  - SSL private key and certificate installed

### Inventory

The inventory file is `ansible/step-inventory.yaml`.

This provisions the following:
- step-simdb-dev.apps.l: Development VM
- step-simdb-prod.apps.l: Production VM

### Postgres maintainer users

The SimDB Ansible role can manage Postgres maintainer users. In order to add a new user, an additional secrets file
needs to be provided when running the playbook, e.g. `simdb_maintainers_secrets.yaml`. This file needs to specify the
passwords for the read and write users, e.g.
```
postgres_maintainer_passwords:
  alahiff-read: "secretpassword"
  alahiff-write: "secretpassword2"
```
Once a user has been added it's not necessary to provide this file anymore.

The users ending in `-read` have read-only
access (e.g. cannot run `UPDATE` or `DELETE`) and the users ending in `-write` have read-write access but are not admins.

The inventory file has a maintainers section, e.g.
```
      # Maintainers
      postgres_maintainers:
      - alahiff
      - aperson
```
If an existing username is removed from this list, the associated users in Postgres are removed. If a new user is added to
`postgres_maintainers` but no passwords are supplied in the additional secrets file, Ansible will exit with an error.

To summarise:
* Users must be specified in `postgres_maintainers`.
* To add a new user, add the username to `postgres_maintainers` and specify the passwords in `postgres_maintainer_passwords`. Once a user
has been added it is not necessary to supply the password anymore.
* To remove a user, remove the username from `postgres_maintainers`.

### Roles

The provisioning roles are defined in `ansible/roles/`.

#### simdb role

This role provisions the SimDB service based on the following arguments:

```yaml
simdb_user: sim
simdb_git_repo: https://gitlab-project-token:{{ simdb_git_token }}@gitlab.ukaea.uk/step/simulation-data-management/simdb.git
simdb_git_version: 6e706e7b
simdb_pip_package: imas-simdb[server,auth-ad,postgres] @ git+{{ simdb_git_repo }}@{{ simdb_git_version }}
```

#### simdb-ui role

This role provisions the SimDB UI based on the following arguments:

```yaml
simdb_ui_artifact_url: "https://gitlab.ukaea.uk/api/v4/projects/20155/jobs/artifacts/master/download?job=build"
simdb_ui_git_version: aad816e4
```
