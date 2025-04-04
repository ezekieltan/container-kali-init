apt update
apt full-upgrade -y
apt install -y kali-linux-core
apt install -y which wget curl file git zip nano openssl tcpdump iproute2 net-tools xz-utils python3.13-venv nmap gnupg
#apt install -y nikto peass gobuster sqlmap metasploit-framework chisel sqlmap


#INITAL SETUP
target_directory="/root/software"
mkdir -p ${target_directory}
cd ${target_directory}
backup_directory="${target_directory}/backup"
mkdir -p ${backup_directory}

mkdir -p ${target_directory}/python-sandbox
python3 -m venv ${target_directory}/python-sandbox/venv
${target_directory}/python-sandbox/venv/bin/pip install requests cryptography bcrypt

random_seed_generated=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 20)
encryption_password="C0nv0lution(*)"



#DOWNLOADING ALL THE THINGS
curl -sSL https://raw.githubusercontent.com/ezekieltan/linpeas-splitted/refs/heads/main/linpeas-splitted.sh | bash


go_version="1.24.2"
wget https://go.dev/dl/go${go_version}.linux-amd64.tar.gz -O go${go_version}.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc
source /root/.bashrc

go install mvdan.cc/garble@latest
echo "export PATH=\$PATH:/root/go/bin" >> /root/.bashrc
source /root/.bashrc 


chisel_version="1.10.1"
wget https://github.com/jpillora/chisel/archive/refs/tags/v${chisel_version}.tar.gz -O chisel-v${chisel_version}.tar.gz
tar -zxvf chisel-v${chisel_version}.tar.gz -C ${target_directory}
cd ${target_directory}/chisel-${chisel_version}
garble build -o ${target_directory}/chisel.elf
#garble build -seed="$random_seed_generated" -o ${target_directory}/chisel.elf
cd ${target_directory}
rm -rf chisel-${chisel_version}
mv chisel-v${chisel_version}.tar.gz ${backup_directory}
gpg --batch --yes --passphrase "$encryption_password" -c ${backup_directory}/chisel-v${chisel_version}.tar.g	z
rm -rf ${backup_directory}/chisel-v${chisel_version}.tar.gz

pspy_version="1.2.1"
wget https://github.com/DominicBreuker/pspy/archive/refs/tags/v${pspy_version}.tar.gz -O pspy-v${pspy_version}.tar.gz
tar -zxvf pspy-v${pspy_version}.tar.gz -C ${target_directory}
cd ${target_directory}/pspy-${pspy_version}
garble build -o ${target_directory}/pspy.elf
#garble build --seed="$random_seed_generated" -o ${target_directory}/pspy.elf
cd ${target_directory}
rm -rf pspy-${pspy_version}
mv pspy-v${pspy_version}.tar.gz ${backup_directory}
gpg --batch --yes --passphrase "$encryption_password" -c ${backup_directory}/pspy-v${pspy_version}.tar.gz
rm -rf ${backup_directory}/pspy-v${pspy_version}.tar.gz




# wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64 -P ${target_directory} -O pspy64

# chisel_version="1.10.1"
# wget https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_${chisel_version}_linux_amd64.gz -P ${target_directory} -O chisel_${chisel_version}_linux_amd64.gz
# wget https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_${chisel_version}_windows_amd64.gz -O -P ${target_directory} -O chisel_${chisel_version}_windows_amd64.gz
# gzip -d ${target_directory}/chisel_${chisel_version}_windows_amd64.gz
# gzip -d ${target_directory}/chisel_${chisel_version}_linux_amd64.gz
# mv ${target_directory}/chisel_${chisel_version}_windows_amd64 ${target_directory}/chisel.exe
# mv ${target_directory}/chisel_${chisel_version}_linux_amd64 ${target_directory}/chisel.elf









