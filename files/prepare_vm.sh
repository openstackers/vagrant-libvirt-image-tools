useradd vagrant -u 5000 -m -d /home/vagrant

echo "Defaults !requiretty
vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-vagrant
chmod 0440 /etc/sudoers.d/90-vagrant
sed -i -r 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

mkdir -p /root/.ssh
cat /root/vagrant_pub_key >> /root/.ssh/authorized_keys
chown -R root: /root
chmod 0700 /root/.ssh
chmod 0600 /root/.ssh/authorized_keys

mkdir -p /home/vagrant/.ssh
cat /root/vagrant_pub_key >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant: /home/vagrant
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
