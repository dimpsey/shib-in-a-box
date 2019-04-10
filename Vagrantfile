$script = <<-SCRIPT
# Update system
apt-get update && apt-get upgrade -y

# Install Docker
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker vagrant

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname
-s)-$(uname -m)" -so /usr/local/bin/docker-compose
curl -L https://raw.githubusercontent.com/docker/compose/1.24.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install build tools
apt-get install -y m4 make python3-pip
pip3 install behave boto3 awscli-login
pip3 install sdg-test-behave-web --extra-index-url https://pip-test.techservices.illinois.edu/index/test

# Check out code
# git clone -b feature/local.test https://github.com/techservicesillinois/shib-in-a-box
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: $script

  config.vm.define "shib-in-a-box" do |web|
    #config.vm.box = "ubuntu/bionic64"
    config.vm.box = "debian/stretch64"

    # This is must be here for WSL users:
    # https://github.com/hashicorp/vagrant/issues/10576
    config.vm.synced_folder '.', '/vagrant', disabled: true
  end

  #config.vm.provider "virtualbox" do |v|
  #  v.name = "shib-in-a-box"
  #end
end
