         ___        ______     ____ _                 _  ___  
        / \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \ 
       / _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
      / ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
     /_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/ 
 ----------------------------------------------------------------- 


Repo Name : group21-project

### Prerequisites before Deployment ###
1. Create three S3 buckets that corresponds to the three environment to be deploed. 
2. Create a github repo and add the users with appropriate permissions.
3. Navigate to Cloud9 and create an environment that will work as an admin.
4. Go to the S3 buckets in console and click on the buckets that are created. Click in "Upload" to upload images into the S3 buckets.
5. As the deployment for the three environments are similar with just minor adjustments, this readme file contains generalized deployment steps.
6. environment ------- cidr ----- instances -- instance type
7.      dev       10.100.0.0/16       2           t3.micro
8.      staging   10.200.0.0/16       3           t3.small
9.      prod      10.250/0.0/16       3           t3.medium

### Creating the Architecture ###

1. Open the Cloud9 environment and create a module for the project giving it an appropriate name. 
2. Create a module for your environment and add two sub modules called network and webservers. Another module that will contain sub modules for load balancer, autoscaling groups and aws_network.
3. Create another module called aws_network in that folder that will contain information regarding  the network config, variables to be used and output.
    - Create main.tf that will define the basic parameters such as provider, availability zones, tags. 
    - It will also contain information on defining the network architecture like VPC, subnets, Internet Gateway, NAT Gateway and Route table.
    - The variables.tf will the variables that will be referenced on later on. This .tf file will contain the cidr range and env variable that will be changed according to the requirements mentioned in the prerequisites. 
    - Create an output.tf that displays various outputs such as public subnets and the vpc_id.
4. Navigate to the network module and create a config.tf that contains the backend s3 bucket information.
5. Create a main.tf that will use the aws_network module as a source and rest of the variables.
6. The variables.tf and output.tf will be similar to that in the aws_network module.
7. Go to the webservers module and create the following files.
    - config.tf that contains backend s3 information.
    - main.tf that defines the provider, instance id, remote state, EBS volume, tags, security groups, Elastic IP, Bastion.
    - output.tf that will display instance id, elastic ip, etc and other relevanet information.
    - variables.tf that will define necessary variables such as tags, prefix as well as the number of instance that are supposed to be deployed. 
8. Generate a ssh key in the webservers module.
9. Create a static webpage that will be hosted on the webservers, that displays the relevant information such as the instance name, ip address, etc. 
10. Create a module for autoscaling with the following files.
    - main.tf that will contain the general information as well as additional information for autoscaling.
        - It will contain aws_launch_configuration whose parameters will changed according to the requirements, here it's the instance type.
        - aws_autoscaling_group that will refer to launch_configuration and desired_capacity whose values will change according to requirements.
        - aws_autoscaling_policy scale_up and scale_down policies that will provision and delete instances according to the alarm_actions.
        - aws_cloudwatch_metric_alarm defines the parameters that will trigger the alarms such as metric_name: CPU Utilization, threshold: 10, etc.
    - variables.tf that will define that usual variables such as tags, prefix, etc.
    - A html file that will be hosted on the newly provisioned instances.
11. Create a module for loadbalancer and create the following files.
    - main.tf that will contain the basic parameters along with some load balancer parameters.
        - we have created an application load balancer.
        - target_group that will target instances. 
        - load balancer listener that will filter out the instances.
        - target group attachment that will register the targets to target groups.
    - variables.tf in a similar manner as before along with changing the number of instances to be added to the target group as per requirements.

### Test Deployment ###

1. Go to the network module and begin deploying the architecture using the usual tf init, plan and apply commands.
2. Following that go perform the same steps in webservers module. 
    - When deploying there might be times where the aws_autoscaling_group will take a long time to configure and as we have put an limit on the deployment time of 10 mins, terraform will automatically shutdown that process.
    - Although StatusCode will return Successful, which means that the targets are successfully attached to the target groups. Verify it through console.

### Pushing and commiting to Git repos ###
1. Create a repository in GitHub with .gitignore file which excludes all the files that should be ignored in the git repository.
2. Generate a token that will be used for accessing the repository and simultaneously pushing the code to branches.
3. Each member will create a seperate branch to push their code to.
    - Configure local repo first using following commands:
        - git init
        - git config –global user.name <user_name>
        - git config -l
        - git init
        - git remote add origin <URL copied from GitHub>
    - Add commits to the branches using these commands:
        - git add .
        - git status
        - git commit -m "Text u want to display"
    - Commands that will be used to navigate branches:
        - git branch <name>   # this will create branch called <name>
        - git checkout <name> # switch branches
        - git merge           # to merge branch to master.
4. Create a develop branch, and pushed all the code from every branch to avoid merge conflicts.
5. The code is then pushed into master from develop branch
6. Cloned the code from the master branch into our cloud9 environment to preform the final deployment
7. Add tfsec in github action to scan the code for main and develop branch to perform the security check when ever the code is pushed or pulled.

### Final Deployment ###

1. Implement the prerequisites as mentioned in the beginning but not the GitHub steps as we are deploying as a user.
2. Create a module in which the deployment will occur and clone the repository using the command: git clone -b main <URL of the repository>.
3. Following the deployment steps above navigate to the network and webservers modules of the environment.
4. Use the usual terraform commands to deploy the architecture.
5. Go to EC2 console, navigate to Load Balancer and copy-paste the DNS address into a new webpage.
6. We should be directed to the webpages hosted on the EC2 instances. Refresh the page and the IP addresses should cycle between the different instances indicating that the load is balanced between the instances in the target groups.
7. For autoscaling, go to EC2 instances and manually terminate/stop a instance. Wait for sometime and the autoscaling will automatically provision a new EC2 instance with similar configurations. 
8. This means that our Load Balancer and Auto Scaling Groups are woking as intended. 


### End ###
