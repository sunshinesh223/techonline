#!/bin/bash
set -x  # Enable bash debug
exec &> /var/log/boot.log
yum update -y
yum install -y docker git expect
systemctl enable docker
#systemctl enable named
systemctl start docker
cd /root
# Fetch the IP address
while true; do
  IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)
  if [ $? -ne 0 ]; then
    echo "Command failed, retrying..."
    sleep 10  # Add a delay if desired
  else
    break
  fi
done

#get the country information
land=$(curl ipinfo.io | grep country |cut -d '"' -f 4)

# Clone the repository
git clone https://github.com/kylemanna/docker-openvpn.git
# Change current directory to the cloned repository
cd docker-openvpn

# Build the Docker image
docker build -t myownvpn .
# Change back to the previous directory and create a volume for storing config files and keys
cd ..
mkdir vpn-data-443 && touch vpn-data-443/vars

# Generate the OpenVPN config file
docker run -v $PWD/vpn-data-443:/etc/openvpn --rm myownvpn ovpn_genconfig -u udp://${IP_ADDRESS}:443
PASSPHRASE=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 8; echo;)
# Initialize PKI, generate the CA certificate
/usr/bin/expect <<EOF
set timeout 600

spawn docker run -v $PWD/vpn-data-443:/etc/openvpn --rm -it myownvpn ovpn_initpki
expect "Enter New CA Key Passphrase:" { send "$PASSPHRASE\r" }
expect "Confirm New CA Key Passphrase:" { send "$PASSPHRASE\r" }
expect "Common Name (eg: your user, host, or server name)" { send "$IPADDRESS\r" }
expect "Confirm request details" { send "yes\r" }
expect -re "Enter pass phrase for /etc/openvpn/pki/private/ca.key:" { send "$PASSPHRASE\r" }
expect -re "Enter pass phrase for /etc/openvpn/pki/private/ca.key:" { send "$PASSPHRASE\r" }
expect "CRL file: /etc/openvpn/pki/crl.pem" { send "\r" }
EOF




# Run the VPN server
docker run -v $PWD/vpn-data-443:/etc/openvpn -d -p 443:1194/udp --cap-add=NET_ADMIN myownvpn

# Create a user for the VPN connection
for i in xp zt xw ruimin; do
  /usr/bin/expect <<EOF
  set timeout 600

  spawn docker run -v $PWD/vpn-data-443:/etc/openvpn --rm -it myownvpn easyrsa build-client-full $i nopass
  expect "Confirm request details" { send "yes\r" }
  expect -re "Enter pass phrase for /etc/openvpn/pki/private/ca.key:" { send "$PASSPHRASE\r" }
  expect "Signature ok" { send "\r" }
EOF
done


# Generate a configuration file for the user
for i in xp zt xw ruimin; do
docker run -v $PWD/vpn-data-443:/etc/openvpn --rm myownvpn ovpn_getclient $i > $i.ovpn
sed -i 's/redirect-gateway def1/route 192.168.0.0\/24 255.255.0.0/g' $i.ovpn
echo "redirect-gateway def1" >> $i.ovpn
mv $i.ovpn /home/ec2-user/$i-$land.ovpn
chown ec2-user /home/ec2-user/$i-$land.ovpn
done

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Update iptables
iptables -I FORWARD -j ACCEPT
iptables -t nat -I POSTROUTING -s 192.168.255.0/24 -o eth0 -j MASQUERADE

# Setup bind service
#cat <<EOF> /etc/named.conf
#acl "allowed" { ${IP_ADDRESS}/32; };
#options {
#    forwarders {
#        8.8.8.8;   // Specify your upstream DNS server IP address here
#        8.8.4.4;
#    };
#    forward only;
#    allow-query { "allowed"; };
#};
#EOF
#systemctl start named