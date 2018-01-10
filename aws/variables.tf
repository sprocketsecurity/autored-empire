variable "aws_priv_key" {
  default = "~/.ssh/redteam.pem"
}

variable "client_name" {
	description = "Client's name that will get appened to the virtual machines name for easy identification"
	# uncomment below to ask each time
	default = ""
}
