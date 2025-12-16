[bastion]
${bastion_public_ip}

[bastion:vars]
ansible_connection=ssh
ansible_user=${ssh_username}
ansible_ssh_private_key_file=~/.ssh/id_rsa

[webservers]
%{ for index, vm in web_servers ~}
${vm.name}.ru-central1.internal
%{ endfor ~}

[webservers:vars]
ansible_connection=ssh
ansible_user=${ssh_username}
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_username}@${bastion_public_ip}"'

[zabbix]
${zabbix_private_ip}

[zabbix:vars]
ansible_connection=ssh
ansible_user=${ssh_username}
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_username}@${bastion_public_ip}"'

[elasticsearch]
${elasticsearch_private_ip}

[elasticsearch:vars]
ansible_connection=ssh
ansible_user=${ssh_username}
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_username}@${bastion_public_ip}"'

[kibana]
${kibana_private_ip}

[kibana:vars]
ansible_connection=ssh
ansible_user=${ssh_username}
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ${ssh_username}@${bastion_public_ip}"'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
