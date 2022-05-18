variable "master" {
  default = "master01"
  description = "Hostname master node"
}

variable "nodes" {
  default = 3
  description = "Number of Worker"
}

variable "worker" {
    type = list
    default = ["worker01", "worker02","worker03"]
    description = "Hostname for worker node"
}

variable "clustername" {
  default = "k8s-techlabnews"
  description = "K8S Cluster name"
}

variable "user" {
  default = "root"
  description = "User name to connect hosts"
}

variable "private_key" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "The path to your private key"
}
