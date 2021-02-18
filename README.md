# Rancher on vSphere and HPE Nimble
1.  Create the file `group_vars/all/vars.yml` based on the file `vars.yml.sample` in the same folder

2.  Create the file `group_vars/all/vault.yml` using the sample file found in the same folder

3.  Edit/Creates a file named `hosts` based on the sample Ansible inventory provided (`hosts.sample`)

4.  Deploy an RKE cluster with Rancher Server

   ```bash
   $ ansible-playbook -i hosts site.yml
   ```

5. If you use the HPE Nimble CSI driver create a folder in your Nimble array default pool matching the name of the user cluster. This name is specified with the environment variable USER_CLUSTER_TAG (see below)

6. Deploy the user cluster with the name foo (for example) using

   ```bash
   $ export USER_CLUSTER_TAG=foo
   $ ansible-playbook -i hosts user.yml
   ```

If you want to access the apps you deploy in the Kubernetes clusters you will probably have to create wildcard DNS names in your DNS infra. They should point to a load balancer which distributes the traffic across the worker nodes.# Rancher on vSphere and HPE Nimble
1.  Create the file `group_vars/all/vars.yml` based on the file `vars.yml.sample` in the same folder

2.  Create the file `group_vars/all/vault.yml` using the sample file found in the same folder

3.  Edit/Creates a file named `hosts` based on the sample Ansible inventory provided (`hosts.sample`)

4.  Deploy an RKE cluster with Rancher Server

   ```bash
   $ ansible-playbook -i hosts site.yml
   ```

5. If you use the HPE Nimble CSI driver create a folder in your Nimble array default pool matching the name of the user cluster. This name is specified with the environment variable USER_CLUSTER_TAG (see below)

6. Deploy the user cluster with the name foo (for example) using

   ```bash
   $ export USER_CLUSTER_TAG=foo
   $ ansible-playbook -i hosts user.yml
   ```

If you want to access the apps you deploy in the Kubernetes clusters you will probably have to create wildcard DNS names in your DNS infra. They should point to a load balancer which distributes the traffic across the worker nodes.
