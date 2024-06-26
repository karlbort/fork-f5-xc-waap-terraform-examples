Deploying F5 XC Bot Defense on Regional Edge Automation Guide
=============================================================

Prerequisites
--------------

-  `F5 Distributed Cloud Account
   (F5XC) <https://console.ves.volterra.io/signup/usage_plan>`__

   -  `F5XC API
      certificate <https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials>`__

-  `Terraform Cloud Account <https://developer.hashicorp.com/terraform/tutorials/cloud-get-started>`__
-  `GitHub Account <https://github.com>`__

List of Products Used
---------------------

-  **xc:** F5 Distributed Cloud Bot Defense
-  **vk8's:** XC Kubernetes Service
-  **airline:** Online Airline demo test web application

Tools
------

-  **Cloud Provider:** XC
-  **IAC:** Terraform
-  **IAC State:** Terraform Cloud
-  **CI/CD:** GitHub Actions

Terraform Cloud
----------------

-  **Workspaces:** Login to terraform cloud and create below CLI or API driven workspaces for storing the terraform state of each job.

   +---------------------------+-------------------------------------------+
   |         **Workflow**      |  **Assets/Workspaces**                    |
   +===========================+===========================================+
   | f5-xc-waf-on-re-appconnect| infra, aks-cluster, xc                    |
   +---------------------------+-------------------------------------------+

-  **Workspace Sharing:** Under the settings for each Workspace, set the **Remote state sharing** to share with each Workspace created.

-  **Variable Set:** Create a Variable Set with the following values:

   +------------------------------------------+--------------+------------------------------------------------------+
   |         **Name**                         |  **Type**    |      **Description**                                 |
   +==========================================+==============+======================================================+
   | TF_VAR_azure_service_principal_appid     | Environment  | Service Principal App ID                             |
   +------------------------------------------+--------------+------------------------------------------------------+
   | TF_VAR_azure_service_principal_password  | Environment  | Service Principal Secret                             |
   +------------------------------------------+--------------+------------------------------------------------------+
   | TF_VAR_azure_subscription_id             | Environment  | Your Subscription ID                                 | 
   +------------------------------------------+--------------+------------------------------------------------------+
   | TF_VAR_azure_subscription_tenant_id      | Environment  | Subscription Tenant ID                               |
   +------------------------------------------+--------------+------------------------------------------------------+
   | VES_P12_PASSWORD                         | Environment  | Password set while creating F5XC API certificate     |
   +------------------------------------------+--------------+------------------------------------------------------+
   | VOLT_API_P12_FILE                        | Environment  | Your F5XC API certificate. Set this to **api.p12**   |
   +------------------------------------------+--------------+------------------------------------------------------+
   | ssh_key                                  | TERRAFORM    | Your ssh key for accessing the created resources     | 
   +------------------------------------------+--------------+------------------------------------------------------+
   | tf_cloud_organization                    | TERRAFORM    | Your Terraform Cloud Organization name               |
   +------------------------------------------+--------------+------------------------------------------------------+



GitHub
-------

-  Fork and Clone Repo. Navigate to ``Actions`` tab and enable it.

-  **Actions Secrets:** Create the following GitHub Actions secrets in
   your forked repo

   -  P12: The linux base64 encoded F5XC P12 certificate
   -  TF_API_TOKEN: Your Terraform Cloud API token
   -  TF_CLOUD_ORGANIZATION: Your Terraform Cloud Organization name
   -  TF_CLOUD_WORKSPACE\_\ *<Workspace Name>*: Create for each
      workspace in your workflow per each job

      -  EX: TF_CLOUD_WORKSPACE_AKS_CLUSTER would be created with the
         value ``aks-cluster``

-  Created GitHub Action Secrets:
.. image:: assets/action-secret.JPG

Workflow Runs
###############

**STEP 1:** Check out a branch with the branch name as suggested below for the workflow you wish to run using
the following naming convention.

**DEPLOY**

+----------------------------+-----------------------+
| Workflow                   |  Branch Name          |
+============================+=======================+
| f5-xc-api-on-re-appconnect | deploy-api-re-ac-aks  |
+----------------------------+-----------------------+

**DESTROY**

+----------------------------+-----------------------+
| Workflow                   |  Branch Name          |
+============================+=======================+
| f5-xc-api-on-re-appconnect | destroy-api-re-ac-aks |
+----------------------------+-----------------------+


**STEP 2:** Rename ``azure/azure-infra/terraform.tfvars.examples`` to ``azure/azure-infra/terraform.tfvars`` and add the following data: 

-  project_prefix = “Your project identifier name in **lower case** letters only - this will be applied as a prefix to all assets”.

-  azure_region = “Azure Region/Location” ex. "southeastasia".

-  aks-cluster = Set this value to true as we need AKS cluster in our usecase.

-  Also update assets boolean value as per your workflow.

**Step 3:** Rename ``xc/terraform.tfvars.examples`` to ``xc/terraform.tfvars`` and add the following data: 

-  api_url = “Your F5XC tenant” 

-  xc_tenant = “Your tenant id available in F5 XC ``Administration`` section ``Tenant Overview`` menu” 

-  xc_namespace = “The existing XC namespace where you want to deploy resources” 

-  app_domain = “the FQDN of your app (cert will be autogenerated)” 

-  xc_waf_blocking = “Set to true as we need to enable blocking”

-  k8s_pool = "Set to true as backend is residing in k8s"

-  serviceName = "k8s service name of backend"

-  serviceport = "k8s service port of backend"

-  advertise_sites = "set to false as we want to advertise on public"

-  http_only = "set to true"

-  xc_delegation = "set to true as we want to automatically manage DNS records for http load balancer"

-  az_ce_site = "set to true since we want to deploy azure CE site"

-  xc_service_discovery = "set to true as want to create service discovery object in XC console"

-  xc_api_disc = true

-  xc_api_pro  = true

-  xc_api_spec = ["path to your OAS in XC"] **note** Check `Here ` for how to obtain this value.

-  xc_api_val = true

-  xc_api_val_all        = true

-  xc_api_val_properties = ["PROPERTY_QUERY_PARAMETERS", "PROPERTY_PATH_PARAMETERS", "PROPERTY_CONTENT_TYPE", "PROPERTY_COOKIE_PARAMETERS", "PROPERTY_HTTP_HEADERS", "PROPERTY_HTTP_BODY"]

-  xc_api_val_active = true

-  enforcement_block  = true

-  enforcement_report = false

-  fall_through_mode_allow = false

-  xc_api_val_custom = false 

**STEP 4:** Commit and push your build branch to your forked repo 

- Build will run and can be monitored in the GitHub Actions tab and TF Cloud console

**STEP 5:** Once the pipeline completes, verify your CE, Origin Pool and LB were deployed. (**Note:** CE sites will take 15-20 mins to come online)

**STEP 6:** To validate the test infra, copy the domain name configured in Load balancer and access it in the browser, You should be able to access the demo application as shown in the image below

.. image:: assets/botique.JPG

**Note:** If you want to destroy the entire setup, checkout a branch with name ``destroy-waf-re-ac-k8s`` and push the repo code to it which will trigger destroy workflow and will remove all created resources

