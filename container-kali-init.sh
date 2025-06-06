
echo_colour_bold() {
  local newline=true
  if [[ $1 == "-n" ]]; then
    newline=false
    shift
  fi
  
  local colour=$1
  local text="${*:2}"


  # Define colour codes
  case "$colour" in
    black)   code=30 ;;
    red)     code=31 ;;
    green)   code=32 ;;
    yellow)  code=33 ;;
    blue)    code=34 ;;
    magenta) code=35 ;;
    cyan)    code=36 ;;
    white)   code=37 ;;
    *)       echo "Unknown colour: $colour"; return 1 ;;
  esac

  if [[ $newline == false ]]; then
    # \e[1;${code}m makes it bold and coloured
    echo -ne "\e[1;${code}m${text}\e[0m"
  else
    echo -e "\e[1;${code}m${text}\e[0m"
  fi
}

echo_header() {
  local newline=true
  if [[ $1 == "-n" ]]; then
    newline=false
    shift
  fi
  local text="${*:1}"

  if [[ $newline == false ]]; then
    echo_colour_bold -n "blue" $text
  else
    echo_colour_bold "blue" $text
  fi
}

echo_status() {
  local newline=true
  if [[ $1 == "-n" ]]; then
    newline=false
    shift
  fi
  local text="${*:1}"

  if [[ $newline == false ]]; then
    echo_colour_bold -n "green" $text
  else
    echo_colour_bold "green" $text
  fi
}

install_deb() {
  local tool_name=$1
  local extension=$2
  local target_directory=$3
  local backup_directory=$4

  # Install the package
  dpkg -i ${target_directory}/${tool_name}.${extension} > /dev/null

  # Backup the .deb file
  mv -f ${target_directory}/${tool_name}.${extension} ${backup_directory}
}

install_archive() {
  local tool_name=$1
  local extension=$2
  local target_directory=$3
  local backup_directory=$4
  local strip_archive=$5
  local encryption_password=$6
  
  # Clean up any previous extracted version
  rm -rf ${target_directory}/${tool_name}

  # Create directory and extract the downloaded file
  mkdir -p ${target_directory}/${tool_name}
 
  if [[ ${url} =~ \.tar\.(gz|xz)$ ]]; then
    if [[ -n "$strip_archive" && ("$strip_archive" == "true") ]]; then
      tar --strip-components=1 -xf ${target_directory}/${tool_name}.${extension} -C ${target_directory}/${tool_name}
    else
      tar -xf ${target_directory}/${tool_name}.${extension} -C ${target_directory}/${tool_name}
    fi
  elif [[ ${url} =~ \.zip$ ]]; then
    unzip ${target_directory}/${tool_name}.zip -d ${target_directory}/${tool_name}
  else
    echo "Unsupported file type"
    return 1
  fi

  # Move the archive file to the backup directory
  mv -f ${target_directory}/${tool_name}.${extension} ${backup_directory}

  # Encrypt backup if specified
  if [ -n "$encryption_password" ]; then
    # Encrypt backup
    gpg --batch --yes --passphrase "$encryption_password" -c ${backup_directory}/${tool_name}.${extension}
    
    # Remove the unencrypted file from backup directory
    rm -rf ${backup_directory}/${tool_name}.${extension}
  fi

  return 0
    
}

install() {
  local tool_name=$1
  local url=$2
  local target_directory=$3
  local backup_directory=$4
  local strip_archive=$5
  local encryption_password=$6

  if [[ "$url" =~ \.tar\.gz$ ]]; then
    extension="tar.gz"
  elif [[ "$url" =~ \.zip$ ]]; then
    extension="zip"
  elif [[ "$url" =~ \.tar\.xz$ ]]; then
    extension="tar.xz"
  elif [[ "$url" =~ \.deb$ ]]; then
    extension="deb"
  elif [[ "$url" =~ \.sh$ ]]; then
    extension="sh"
  else    
    echo "Unsupported file type"
    return 1
  fi
  
  # Download the archive/package/file
  echo_status -n "Downloading ${tool_name}..."
  wget -qO- ${url} -P ${target_directory} -O ${tool_name}.${extension}
  echo_status "Done"



  echo_status -n "Installing ${tool_name}..."
  if [[ ${url} =~ \.(tar\.gz|tar\.xz|zip)$ ]]; then
    install_archive $tool_name ${extension} $target_directory $backup_directory $strip_archive $encryption_password
  elif [[ ${url} =~ \.deb$ ]]; then
    install_deb ${tool_name} ${extension} $target_directory $backup_directory
  elif [[ ${url} =~ \.sh$ ]]; then
    chmod +x ${target_directory}/${tool_name}.sh
  else
    echo "Unsupported file type"
    return 1
  fi
  
  echo_status "Done"
}

