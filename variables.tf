locals {
  assistant_port                   = 23010
  distro_ami                       = var.distribution == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.rhel.id
  default_ssh_user                 = var.distribution == "ubuntu" ? "ubuntu" : "ec2-user"
  rendered_secondary_instance_type = var.secondary_instance_type != "" ? var.secondary_instance_type : var.primary_instance_type
}

### =================================================================== REQUIRED

variable "domain" {
  type        = string
  description = "Route53 Domain to manage DNS under"
}

variable "private_zone" {
  type        = "string"
  description = "set to true if your route53 zone is private"
  default     = false
}

variable "license_file" {
  type        = string
  description = "path to license file"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC id to install into"
}

### =================================================================== OPTIONAL

variable "prefix" {
  type        = string
  description = "Name prefix for resource names and tags"
  default     = "tfe"
}

variable "airgap_installer_url" {
  type        = string
  description = "URL to airgap installer package"
  default     = "https://s3.amazonaws.com/replicated-airgap-work/replicated__docker__kubernetes.tar.gz"
}

variable "airgap_package_url" {
  type        = string
  description = "signed URL to download the package"
  default     = ""
}

variable "ca_bundle_url" {
  type        = string
  description = "URL to Custom CA bundle used for outgoing connections"
  default     = "none"
}

variable "ami" {
  type        = string
  description = "AMI to launch instance with; defaults to latest Ubuntu Xenial"
  default     = ""
}

variable "cert_arn" {
  type        = string
  description = "Amazon Resource Name (ARN) for Certificate in the ACM you'd like to use (default uses domain or cert_domain to look it up)"
  default     = ""
}

variable "cert_domain" {
  type        = string
  description = "domain to search for ACM certificate with (default is *.domain)"
  default     = ""
}

variable "distribution" {
  type        = string
  description = "Type of linux distribution to use. (ubuntu or rhel)"
  default     = "ubuntu"
}

variable "encryption_password" {
  type        = string
  description = "encryption password to use as root secret (default is autogenerated)"
  default     = ""
}

variable "hostname" {
  type        = string
  description = "hostname to assign to cluster under domain (default is autogenerated one)"
  default     = ""
}

variable "iact_subnet_list" {
  type        = string
  description = "List of subnets to allow to access Initial Admin Creation Token (IACT) API. https://www.terraform.io/docs/enterprise/private/automating-initial-user.html"
  default     = ""
}

variable "iact_subnet_time_limit" {
  type        = string
  description = "Amount of time to allow access to IACT API after initial boot"
  default     = ""
}

variable "import_key" {
  type        = string
  description = "an ssh pub key to import to all machines"
  default     = ""
}

variable "installer_url" {
  type        = string
  description = "URL to the cluster setup tool"
  default     = "https://install.terraform.io/installer/ptfe-0.1.zip"
}

variable "primary_count" {
  type        = string
  description = "The number of primary cluster master nodes to run, only 3 support now."
  default     = 3
}

variable "primary_instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = "m4.xlarge"
}

variable "secondary_count" {
  type        = string
  description = "The number of secondary cluster nodes to run"
  default     = 5
}

variable "secondary_instance_type" {
  type        = string
  description = "ec2 instance type (Defaults to `primary_instance_type` if not set.)"
  default     = ""
}

variable "ssh_user" {
  type        = string
  description = "the user to connect to the instance as"
  default     = ""
}

variable "startup_script" {
  type        = string
  description = "shell script to run when primary instance boots the first time"
  default     = ""
}

variable "subnet_tags" {
  type        = map(string)
  description = "tags to use to match subnets to use"
  default     = {}
}

variable "update_route53" {
  type        = string
  description = "whether or not to automatically update route53 records for the cluster"
  default     = true
}

variable "volume_size" {
  type        = string
  description = "size of the root volume in gb"
  default     = "100"
}

variable "weave_cidr" {
  type        = string
  description = "Specify a non-standard CIDR range for weave. The default is 10.32.0.0/12"
  default     = ""
}

variable "release_sequence" {
  type        = string
  description = "Replicated release sequence number to install - this locks the install to a specific release"
  default     = ""
}

variable "repl_cidr" {
  type        = string
  description = "Specify a non-standard CIDR range for the replicated services. The default is 10.96.0.0/12"
  default     = ""
}

### ================================ External Services Support

variable "aws_access_key_id" {
  type        = string
  description = "AWS access key id to connect to s3 with"
  default     = ""
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key to connect to s3 with"
  default     = ""
}

variable "http_proxy_url" {
  type        = string
  description = "HTTP(S) Proxy URL"
  default     = ""
}

variable "postgresql_address" {
  type        = string
  description = "address to connect to external postgresql database at"
  default     = ""
}

variable "postgresql_database" {
  type        = string
  description = "database name to use in exetrnal postgresql database"
  default     = ""
}

variable "postgresql_extra_params" {
  type        = string
  description = "additional connection string parameters (must be url query params)"
  default     = ""
}

variable "postgresql_password" {
  type        = string
  description = "password to connect to external postgresql database as"
  default     = ""
}

variable "postgresql_user" {
  type        = string
  description = "user to connect to external postgresql database as"
  default     = ""
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket to store objects into"
  default     = ""
}

variable "s3_region" {
  type        = string
  description = "Region of the S3 bucket"
  default     = ""
}

variable "ingress_allow_list" {
  type        = list(string)
  description = "List of CIDR blocks we allow to access the infrastructure"
  default     = []
}

variable "egress_allow_list" {
  type        = list(string)
  description = "List of CIDR blocks we allow the infrastructyre to access"
  default     = ["0.0.0.0/0"]
}


### ======================================================================= MISC

data "aws_ami" "ubuntu" {
  owners = ["099720109477", "513442679011"] # Canonical, Canonical (GovCloud)

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "rhel" {
  owners = ["309956199498", "219670896067"] # RedHat, RedHat (GovCloud)

  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-7.?*GA*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## random password for the installer dashboard
resource "random_pet" "console_password" {
  length = 3
}

resource "random_string" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "bootstrap_token_suffix" {
  length  = 16
  upper   = false
  special = false
}

resource "random_string" "setup_token" {
  length  = 32
  upper   = false
  special = false
}

