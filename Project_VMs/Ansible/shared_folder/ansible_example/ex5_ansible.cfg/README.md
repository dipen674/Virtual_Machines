# ⚡ Example 5 – Ansible Practice with `ansible.cfg`

This example builds upon **Example 4**, focusing on practising and understanding **Ansible configuration file (`ansible.cfg`) settings** for real-world automation efficiency.


## 🔧 Key Highlights – `ansible.cfg`

- **host_key_checking**: Disabled (`False`)
  - Prevents SSH host key verification prompts, useful in labs or testing.
  
- **inventory**: Set to `./inventory`
  - Defines default inventory file path, avoiding repeated `-i` flag usage.

- **forks**: Configured to `5`
  - Allows up to 5 parallel task executions for faster runs in multi-host environments.

- **log_path**: Set to `ansible.log`
  - Saves logs of playbook runs for review, debugging, and documentation.

- **Privilege escalation settings**:
  - `become`: Enabled (`True`) to run tasks with elevated privileges.
  - `become_method`: Uses `sudo` for privilege escalation.
  - `become_ask_pass`: Disabled (`False`) to avoid password prompts during privilege escalation in this setup.

