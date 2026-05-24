# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # =============================================
  # Configuration commune à toutes les machines
  # =============================================
  config.vm.box = "debian/bookworm64"

  # Désactive la mise à jour automatique des Guest Additions (important !)
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  # Provisioning SSH commun (adapté pour Debian 12)
  config.vm.provision "shell", inline: <<-SHELL
    echo "=== Configuration SSH ==="
    sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
    systemctl restart ssh
    echo "SSH configuré avec ChallengeResponseAuthentication = yes"
  SHELL

  # =============================================
  # 1. p1jenkins-pipeline (Jenkins principal)
  # =============================================
  config.vm.define "p1jenkins-pipeline" do |p1jenkins|
    p1jenkins.vm.hostname = "p1jenkins-pipeline"
    p1jenkins.vm.network :private_network, ip: "192.168.56.10"   # IP conservée comme demandé

    p1jenkins.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 4096]     # 4 Go recommandé pour Jenkins + Docker
      v.customize ["modifyvm", :id, "--name", "p1jenkins-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end

    p1jenkins.vm.provision "shell", path: "install_p1jenkins.sh"
  end

  # =============================================
  # 2. srvdev-pipeline
  # =============================================
  config.vm.define "srvdev-pipeline" do |srvdev|
    srvdev.vm.hostname = "srvdev-pipeline"
    srvdev.vm.network :private_network, ip: "192.168.5.3"

    srvdev.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "srvdev-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end

  # =============================================
  # 3. srvstage-pipeline
  # =============================================
  config.vm.define "srvstage-pipeline" do |srvstage|
    srvstage.vm.hostname = "srvstage-pipeline"
    srvstage.vm.network :private_network, ip: "192.168.5.7"

    srvstage.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "srvstage-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end

  # =============================================
  # 4. srvprod-pipeline
  # =============================================
  config.vm.define "srvprod-pipeline" do |srvprod|
    srvprod.vm.hostname = "srvprod-pipeline"
    srvprod.vm.network :private_network, ip: "192.168.5.4"

    srvprod.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "srvprod-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end

  # =============================================
  # 5. srvbdd-pipeline (PostgreSQL)
  # =============================================
  config.vm.define "srvbdd-pipeline" do |srvbdd|
    srvbdd.vm.hostname = "srvbdd-pipeline"
    srvbdd.vm.network :private_network, ip: "192.168.5.6"

    srvbdd.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "srvbdd-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end

    srvbdd.vm.provision "shell", path: "install_srvpostgres.sh"
  end

  # =============================================
  # 6. registry-pipeline (Docker Registry)
  # =============================================
  config.vm.define "registry-pipeline" do |registry|
    registry.vm.hostname = "registry-pipeline"
    registry.vm.network :private_network, ip: "192.168.5.5"

    registry.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 1024]
      v.customize ["modifyvm", :id, "--name", "registry-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end

    registry.vm.provision "shell", path: "install_registry.sh"
  end

  # =============================================
  # 7. gitlab-pipeline
  # =============================================
  config.vm.define "gitlab-pipeline" do |gitlab|
    gitlab.vm.hostname = "gitlab-pipeline"
    gitlab.vm.network :private_network, ip: "192.168.5.10"

    gitlab.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ["modifyvm", :id, "--name", "gitlab-pipeline"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end

    gitlab.vm.provision "shell", path: "install_gitlab.sh"
  end

end
