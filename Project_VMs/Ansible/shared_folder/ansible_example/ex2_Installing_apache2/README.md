
Install Apache Web Server Using ansible playbook.

This playbook installs the **Apache web server** on a VM and updates the `index.html` file with custom content.


- **Purpose:**  
  - Install Apache web server  
  - Ensure the Apache service is running  
  - Deploy a custom `index.html` file to the web server root

⚙️ **Modules Used**

- `apt` – for installing Apache packages
- `service` – to enable and start the Apache service
- `copy` – to copy the `index.html` file to the server


