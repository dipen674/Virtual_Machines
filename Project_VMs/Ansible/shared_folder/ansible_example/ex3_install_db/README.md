# 🚀 Ansible Playbook: Setup Web & Database Servers

This playbook sets up:

1. **Apache Web Server** on an Ubuntu VM  
2. **MariaDB Database Server** on a CentOS VM


- **Hosts:** `webser` group
- **Tasks:**
  - Install `apache2` package (using `apt` module)
  - Enable and start Apache service
  - Copy custom `index.html` to `/var/www/html/`


- **Hosts:** `dbser` group
- **Tasks:**
  - Install `mariadb-server` package (using `yum` module)
  - Enable and start MariaDB service

## 🔧 **Modules Used**

- `apt` – Install packages on Debian-based systems
- `yum` – Install packages on RedHat-based systems
- `service` – Manage services (start/enable)
- `copy` – Copy files from control node to target hosts

