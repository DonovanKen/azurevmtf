[master]
${master_name} ansible_host=${ips[master_name]} ansible_user=${admin_username}

[workers]
%{ for w in ips ~}
%{ if w != master_name && w != ansible_name ~}
${w} ansible_host=${ips[w]} ansible_user=${admin_username}
%{ endif ~}
%{ endfor ~}

[ansible]
${ansible_name} ansible_host=${ips[ansible_name]} ansible_user=${admin_username}

[kubernetes:children]
master
workers
