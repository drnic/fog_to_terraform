fog to terraform
================

Creates a `terraform.tf` input variable file for terraform plans using credentials from a fog-formatted YAML file.

Given the following example fog file (defaults to `~/.fog`\):

```yaml
---
:student1:
  :aws_access_key_id: ACCESS
  :aws_secret_access_key: SECRET
```

A `terraform.tf` file will be created in the current folder with the following command:

```
fog_to_terraform -C path/to/fog.yml student1
```

The output `/path/to/terraform.tf` will look like:

```hcl
aws_access_key = "ACCESS"
aws_secret_key = "SECRET"
aws_key_path = "/path/to/ssh/student1.pem"
aws_key_name = "student1"
aws_region = "us-west-2"
network = "10.10"
```

The keypair `student1` will be created for you in the AWS region (defaults to us-west-2) and the `ssh/student1.pem` is located in the current/target folder.

Requires
--------

-	Ruby 1.9+
-	RubyGems

Installation
------------

Install using RubyGems:

```
$ gem install fog_to_terraform
```

Usage
-----

TODO: Write usage instructions here

Contributing
------------

1.	Fork it ( https://github.com/[my-github-username]/fog_to_terraform/fork )
2.	Create your feature branch (`git checkout -b my-new-feature`\)
3.	Commit your changes (`git commit -am 'Add some feature'`\)
4.	Push to the branch (`git push origin my-new-feature`\)
5.	Create a new Pull Request
