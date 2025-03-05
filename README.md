**Terraform for GCP Project Documentation**

## **Project Overview**
This Terraform project is designed to automate the provisioning and management of Google Cloud Platform (GCP) resources. The project follows an Infrastructure as Code (IaC) approach, allowing for consistent, repeatable, and version-controlled deployments. It is structured into modules and environments for better organization and maintainability.

## **Project Structure**
The project is divided into two main directories:
1. **dev/** – This directory contains Terraform configurations specific to the development environment.
2. **modules/** – This directory contains reusable Terraform modules for different GCP services.

### **1. dev Directory**
This directory contains the core Terraform configuration files used to set up the development environment:
- **backend.tf**: Configures the backend storage for Terraform state files.
- **key.json**: Contains service account credentials for authentication with GCP.
- **main.tf**: The primary Terraform script that defines infrastructure components.
- **providers.tf**: Specifies the Terraform provider configuration (e.g., Google Cloud provider settings).
- **terraform.tfvars**: Stores variable values used in Terraform configurations.
- **variables.tf**: Defines input variables for the project.

### **2. modules Directory**
The `modules/` directory contains modular components of the infrastructure, each representing a distinct GCP service. These modules enable reusability and better management of Terraform configurations.

#### **Module Descriptions**

- **apis/**:
  - Manages API enablement for required GCP services.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **cloud_armour/**:
  - Configures Google Cloud Armor for DDoS protection and security policies.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **cloud_cdn/**:
  - Sets up Google Cloud CDN for optimizing content delivery.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **cloud_dns/**:
  - Configures Cloud DNS for domain name resolution.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **cloud_run/**:
  - Deploys and manages Cloud Run services for containerized applications.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **cloud_sql/**:
  - Sets up and manages Cloud SQL instances for relational databases.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **gce/**:
  - Configures Google Compute Engine (GCE) virtual machines.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **gke_autopilot/**:
  - Provisions a Google Kubernetes Engine (GKE) Autopilot cluster for fully managed Kubernetes.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **gke_standard/**:
  - Sets up a standard GKE cluster for Kubernetes workloads.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **identity_platform/**:
  - Manages Identity Platform for authentication and identity management.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

- **vpc/**:
  - Configures Virtual Private Cloud (VPC) networking, including subnets and firewall rules.
  - Files: `main.tf`, `outputs.tf`, `variables.tf`.

## **Usage Instructions**
### **1. Prerequisites**
- Install Terraform (latest version recommended)
- Configure GCP SDK and authenticate using the service account key (`key.json`)
- Enable required GCP APIs (if not already enabled)

### **2. Initialization**
Run the following command in the `dev/` directory to initialize Terraform:
```sh
terraform init
```

### **3. Planning**
Generate an execution plan to preview infrastructure changes:
```sh
terraform plan
```

### **4. Apply Configuration**
Apply the Terraform configuration to provision resources:
```sh
terraform apply
```

### **5. Destroy Infrastructure**
To remove all resources managed by Terraform, run:
```sh
terraform destroy
```

## **Best Practices**
- **State Management**: Use remote backends like Google Cloud Storage (GCS) for storing state files securely.
- **Modularization**: Keep infrastructure components modular to enable reusability and scalability.
- **Security**: Restrict access to `key.json` and follow the principle of least privilege (PoLP) for IAM roles.
- **Version Control**: Store Terraform configurations in a version-controlled repository (e.g., GitHub, GitLab).

## **Conclusion**
This Terraform project provides an automated and scalable way to manage GCP resources efficiently. By following modular design principles, it ensures better organization, maintainability, and security in infrastructure management.

