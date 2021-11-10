# terraform-training
## Usage
EC2 instance and s3 bucket deployment using terraform, packer and terratest.


## Packer
To build the AMI for terraform, run ``` packer build . ``` inside  ```images``` directory. The ```/test/setup.sh``` installs known python dependencies for the ```http-server``` run. It also configures ssh configuration so we can access it from a public ip.

## Terraform
Run ``` terraform apply ``` inside ``` instances ``` to run the instance.

## Terratest
Install dependencies listed on the ``` import ``` using ```go get <MODULE>```, then run ``` go test -v ``` to run all tests.