resource "null_resource" "k8s_master" {

    

    provisioner "file" {
        source      = "k8sdeploy-scripts"
        destination = "/tmp/"

            connection {
                        type        = "ssh"
                        user        = "root"
                        host     = var.master
                        private_key = "${file(var.private_key)}"
                        timeout = "1m"
                        agent = false
                }
    }

provisioner "remote-exec" {
inline = [
<<EOT
#!/bin/bash
set -x
chmod +x -R /tmp/k8sdeploy-scripts
/tmp/k8sdeploy-scripts/setk8sconfig.sh ${var.clustername}
/usr/sbin/swapoff -a

modprobe overlay
modprobe br_netfilter
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf
echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.conf
sysctl -p

/usr/bin/kubeadm init --config /tmp/k8sdeploy-scripts/setk8sconfig.yaml

mkdir -p $HOME/.kube && sudo /bin/cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

/usr/bin/kubectl apply -f /usr/share/k8s-yaml/weave/weave.yaml
/usr/bin/kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
/usr/bin/kubectl apply -f /tmp/k8sdeploy-scripts/clusteradmin.yaml

/bin/rm -r /tmp/k8sdeploy-scripts

EOT
                ]
        connection {
                        type        = "ssh"
                        user        = "root"
                        host     = var.master
                        private_key = "${file(var.private_key)}"
                        timeout = "1m"
                        agent = false
                }
        }
        provisioner "local-exec" {
                command    = "./k8sdeploy-scripts/getkubectl-conf.sh ${var.master}"
        }
}

data "external" "kubeadm_join" {
  program = ["./k8sdeploy-scripts/kubeadm-token.sh"]

  query = {
    host = var.master
  }
  depends_on = [null_resource.k8s_master]

}