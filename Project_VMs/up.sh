#!/bin/bash

# List of directories where vagrant reload should run
dirs=(
  "Ansible"
  "deployment_vm"
  "Docker_harbor_registy"
  "Jenkins_vm"
  "production_vm"
  "Nexus_Sonar"
)

# Loop through each directory and reload vagrant
for dir in "${dirs[@]}"; do
  echo "🔄 Reloading VM in $dir ..."
  (
    cd "$dir" && vagrant up
  )
  echo "✅ Finished reloading $dir"
  echo "--------------------------------"
done

echo "🎉 All VMs reloaded successfully!"

