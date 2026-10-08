# Terraform AWS Web Server – High-Level Overview

This project uses Terraform to build a very simple public web server in AWS.

The goal is:

```text
User visits adilselimovic.com
        ↓
Route 53 finds the correct IP address
        ↓
Traffic goes to an EC2 instance
        ↓
Nginx responds with a web page
```

## What happens when Terraform runs

When you run:

```bash
terraform apply
```

Terraform talks to AWS and creates the infrastructure needed for the website.

At a high level, the following happens.

### 1. Terraform connects to AWS

Terraform uses the AWS provider and works in the London region.

This allows Terraform to create and configure AWS resources on your behalf.

### 2. AWS creates an EC2 instance

Terraform creates a small EC2 virtual machine.

This is the actual server that will host the website.

The EC2 instance is given a public IP address so that it can be reached from the internet.

### 3. SSH access is enabled

A security group allows connections to port 22.

This lets you SSH into the EC2 instance from your computer.

The EC2 instance also uses the SSH public key that was uploaded through Terraform.

### 4. HTTP access is enabled

Another security group allows connections to port 80.

Port 80 is used for normal HTTP web traffic.

This means people on the internet can connect to the EC2 instance using a web browser.

### 5. Nginx is installed automatically

When the EC2 instance starts for the first time, a startup script runs automatically.

That script:

- updates the server
- installs Nginx
- configures Nginx to start automatically
- starts Nginx

Once this finishes, the EC2 instance is acting as a web server.

### 6. Terraform finds the existing Route 53 hosted zone

The Route 53 hosted zone for:

```text
adilselimovic.com
```

already exists.

Terraform does not create the hosted zone.

Instead, it looks it up and reads its details.

### 7. Terraform creates an A record

Terraform creates an A record inside Route 53.

The record points:

```text
adilselimovic.com
```

to the EC2 instance's public IP address.

For example:

```text
adilselimovic.com
        ↓
18.171.170.175
```

### 8. Someone visits the domain

When a user enters:

```text
http://adilselimovic.com
```

the following happens:

```text
Browser
   ↓
DNS lookup
   ↓
Route 53
   ↓
EC2 public IP
   ↓
Security group allows port 80
   ↓
EC2 instance
   ↓
Nginx
   ↓
Web page returned to browser
```

## Overall architecture

```text
                    Internet
                       |
                       v
              adilselimovic.com
                       |
                       v
                  Route 53
                       |
                  A record
                       |
                       v
                EC2 Public IP
                       |
                       v
                EC2 Instance
                 /         \
                /           \
          SSH :22         HTTP :80
             |               |
             v               v
        Admin access       Nginx
                              |
                              v
                           Website
```

## What Terraform is managing

Terraform is managing:

- the EC2 instance
- the EC2 key pair
- the SSH security group
- the HTTP security group
- the Route 53 A record

Terraform is only reading the existing Route 53 hosted zone.

## Important point about the public IP

The current setup points the domain directly to the EC2 instance's automatically assigned public IP.

That public IP can change if the EC2 instance is stopped and started.

A more stable production-style design would normally use an Elastic IP so that the public IP remains fixed.

That would look like:

```text
adilselimovic.com
        ↓
Route 53
        ↓
Elastic IP
        ↓
EC2
        ↓
Nginx
```

## In one sentence

This Terraform configuration creates a public EC2 web server, installs Nginx automatically, opens SSH and HTTP access, and points the domain `adilselimovic.com` to the EC2 server through Route 53.
