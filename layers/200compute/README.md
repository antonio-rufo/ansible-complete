# 200compute

This layer creates the Computing resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | The account ID you are building into. | string | n/a | yes |
| region | The AWS region the state should reside in. | string | `"ap-southeast-2"` | yes |
| environment | The name of the environment, e.g. Production, Development, etc. | string | `"Development"` | no |
| security\_group\_ansible\_target\_name | Name for the Ansible Target security group. | string | n/a | yes |
| key\_pair | Instances Key Pair. | string | n/a | yes |
| instance\_type\_ansible\_target | Ansible Target Instance Type. | string | n/a | yes |
| instance\_name\_ansible\_target | Ansible Target Server Instance Name. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ansible\_target\_ip | The Public IP of the Ansible Target server. |
