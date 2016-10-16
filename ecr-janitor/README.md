
### ECR Janitor

A simple lambda to remove any untagged images in any EC2 Container Registries once a day.

The script only operates in the region where it is installed. Edit lib.sh and reinstall if you need a different region.

# WARNING :: This script will delete images from ECR without asking for confirmation!

To install, run the install.sh script. This will create a CloudWatch cron rule to trigger at 4am daily and trigger the main lambda. Role and trust policies are included in the respective .json files and are configured to allow the minimum necessary permissions.

To uninstall, run the uninstall.sh script.