trivy_version="0.60.0"
wget https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.deb -P ${target_directory} -O trivy_${trivy_version}_Linux-64bit.deb
dpkg -i ${target_directory}/trivy_${trivy_version}_Linux-64bit.deb
mv -f ${target_directory}/trivy_${trivy_version}_Linux-64bit.deb ${backup_directory}

grype_version="0.90.0"
wget https://github.com/anchore/grype/releases/download/v0.90.0/grype_${grype_version}_linux_amd64.deb -P ${target_directory} -O grype_${grype_version}_linux_amd64.deb
dpkg -i ${target_directory}/grype_${grype_version}_linux_amd64.deb
mv -f ${target_directory}/grype_${grype_version}_linux_amd64.deb ${backup_directory}

kubebench_version="0.10.4"
wget https://github.com/aquasecurity/kube-bench/releases/download/v0.10.4/kube-bench_${kubebench_version}_linux_amd64.deb -P ${target_directory} -O kube-bench_${kubebench_version}_linux_amd64.deb
dpkg -i ${target_directory}/kube-bench_${kubebench_version}_linux_amd64.deb
mv -f ${target_directory}/kube-bench_${kubebench_version}_linux_amd64.deb ${backup_directory}

wget https://github.com/stealthcopter/deepce/raw/main/deepce.sh -P ${target_directory}
chmod +x ${target_directory}/deepce.sh

wget https://raw.githubusercontent.com/cyberark/kubernetes-rbac-audit/refs/heads/master/ExtensiveRoleCheck.py -P ${target_directory} -O ExtensiveRoleCheck.py

peirates_version="1.1.25"
wget https://github.com/inguardians/peirates/releases/download/v${peirates_version}/peirates-linux-amd64.tar.xz -P ${target_directory} -O peirates-linux-amd64.tar.xz
tar -xvf ${target_directory}/peirates-linux-amd64.tar.xz
mv -f ${target_directory}/peirates-linux-amd64.tar.xz ${backup_directory}

kubescore_version="1.19.0"
wget https://github.com/zegl/kube-score/releases/download/v${kubescore_version}/kube-score_${kubescore_version}_linux_amd64 -P ${target_directory} -O kube-score_${kubescore_version}_linux_amd64.elf

wget https://github.com/kubescape/kubescape/releases/download/v3.0.31/kubescape-ubuntu-latest.tar.gz -P ${target_directory} -O kubescape-ubuntu-latest.tar.gz
rm -rf ${target_directory}/kubescape-ubuntu-latest
mkdir -p ${target_directory}/kubescape-ubuntu-latest
tar -zxvf ${target_directory}/kubescape-ubuntu-latest.tar.gz -C ${target_directory}/kubescape-ubuntu-latest
mv -f ${target_directory}/kubescape-ubuntu-latest.tar.gz ${backup_directory}


rm -rf ${target_directory}/KubiScan
git clone https://github.com/cyberark/KubiScan.git ${target_directory}/KubiScan
python3 -m venv ${target_directory}/KubiScan/venv
${target_directory}/KubiScan/venv/bin/pip install -r ${target_directory}/KubiScan/requirements.txt
alias kubiscan='~/software/KubiScan/venv/bin/python ~/software/KubiScan/KubiScan.py'

wget https://github.com/FairwindsOps/polaris/releases/download/9.6.2/polaris_linux_amd64.tar.gz -P ${target_directory} -O polaris_linux_amd64.tar.gz
rm -rf ${target_directory}/polaris_linux_amd64
mkdir -p ${target_directory}/polaris_linux_amd64
tar -zxvf ${target_directory}/polaris_linux_amd64.tar.gz -C ${target_directory}/polaris_linux_amd64
mv -f ${target_directory}/polaris_linux_amd64.tar.gz ${backup_directory}

#apt -y install kali-desktop-xfce
#apt -y install xfce4 xfce4-goodies dbus-x11
#apt -y install xrdp
#export DISPLAY=host.docker.internal:0
### download server: https://sourceforge.net/projects/vcxsrv/
### then "startxfce4"


