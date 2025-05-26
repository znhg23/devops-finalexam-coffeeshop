# CoffeeShop DevOps Final Project

This is my final DevOps exam project for deploying a microservices-based CoffeeShop application on AWS using Terraform, Docker, and GitHub Actions.

## Technologies Used

- Terraform – Provision AWS infrastructure
- Docker & Docker Compose – Containerize and manage services
- Amazon EC2 – Host the application
- Amazon RDS (PostgreSQL) – Store data persistently
- GitHub Actions – Automate CI/CD pipeline
- RabbitMQ – Enable inter-service messaging

## Infrastructure (Terraform)

Provisioned via `main.tf`:

- VPC with two public subnets
- Internet Gateway + route table
- EC2 instance with Docker installed
- RDS PostgreSQL instance (publicly accessible)
- Security Group with:
  - Port 22: SSH
  - Port 5432: PostgreSQL
  - Port 8888: Web frontend
  - Port 5672 & 15672: RabbitMQ

## Microservices Overview

All services are containerized and orchestrated using `docker-compose.yml`.

| Service  | Port         | Description              |
| -------- | ------------ | ------------------------ |
| Web      | 8888         | Frontend UI              |
| Proxy    | 5000         | gRPC gateway             |
| Product  | 5001         | Product microservice     |
| Counter  | 5002         | Order counter service    |
| Barista  | -            | Beverage prep service    |
| Kitchen  | -            | Food prep service        |
| RabbitMQ | 5672 / 15672 | Messaging + UI dashboard |

All container images are pulled from Docker Hub: https://hub.docker.com/u/znhg23

## Manual Deployment (via SSH)

1. SSH into EC2:

ssh -i opswat-key.pem ec2-user@54.255.241.246

2. Clone & start:

git clone https://github.com/znhg23/coffeeshop-devops.git
cd coffeeshop-devops
docker-compose up -d

3. Access the app in your browser:

http://54.255.241.246:8888

## CI/CD with GitHub Actions

On every push to the main branch:

- GitHub Actions runs `.github/workflows/deploy.yml`
- Connects to EC2 over SSH
- Pulls the latest code
- Restarts all services

Secrets Used in GitHub:

| Secret Name     | Description                |
| --------------- | -------------------------- |
| EC2_HOST        | EC2 public IP              |
| EC2_SSH_KEY     | PEM key content            |
| DOCKER_USERNAME | Docker Hub username        |
| DOCKER_PASSWORD | Docker Hub password or PAT |

## Monitoring

You can monitor services on the EC2 instance with:

docker stats
docker-compose logs -f

## Database Access

- Host: coffee-db.c1yogcae2zbe.ap-southeast-1.rds.amazonaws.com
- Port: 5432
- Database: coffee
- Username: coffeeuser
- Password: coffeepass123
- SSL: disabled via parameter group (rds.force_ssl = 0)

## Final Submission Checklist

| Task                            | Status  |
| ------------------------------- | ------- |
| Terraform infrastructure set up | ✅ Done |
| EC2 instance provisioned        | ✅ Done |
| RDS PostgreSQL provisioned      | ✅ Done |
| Docker Compose deployed         | ✅ Done |
| All services functional         | ✅ Done |
| RabbitMQ running                | ✅ Done |
| GitHub Actions CI/CD working    | ✅ Done |
| Web UI accessible               | ✅ Done |
| README.md written               | ✅ Done |

## Repository Structure

.
├── main.tf # Terraform for AWS infra  
├── terraform.tfvars # DB credentials (gitignored)  
├── docker-compose.yml # Service orchestration  
├── .github/  
│ └── workflows/  
│ └── deploy.yml # CI/CD pipeline via GitHub Actions  
└── README.md # Project documentation

## Author

Student: Danh Mai
GitHub: https://github.com/znhg23
Docker Hub: https://hub.docker.com/u/znhg23

## Access URLs

| Component   | URL                         |
| ----------- | --------------------------- |
| Web UI      | http://54.255.241.246:8888  |
| RabbitMQ UI | http://54.255.241.246:15672 |

## Notes

- PEM key file: `opswat-key.pem` used for SSH
- Images pulled from Docker Hub repo: `znhg23/...`
- RDS configured to allow non-SSL connections
- Docker Compose automatically connects all services internally
