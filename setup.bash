#!/bin/bash

# Install necessary packages
apt update && apt install -y openssh-server fail2ban ufw

# Enable and start SSH service
systemctl enable --now ssh

# Configure SSH for security
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#AllowTcpForwarding.*/AllowTcpForwarding no/' /etc/ssh/sshd_config
sed -i 's/^#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/^#ClientAliveCountMax.*/ClientAliveCountMax 3/' /etc/ssh/sshd_config
systemctl restart ssh

# Configure firewall
ufw allow OpenSSH
ufw --force enable

# Create a secure SFTP user
USERNAME=sftpuser
PASSWORD=$(openssl rand -base64 12)
useradd -m -s /usr/sbin/nologin $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
mkdir -p /home/$USERNAME/sftp_upload
chown root:root /home/$USERNAME
chmod 755 /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME/sftp_upload

# Configure SFTP access
cat >> /etc/ssh/sshd_config <<EOL
Match User $USERNAME
    ChrootDirectory /home/$USERNAME
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
EOL
systemctl restart ssh

# Output login credentials
echo "====================================="
echo "SSH/SFTP Setup Complete"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "====================================="

echo "                           *+==++++=================+=++++++++=========---------===-=====++="
echo "                          =+----------------------------------------------------------=++"
echo "                          ++--------------------------------------------------------=+="
echo "                      -+++=-------------------------------=-----------------------++=            Done! Now you can use SFTP and SSH Remotly!"
echo "                    =++- ---------------+**-------------++++--------------------++=             Also I installed on your server some security packages."
echo "                ==+=-- - -------------=#+-++---------=++=-=*------------------++="
echo "             =++------ --------------=+=------------+=-----=---------------=++=                 There's SFTP and SSH info:"
echo "              -=+=-----------------------------------------------------=--++=                   Username: $USERNAME"
echo "                -=+=---------------------------------------------------++++=                    Password: $PASSWORD"
echo "                 --=+=--------------------------------------------------==++="
echo "                     =+=--------------------------------------------------==+++="
echo "                     =+=-----------------------------------------------------=**+="
echo "                   ++=--------------------------------------------------------=++*+="
echo "                =++=-------------------------------------------------------------=+**="
echo "            =+=------------------------------------------------------------------==+*+="
echo "            ++=====================================================================+**=="