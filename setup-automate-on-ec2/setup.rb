#!/usr/bin/env ruby

module Setup
  BORDER = '#' * 60

  class << self

    def display_section(title)
      puts BORDER
      puts "# #{title.center(56)} #"
      puts BORDER
    end

    def foot_note(foot_note)
      puts "# #{foot_note.center(56)} #"
    end

    def run_system_command(command)
      system(command) || handle_command_failure(command)
    end

    def check_application(application)
      unless system("#{application} --version")
        install_application(application)
      else
        puts "#{application} is installed on this system."
      end
    end

    def check_git
      check_application("git")
    end

    def check_vagrant
      check_application("vagrant")
    end

    def install_and_add_vagrant_aws_box
      unless vagrant_box_installed? && vagrant_plugin_installed?("vagrant-aws")
        install_vagrant_plugin("vagrant-aws")
        add_aws_vagrant_box
      else
        puts "The vagrant-aws plugin is installed and added."
      end
    end

    def vagrant_up
      puts "Running vagrant up..."
      run_system_command("vagrant up")
    end

    def check_directory
      check_directory_location("automate/ec2")
    end

    def check_license_file
      check_file_existence("../dev/license.jwt", "Please create a license.jwt file in the automate/dev directory.")
    end

    def check_aws_credentials
      aws_credentials_file = File.join(Dir.home, ".aws/credentials")
      check_file_existence(aws_credentials_file, "Please create aws credentials file in the ~/.aws directory.")
    end

    def check_aws_ssh_key_environment_variable
      puts "Checking for AWS_SSH_KEY_NAME environment variable..."
      puts "This key is used to create the AWS EC2 instance and must be present in the AWS console in the region you are deploying to. (Vagrantfile is configured to use us-east-2)"
      puts "If you do not have this key, please create one in the AWS console."
      puts "If you have this key, please set the AWS_SSH_KEY_NAME environment variable to the name of the key in the AWS console."
      check_or_set_environment_variables("AWS_SSH_KEY_NAME")
    end

    def check_aws_ssh_key_path_environment_variable
      puts "Checking for AWS_SSH_KEY_PATH environment variable..."
      puts "This key is used to ssh into the AWS EC2 instance and must be present on your local machine."
      puts "If you do not have this key, please create one in the AWS console."
      puts "If you have this key, please set the AWS_SSH_KEY_PATH environment variable to the path of the key on your local machine."
      check_or_set_environment_variables("AWS_SSH_KEY_PATH")
    end

    def check_github_token_environment_variable
      puts "Checking for GITHUB_TOKEN environment variable..."
      puts "This token is used to download the Chef Automate license from GitHub."
      puts "If you do not have this token, please create one in GitHub."
      puts "If you have this token, please set the GITHUB_TOKEN environment variable to the token."
      check_or_set_environment_variables("GITHUB_TOKEN")
    end

    def check_aws_ssh_profile_environment_variable
      puts "Checking for AWS_PROFILE environment variable..."
      puts "This profile is the AWS profile configured in your credentials file (~/.aws/credentials)."
      check_or_set_environment_variables("AWS_PROFILE")
    end

    private

    def check_or_set_environment_variables(env_variable)
      puts "Checking for #{env_variable} environment variable..."
      if ENV[env_variable]
        puts "Found #{env_variable} environment variable."
      else
        puts "Did not find #{env_variable} environment variable."
        prompt_environment_variable(env_variable)
      end
    end

    def handle_command_failure(command)
      puts "Error executing '#{command}'."
      exit
    end

    def install_application(application)
      if RUBY_PLATFORM.include?("darwin")
        install_application_macos(application)
        loop do
          print "Would you like to install #{application} now? (y/n) "
          answer = gets.chomp.downcase
          case answer
          when "y"
            run_system_command("brew install #{application}")
            break
          when "n"
            puts "Exiting..."
            exit
          else
            puts "Invalid input. Please enter 'y' or 'n'."
          end
        end
      else
        puts "Please install #{application} on this system."
        exit
      end
    end

    def vagrant_box_installed?
      system("vagrant box list | grep aws")
    end

    def vagrant_plugin_installed?(plugin)
      system("vagrant plugin list | grep #{plugin}")
    end

    def install_vagrant_plugin(plugin)
      puts "Installing the #{plugin} plugin..."
      run_system_command("vagrant plugin install #{plugin}")
    end

    def add_aws_vagrant_box
      puts "Adding the AWS Vagrant box..."
      run_system_command("vagrant box add aws https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box")
    end

    def prompt_environment_variable(env_variable)
      loop do
        print "Please enter the #{env_variable} environment variable: "
        env_variable_value = gets.chomp
        return env_variable_value unless env_variable_value.empty?
        puts "Value cannot be empty. Please try again."
      end
    end

    def check_directory_location(location)
      unless Dir.pwd.include?(location)
        puts "Please run this script from the #{location} directory."
        exit
      else
        puts "Running this script from the #{location} directory."
      end
    end

    def check_file_existence(file_path, error_message)
      unless File.exist?(file_path)
        puts error_message
        exit
      else
        puts "Found #{File.basename(file_path)} file in the #{File.dirname(file_path)} directory."
      end
    end
  end
end

Setup.display_section("Checking System Requirements")
Setup.check_directory
Setup.check_git
Setup.check_vagrant
Setup.install_and_add_vagrant_aws_box
Setup.foot_note("System requirements met.")

Setup.display_section("Checking Environment Variables")
Setup.check_aws_ssh_key_environment_variable
Setup.check_aws_ssh_key_path_environment_variable
Setup.check_github_token_environment_variable
Setup.check_aws_ssh_profile_environment_variable
Setup.foot_note("Environment variables set.")

Setup.display_section("Checking Files")
Setup.check_aws_credentials
Setup.check_license_file
Setup.foot_note("Files found.")

Setup.display_section("Starting Vagrant")
Setup.vagrant_up
Setup.foot_note("Vagrant started.")

puts "Setup complete."
puts "Please run 'vagrant ssh' to ssh into the AWS EC2 instance."
