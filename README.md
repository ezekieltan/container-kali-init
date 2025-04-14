# container-kali-init
A script to initalise a Kali Linux container for security testing of kubernetes environments

## Instructions
- Pull https://hub.docker.com/r/kalilinux/kali-rolling
- Then,


```
apt update
apt install -y wget dos2unix
cd root
wget https://raw.githubusercontent.com/ezekieltan/container-kali-init/refs/heads/main/container-kali-init.sh
dos2unix container-kali-init.sh
source ./container-kali-init.sh
```