# Function to download, extract, build, and encrypt a project
garble_build() {
  local tool_name=$1  # specify the tool_name for extraction and other uses
  local target_directory=$2
  local random_seed_generated=$4
  local original_directory="$(pwd)"
  # Build the project
  echo_status -n "Garbling ${tool_name}..."
  cd ${target_directory}/${tool_name}
  if [ -n "$random_seed_generated" ]; then
      garble --seed="$random_seed_generated" build -o ${target_directory}/${tool_name}.elf
  else
      garble build -o ${target_directory}/${tool_name}.elf
  fi
  cd ${original_directory}

  # Remove the unencrypted source code directory
  rm -rf ${target_directory}/${tool_name}
  
  echo_status "Done"
}
clear

echo_header "Updating package list"
apt update
clear

echo_header "Upgrading packages"
apt full-upgrade -y
clear

echo_header "Installing Kali core"
apt install -y kali-linux-core
clear

echo_header "Installing basic packages"
apt install -y which wget curl file git zip nano openssl tcpdump iproute2 net-tools xz-utils python3.13-venv nmap gnupg curl iputils-ping openssh-client
clear
#apt install -y nikto peass gobuster sqlmap metasploit-framework chisel sqlmap

echo_header -n "Basic configuration..."

#INITAL SETUP
target_directory="/root/software"
mkdir -p ${target_directory}
cd ${target_directory}
backup_directory="${target_directory}/backup"
mkdir -p ${backup_directory}

mkdir -p ${target_directory}/python-sandbox
python3 -m venv ${target_directory}/python-sandbox/venv
${target_directory}/python-sandbox/venv/bin/pip install -q requests cryptography bcrypt

random_seed_generated=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 20)
encryption_password="C0nv0lution(*)"

echo_header "Done"
echo_header -n "Downloading and installing tools..."


#DOWNLOADING ALL THE THINGS
wget -qO- https://raw.githubusercontent.com/ezekieltan/linpeas-splitted/refs/heads/main/linpeas-splitted.sh -O ${target_directory}/linpeas-splitted.sh
chmod +x ${target_directory}/linpeas-splitted.sh
${target_directory}/linpeas-splitted.sh "lp.sh" "$random_seed_generated"

go_version="1.24.2"
wget -qO- https://go.dev/dl/go${go_version}.linux-amd64.tar.gz -O  ${target_directory}/go${go_version}.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf ${target_directory}/go${go_version}.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> /root/.bashrc
source /root/.bashrc
mv  ${target_directory}/go${go_version}.linux-amd64.tar.gz ${backup_directory}

go install mvdan.cc/garble@latest
echo "export PATH=\$PATH:/root/go/bin" >> /root/.bashrc
source /root/.bashrc 



# Install and backup Trivy
trivy_version="0.60.0"
trivy_url="https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.deb"
install "trivy" $trivy_url $target_directory $backup_directory

# Install and backup Grype
grype_version="0.90.0"
grype_url="https://github.com/anchore/grype/releases/download/v${grype_version}/grype_${grype_version}_linux_amd64.deb"
install "grype" $grype_url $target_directory $backup_directory

# Install and backup kubebench
kubebench_version="0.10.4"
kubebench_url="https://github.com/aquasecurity/kube-bench/releases/download/v${kubebench_version}/kube-bench_${kubebench_version}_linux_amd64.deb"
install "kubebench" $kubebench_url $target_directory $backup_directory

