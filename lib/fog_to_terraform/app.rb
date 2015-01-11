require "optparse"
require "yaml"

class FogToTerraform::App

  def self.start(args)
    credentials_file = "~/.fog"
    aws_region = "us-west-2"

    opts = OptionParser.new do |opts|
      opts.banner = "fog_to_terraform {options} credentials-key"
      opts.separator ""
      opts.separator "Options are ..."

      opts.on_tail("-h", "--help", "-H", "Display this help message.") do
        puts opts
        exit 1
      end

      opts.on '--credentials-path="FILE"', '-C',
        'Path to the credentials file',
        lambda { |value| credentials_file = value }
    end
    remaining_args = opts.parse(args)
    credentials_key = args.shift || "default"

    all_credentials = YAML.load_file(File.expand_path(credentials_file))
    credentials = all_credentials[credentials_key.to_sym] || all_credentials[credentials_key.to_s]
    unless credentials
      $stderr.puts "Cannot find '#{credentials_key}' key in #{credentials_file}\n\n"
      puts opts
      exit 1
    end

    # Only AWS supported currently
    aws_access_key_id = credentials[:aws_access_key_id]
    aws_secret_access_key = credentials[:aws_secret_access_key]
    unless aws_access_key_id && aws_secret_access_key
      $stderr.puts "AWS credentials require :aws_access_key_id and :aws_secret_access_key keys"
      exit 1
    end

    aws_key_path = "ssh/#{credentials_key.to_s}.pem"
    aws_key_name = credentials_key.to_s

    File.open("terraform.tf", "w") do |f|
      f << <<-EOS
aws_access_key = "#{aws_access_key_id}"
aws_secret_key = "#{aws_secret_access_key}"
aws_key_path = "#{aws_key_path}"
aws_key_name = "#{aws_key_name}"
aws_region = "#{aws_region}"
network = "10.10"
      EOS
    end
    puts "created terraform.tf"
  end
end
