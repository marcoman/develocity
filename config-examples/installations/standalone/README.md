# Example Develocity configuration files.

In this directory, we have several `yaml` files that you may use as a starting point to configure your Develocity server.

These files were tested against a K3S installation on AWS in the us-east-1 region.  Your mileage may vary, but the files are generally correct because they worked.  These files were tested on an Ubuntu 22 host connected into EC2 instances. The version of Linux probalby should not matter, but the information is presented just in case.

The files with the names `-partN` become more complex as we enable more features.

- `part1` is the simplest, and you may consider it to be a barebones installation.
- `part2` includes the specification of a password.  In case you want help, here is what I did:

See the [document](https://docs.gradle.com/enterprise/admin-cli/) for background information.

I ran this command:
`java -jar gradle-enterprise-admin-1.8.1.jar  config-file hash -o secret.txt -s password.secret`

I created a local file with a password, and submitted it to the command above.  The file named `password.secret` is a local file that contained my password.  I recommend you do not check this file into your repository.

- `part3` includes a specification of a S3 bucket.
- The unadorned file is largely identical to the most complex file in our list.

