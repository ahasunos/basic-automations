#!/usr/bin/env ruby

module Setup
  def self.check_os
    unless RUBY_PLATFORM.include?("darwin")
      puts "This script is only compatible with macOS."
      exit
    end
  end

  def self.check_application(application)
    unless system("#{application} --version")
      puts "#{application} is not installed on this system."

      # Prompt the user to install Git or exit
      print "Would you like to install #{application} now? (y/n) "
      answer = gets.chomp
      if answer == "y"
        system("brew install #{application}")
      else
        puts "Exiting..."
        exit
      end
    end
    puts "#{application} is installed on this system."
  end
  
  def self.check_git
    check_application("git")
  end
  
  def self.check_vagrant
    check_application("vagrant")
  end
  
  def self.check_aws_cli
    check_application("aws")
  end
  
  def self.check_saml2aws
    unless system("saml2aws --version")
      puts "saml2aws is not installed on this system."
  
      # Prompt the user to install saml2aws or exit
      print "Would you like to install saml2aws now? (y/n) "
      answer = gets.chomp
      if answer == "y"
        system("brew install saml2aws")
      else
        puts "Exiting..."
        exit
      end
    end
    puts "saml2aws is installed on this system."
  end

  def self.install_and_add_vagrant_aws_box
    unless system("vagrant box list | grep aws")
      puts "Installing the vagrant-aws plugin..."
      system("vagrant plugin install vagrant-aws")
      puts "Adding the AWS Vagrant box..."
      system("vagrant box add aws https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box")
    end

    puts "The vagrant-aws plugin is installed and added."
  end

  def self.configure_saml2aws
    puts "Configuring saml2aws..."
    puts "Please enter your Username: (username@company.com)"
    username = gets.chomp
    system("saml2aws configure --idp-provider='AzureAD' --mfa='Auto' --url='https://account.activedirectory.windowsazure.com' --username='#{username}' --app-id='60978246-ce55-4e43-bdd1-f08b130d52bd' --skip-prompt")
    
      puts "Please enter the profile name you would like to use: (default)"
      profile_name = gets.chomp
      system("saml2aws login --profile #{profile_name}")

      puts "Successfully configured saml2aws."
  end

  def self.check_or_set_environment_variables
    env_helper("AWS_SSH_KEY_NAME")
    env_helper("AWS_SSH_KEY_PATH")
    env_helper("GITHUB_TOKEN")
  end

  def self.env_helper(env_variable)
    unless ENV[env_variable]
      puts "Please enter the #{env_variable} environment variable:"
      env_variable_value = gets.chomp
      system("export #{env_variable}=#{env_variable_value}")
    end
  end

  def self.vagrant_up_and_ssh
    puts "Running vagrant up and ssh..."
    unless system("pwd | grep automate/ec2")
      puts "Please run this script from the automate/ec2 directory."
      exit
    else
      system("vagrant up")
      system("vagrant ssh")
    end
  end
end

Setup.check_os
Setup.check_git
Setup.check_vagrant
Setup.check_aws_cli
Setup.check_saml2aws
Setup.install_and_add_vagrant_aws_box
Setup.configure_saml2aws
Setup.check_or_set_environment_variables
Setup.vagrant_up_and_ssh
