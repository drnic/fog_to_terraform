require "optparse"
require "yaml"
require "cyoi/cli/key_pair"

class FogToTerraform::App

  def self.start(args)
    # for cyoi
    extend Cyoi::Cli::Helpers::Settings
    @settings_dir = File.expand_path(".")

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

    all_credentials = YAML.load_file(File.expand_path(credentials_file))
    unless credentials_key = remaining_args.shift
      if all_credentials.keys.size == 1
        credentials_key = all_credentials.keys.first
      else
        $stderr.puts "#{credentials_file} contains more than one key; pass it as an argument\n\n"
        puts opts
        exit 1
      end
    end

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


    settings.set "provider.name", "aws"
    settings.set "provider.credentials.aws_access_key_id", aws_access_key_id
    settings.set "provider.credentials.aws_secret_access_key", aws_secret_access_key
    settings.set "provider.region", aws_region
    save_settings!
    reload_settings!

    keypair = Cyoi::Cli::KeyPair.new([aws_key_name, settings_dir])
    keypair.execute!

    mkdir_p(File.dirname(aws_key_path))
    chmod(0700, File.dirname(aws_key_path))

    private_key = settings.key_pair.private_key
    File.open(aws_key_path, "w") { |file| file << private_key }
    chmod(0600, aws_key_path)
    puts "created #{aws_key_path}"
  end
end