# Install and backup kubescape
kubescape_version="3.0.31"
kubescape_url="https://github.com/kubescape/kubescape/releases/download/v${kubescape_version}/kubescape-ubuntu-latest.tar.gz"
install "kubescape" $kubescape_url $target_directory $backup_directory
${target_directory}/kubescape-ubuntu-latest download artifacts

# Install and backup polaris
polaris_version="9.6.2"
polaris_url="https://github.com/FairwindsOps/polaris/releases/download/${polaris_version}/polaris_linux_amd64.tar.gz"
install "polaris" $polaris_url $target_directory $backup_directory

# Install and backup peirates
peirates_version="1.1.25"
peirates_url="https://github.com/inguardians/peirates/releases/download/v${peirates_version}/peirates-linux-amd64.tar.xz"
install "peirates" $peirates_url $target_directory $backup_directory

# Install and backup Kubiscan
kubiscan_version="1.6"
kubiscan_url="https://github.com/cyberark/KubiScan/archive/refs/tags/v${kubiscan_version}.tar.gz"
install "KubiScan" $kubiscan_url $target_directory $backup_directory true
python3 -m venv ${target_directory}/KubiScan/venv
${target_directory}/KubiScan/venv/bin/pip install -q -r ${target_directory}/KubiScan/requirements.txt
alias kubiscan='~/software/KubiScan/venv/bin/python ~/software/KubiScan/KubiScan.py'

# Install and backup+encrypt chisel
chisel_version="1.10.1"
chisel_url="https://github.com/jpillora/chisel/archive/refs/tags/v${chisel_version}.tar.gz"
install "chisel" $chisel_url $target_directory $backup_directory true $encryption_password
garble_build "chisel" $target_directory $random_seed_generated

# Install and backup+encrypt pspy
pspy_version="1.2.1"
pspy_url="https://github.com/DominicBreuker/pspy/archive/refs/tags/v${pspy_version}.tar.gz"
install "pspy" $pspy_url $target_directory $backup_directory true $encryption_password
garble_build "pspy" $target_directory $random_seed_generated

cdk_version="1.5.5"
cdk_url="https://github.com/cdk-team/CDK/archive/refs/tags/v${cdk_version}.tar.gz"
install "cdk" $cdk_url $target_directory $backup_directory true
mv ${target_directory}/cdk/cmd/cdk/cdk.go ${target_directory}/cdk/cdk.go
garble_build "cdk" $target_directory $random_seed_generated

# Install deepce
deepce_url="https://github.com/stealthcopter/deepce/raw/main/deepce.sh"
install "deepce" $deepce_url $target_directory $backup_directory

# Get ExtensiveRoleCheck
wget -q https://raw.githubusercontent.com/cyberark/kubernetes-rbac-audit/refs/heads/master/ExtensiveRoleCheck.py -P ${target_directory} -O ExtensiveRoleCheck.py

# Get kubescore
kubescore_version="1.19.0"
wget -q https://github.com/zegl/kube-score/releases/download/v${kubescore_version}/kube-score_${kubescore_version}_linux_amd64 -P ${target_directory} -O kube-score_${kubescore_version}_linux_amd64.elf





# wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64 -P ${target_directory} -O pspy64

# chisel_version="1.10.1"
# wget https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_${chisel_version}_linux_amd64.gz -P ${target_directory} -O chisel_${chisel_version}_linux_amd64.gz
# wget https://github.com/jpillora/chisel/releases/download/v1.10.1/chisel_${chisel_version}_windows_amd64.gz -O -P ${target_directory} -O chisel_${chisel_version}_windows_amd64.gz
# gzip -d ${target_directory}/chisel_${chisel_version}_windows_amd64.gz
# gzip -d ${target_directory}/chisel_${chisel_version}_linux_amd64.gz
# mv ${target_directory}/chisel_${chisel_version}_windows_amd64 ${target_directory}/chisel.exe
# mv ${target_directory}/chisel_${chisel_version}_linux_amd64 ${target_directory}/chisel.elf




#apt -y install kali-desktop-xfce
#apt -y install xfce4 xfce4-goodies dbus-x11
#apt -y install xrdp
#export DISPLAY=host.docker.internal:0
### download server: https://sourceforge.net/projects/vcxsrv/
### then "startxfce4"


