
### Table of Contents
- [Why Terraform?](#why-terraform)
- [Infrastructure as Code](#infrastructure-as-code)
- [Hands-on Terraform](#hands-on-terraform)
  - [Creating Configuration Files](#hands-on-terraform)
  - [Terraform Commands](#hands-on-terraform)
    - [terraform init](#hands-on-terraform)
    - [terraform plan](#hands-on-terraform)
    - [terraform apply](#hands-on-terraform)
    - [terraform destroy](#hands-on-terraform)
- [Learning Resources](#want-to-learn-more)

### Why Terraform?

In summary, Terraform is a tool used to manage your cloud services.

But why Terraform?

Usually, cloud services provide a GUI (Graphical User Interface) that allows users to interact with the services directly. The following screenshot shows an example from AWS GUI.

![aws gui](https://fengyu20.github.io/assets/terraform/aws_gui.png)

Although this has some benefits, it is not suitable for batch processing—especially when you need to switch between different services. It is also inconvenient if you prefer to interact with cloud services through your code.

You might be thinking that these cloud services already provide a CLI (Command Line Interface) for accessing the services. The following code snippet shows an example from AWS CLI.

```bash
# Start an EC2 Instance
aws ec2 start-instances --instance-ids i-0123456789abcdef0

# Upload a File to a Bucket
aws s3 cp myfile.txt s3://my-new-bucket/
......
```

Sure, using CLI looks fine. But what if you want to track settings of your cloud services? **Keeping version history** is crucial in the coding world.

Also, sometimes one service depends on another. You always need to remember **dependencies** - always launch one service before another; otherwise, provisioning will fail.

Moreover, what if you don’t want to lock yourself into a single cloud service vendor? It becomes inconvenient to interact with **multiple cloud services** separately.

This is where Terraform comes in and offers benefits in these areas.

Before diving into Terraform, we will first discuss the idea behind Terraform—infrastructure as code.

### Infrastructure as Code

> *Note: This part is written based on my personal understanding of [What is Infrastructure as Code?](https://www.youtube.com/watch?v=zWw2wuiKd5o)*

Let’s imagine we’re building our cloud services from scratch, including Kubernetes and database services.

Using the CLI, we might execute commands like `create k8s` and `create database`, specifying relevant settings such as the region.

This approach consists of step-by-step instructions, which is why we call it **imperative**.

While this approach might work initially, it can become cumbersome over time. For example:
1. What if we want to deploy the same service 10 times? We would have to write custom scripts to handle scaling.
2. What if we need to add another service, such as a load balancer, later? We would have to modify the settings repeatedly.

As we discussed with other tools, developers dislike tedious and repetitive work. That’s why they came up with the **declarative** method.

With this approach, we define the desired final state in a configuration file, and let the tool determine the necessary steps to achieve that state.

For instance, we can specify that we want 10 Kubernetes instances, 5 databases, etc., in one file. When the business grows, we simply update this file and reapply it, allowing the tool to orchestrate the necessary changes automatically.

![IaC](https://fengyu20.github.io/assets/terraform/IaC.png)


### Hands-on Terraform
> *Note: This part is written based on my personal understanding of [Terraform Explained?](https://www.youtube.com/watch?v=HmxkYNv1ksg) and [Introduction to HashiCorp Terraform with Armon Dadgar](https://www.youtube.com/watch?v=h970ZBgKINg).*

To use Terraform, you first need to write down the desired state in a configuration file, usually called `main.tf`.

Let’s say we are going to launch three DynamoDB tables on AWS. You can define it as follows:

```hcl
provider "aws" {
    region = "eu-west-3"  
}

# DynamoDB Table
resource "aws_dynamodb_table" "my_table" {
    count        = 3
    name           = "my-dynamodb-table-${count.index}"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "id"

    attribute {
        name = "id"
        type = "S"
    }

    tags = {
        Name        = "My DynamoDB Table ${count.index}"
        Environment = "Dev"
  }
}
```

After creating this file, you need to run the following commands:
1. **`terraform init`**: This command downloads the required provider plugins, sets up the backend (where the state is stored), and initializes Terraform’s core components.
2. **`terraform plan`**: This command compares the current state of your cloud services with the desired state defined in your configuration file, and it creates an execution plan (without executing the changes).
3. **`terraform apply`**: Terraform displays the execution plan, and once you confirm it, it interacts with the providers to apply the final changes. 

In this case, if you don’t already have the DynamoDB tables, Terraform will create 3 separate tables. Alternatively, if some tables exist (which also need to be managed by Terraform)but their total number is less than 3, Terraform will create the missing tables to reach the desired count.

When you no longer need the services, simply run **`terraform destroy`**` to clean up resources and avoid unnecessary charges.

![](https://fengyu20.github.io/assets/terraform/main_commands.png)

### Want to Learn More?

Terraform is a tool for provisioning cloud services.

If you are completely new to cloud services, I recommend familiarizing yourself with them first. Personally, I self-taught cloud services by preparing for the [AWS SSA certification](https://aws.amazon.com/certification/certified-solutions-architect-associate/), but it did take some time.

After learning about cloud services, I recommend watching this video ([What is Infrastructure as Code?](https://www.youtube.com/watch?v=zWw2wuiKd5o)) to understand the concept behind Terraform first.

Then, you can watch [Terraform Explained?](https://www.youtube.com/watch?v=HmxkYNv1ksg),and [Introduction to HashiCorp Terraform with Armon Dadgar](https://www.youtube.com/watch?v=h970ZBgKINg) to understand more about the architecture and commands to use.

You can also follow the [Get Started Doc](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/) for step-by-step instructions.

Have fun learning Terraform!

