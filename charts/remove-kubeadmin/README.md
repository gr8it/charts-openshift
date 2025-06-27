# Remove Kubeadmin

After kubeadmin user is removed and no accounts exist to login to a cluster, use procedure defined in <https://access.redhat.com/solutions/4845381> to get kubeconfig with system:admin credentials, i.e. on a control plane node, use particular kubeconfig in the `/etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/node-kubeconfigs/` directory.
