# Rancher on vSphere and nimble
  1) edit group_vars/all/vars.yml using the sample file
  2) edit group_vars/all/vault.yml using the sample file
  3) deploy RKE cluster with Rancher Server
     $ ansible-playbook -i hosts site.yml
  4) if you use the HPE Nimble CSI driver create a folder in your Nimble array default pool matching the name
     of the user cluster. This name is specified with the environment variable USER_CLUSTER_TAG (see below)
  5) deploy a user cluster with
    $ export USER_CLUSTER_TAG=foo
    $ ansible-playbook -i hosts user.yml
    This will deploy a Rancher managed user cluster where nodes are named foo-mas<i> and foo-wrk<j> under the resource pool fooCluster. VMs are inventoried under a VM folder named fooCluster

