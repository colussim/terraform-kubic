
resource "null_resource" "k8s_worker" {

for_each = toset(var.worker)
    
    provisioner "file" {
    source      = "k8sdeploy-scripts"
    destination = "/tmp"

    connection {
        type        = "ssh"
        user        = "root"
        host     = each.value 
	      private_key = "${file(var.private_key)}"
        timeout = "1m"
        agent = false
        }
  }

provisioner "remote-exec" {
inline = [
<<EOT1
#!/bin/bash
set -x
chmod +x -R /tmp/k8sdeploy-scripts
/usr/sbin/swapoff -a

modprobe overlay
modprobe br_netfilter
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.forwarding=1 >> /etc/sysctl.conf
echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.conf
sysctl -p

${data.external.kubeadm_join.result.command} && \

mkdir -p $HOME/.kube && scp root@${var.master}:$HOME/.kube/config $HOME/.kube && \
chown $(id -u):$(id -g) $HOME/.kube/config && \
/bin/rm -r /tmp/k8sdeploy-scripts
/usr/bin/kubectl label node ${each.value} node-role.kubernetes.io/worker=worker
/usr/bin/kubectl get nodes

EOT1
    ]
   connection {
                        type        = "ssh"
                        user        = "root"
                        host     = each.value 
                        private_key = "${file(var.private_key)}"
                         timeout = "1m"
                        agent = false
                }	
  }
}

