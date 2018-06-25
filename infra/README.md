# Main infrastructure configuration
For any operation use the parent directory Terraform wrapper because it simplifies the 
management and avoids problems.

### Instance access
To ssh into the instance there some preconditions to meet:
- The iam user in use has to have a Public SSH key set
- To simplify ssh and to make the shuttle tool work the following config has to be set in `~/.ssh/config`:
  ```
  Host <bastion_host_public_ip>
      User <user_name>
      IdentityFile ~/.ssh/id_rsa
  ``` 
  To get the bastion host of the environment run `./terraformw <env> refresh`, the ip will be
  in the outputs.
- Last but not least, the machines have to be recreated with an apply command because the users
  are initialized on instance creation through cloud init configuration.
      
