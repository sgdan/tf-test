# Testing terraform setup

Code to test various AWS deployments using terraform.

## To deploy the stack

Check out this repo and make sure the [tf-modules](https://github.com/sgdan/tf-modules)
repo is checked out in the same parent folder.

Create a `terraform.tfvars` file with your local region and whitelist settings:

```none
internet_whitelist = "127.0.0.1/32"
region = "us-east-1"
```

Deploy the stack using `make init plan apply` or run individually:

```bash
make init
make validate
make plan
make apply
```

## Run terraform commands directly

```bash
make shell

# Once inside the shell can run terraform directly
terraform state list
```

## Remote state

- Assumes you have `tf-modules` checked out in the same parent folder
- Run `make shell` then `cd ../tf-modules/remote-state`
- Run `terraform init`
- Run `terraform apply` to create the 3 resources in the region you specify
- Copy `remote.tf.example` from the module folder to `tf-test/remote.tf`
- Update values in `remote.tf` (bucket, key, region, kms_key_id)
- Run `make init` which should give you the option to push your local state to s3

## Private IPv4 ranges

See [Private network on Wikipedia](https://en.wikipedia.org/wiki/Private_network).

| Cidr           | Range                         | Address Count |
| -------------- | ----------------------------- | ------------- |
| 10.0.0.0/24    | 10.0.0.0 - 10.255.255.255     | 16,777,216    |
| 172.16.0.0/20  | 172.16.0.0 – 172.31.255.255   | 1,048,576     |
| 192.168.0.0/16 | 192.168.0.0 – 192.168.255.255 | 65,536        |

## Example Subnet division

Start with smallest (class C) range above: 192.168.0.0/16 which has 65,536 addresses.
We want 2 public subnets and 2 private, but will divide the range into 8 subnets
altogether (i.e. 4 will remain unused for the moment). Each of the 8 subnets will have
8192 addresses. See [VPC Designer](https://vpcdesigner.com/).

| Name      | Cidr             | Address Count |
| --------- | ---------------- | ------------- |
| Public a  | 192.168.0.0/19   | 8192          |
| Public b  | 192.168.32.0/19  | 8192          |
| Private a | 192.168.64.0/19  | 8192          |
| Private b | 192.168.96.0/19  | 8192          |
| Unused    | 192.168.128.0/19 | 8192          |
| Unused    | 192.168.160.0/19 | 8192          |
| Unused    | 192.168.192.0/19 | 8192          |
| Unused    | 192.168.224.0/19 | 8192          |

# Testing Rancher 2 install on EKS

Note: This is not Rancher's recommended install process, they
say it should only be installed on an RKE cluster

- https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/
- https://cert-manager.io/docs/installation/kubernetes/

```bash
# install cert-manager
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.13.0/cert-manager.yaml

# verify installation (3 pods running)
kubectl get pods --namespace cert-manager

# install rancher
kubectl create namespace cattle-system
helm install rancher rancher-latest/rancher -n cattle-system \
  --set hostname=rancher.my.org \
  --set tls=external

# wait for Rancher to roll out
kubectl -n cattle-system rollout status deploy/rancher

# had to edit local cluster and save to avoid "server-url" error

# Install ingress, see https://kubernetes.github.io/ingress-nginx/deploy/#using-helm
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
kubectl create namespace nginx-ingress
helm install nginx-ingress stable/nginx-ingress -n nginx-ingress \
  --set rbac.create=true \
  --set controller.hostNetwork=true \
  --set controller.kind=DaemonSet

```
