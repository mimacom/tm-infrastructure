[![CircleCI](https://circleci.com/gh/mimacom/tm-infrastructure.svg?style=svg)](https://circleci.com/gh/mimacom/tm-infrastructure)

# Time Manager infrastructure code
Infrastructure base code for the Time Manager application. It consists of two environments
`dev` and `prod`.

### Preparation
To access the cluster some preparations have to be made:
- Create a iam user in the account
- Add an access key for your user and save the secret
- Create a profile for the aws cli called mimacom using the key and secret
    - `aws configure --profile mimacom`
    
After this steps you are ready to use the terraform wrapper, of course to be able to change 
the infrastructure the user has to have the appropriate permissions.

### Terraform wrapper
The Terraform wrapper is a bash script to simplify the infrastructure management operations.

This are the goals available in the Terraform wrapper:
```
usage: ./terraformw <goal> <commands>

goals:
    prepare                  -- check for required tools and initialize terraform
    fmt                      -- format the codebase
    dev <commands>           -- execute terraform goals on dev
    prod <commands>          -- execute terraform goals on prod
    shuttle <env>            -- open a transparent access to the chosen environment
``` 

The shuttle command will open a tunnel to the correct vpc and forward all the request through 
the bastion host.

### SSH access
Refer to the infra [README](infra/README.md) for details on how to enable SSH access for you user.