#!/bin/bash

# List of directories where vagrant halt should run
dirs=(
  "Ansible"
  "deployment_vm"
  "Docker_harbor_registy"
  "Jenkins_vm"
  "production_vm"
  "Nexus_Sonar"
)

# Loop through each directory and halt vagrant
for dir in "${dirs[@]}"; do
  echo "⏹️ Halting VM in $dir ..."
  (
    cd "$dir" && vagrant halt
  )
  echo "✅ Finished halting $dir"
  echo "--------------------------------"
done

echo "🎉 All VMs halted successfully!"

