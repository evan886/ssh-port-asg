#!/bin/bash
set -eux

#add via TF not successful, so add here
# Change SSH port from 22 to 60022
cat > /etc/ssh/sshd_config.d/50-ssh-port.conf <<'EOT'
Port 60022
EOT


SFTP_USER="sftpuser"

# Create SFTP user
useradd -m -s /sbin/nologin "$SFTP_USER"

# Create SSH directory
mkdir -p "/home/$SFTP_USER/.ssh"

# Add SSH public key
cat > "/home/$SFTP_USER/.ssh/authorized_keys" <<'KEY'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZz66AbpF5PaYwS85wVSTLuRIrP+wZPQHHbKQxqtFWN evan@myxps
KEY

# Set permissions
chown -R "$SFTP_USER:$SFTP_USER" "/home/$SFTP_USER/.ssh"
chmod 700 "/home/$SFTP_USER/.ssh"
chmod 600 "/home/$SFTP_USER/.ssh/authorized_keys"

# Create upload directory
mkdir -p "/home/$SFTP_USER/upload"
chown "$SFTP_USER:$SFTP_USER" "/home/$SFTP_USER/upload"

# SFTP-only SSH configuration
cat > /etc/ssh/sshd_config.d/60-sftp-user.conf <<EOT
Match User $SFTP_USER
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    ForceCommand internal-sftp
    PermitTTY no
    AllowTcpForwarding no
    X11Forwarding no
EOT

sshd -t
systemctl restart sshd