  - name: ${user_name}
    groups: ${groups}
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    ssh-authorized-keys:
      - ${ssh_public_key}
