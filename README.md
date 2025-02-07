# Helm for Blazemeter Private Location

[Download the latest Chart](https://github.com/Blazemeter/helm-crane/releases/download/1.2.2/helm-crane-1.2.2.tgz)

Deploy Blazemeter private location engine to your Kubernetes cluster using HELM chart. Plus the chart allows to make advanced configurations if required. 

![Helm-crane](/Image.png)

### [1.0] Requirements
1. A [BlazeMeter account](https://www.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://help.blazemeter.com/docs/guide/private-locations-system-requirements.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____1)


### [2.0] Generating Harbour_ID, Ship_ID and Auth_token in Blazemeter

>To start with, Blazemeter user will need Harbour_ID, Ship_ID & Auth_token from Blazemeter. You can either generate these from Blazemeter GUI or through API as described below.

1. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter GUI
    - Login to Blazemeter & create a [Private Location](https://help.blazemeter.com/docs/guide/private-locations-create.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____2)
    - Copy the [Harbour_ID](https://help.blazemeter.com/docs/guide/private-locations-where-to-find-harbor-id-and-ship-id.html?tocpath=Private%20Locations%7CPrivate%20Locations%20Knowledge%20Base%7C_____1) once the private location has been created in BlazeMeter.
    - Create an [Agent](https://help.blazemeter.com/docs/guide/private-locations-install-agent.html)
    - Copy the Ship_ID & Auth_token, you can copy Harbour_ID, when you click on the add agent button. 

2. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter API
    - You should have the Blazemeter API key and secret
    - Create a Private location [using API](https://help.blazemeter.com/apidocs/performance/private_locations_create_a_private_location.htm?tocpath=Performance%7CPrivate%20Locations%7C_____3)
    - Copy the Harbour ID
    - Create an Agent [using API](https://help.blazemeter.com/apidocs/performance/private_locations_create_an_agent.htm?tocpath=Performance%7CPrivate%20Locations%7C_____4)
    - Copy the Ship_ID
    - Generate the docker command [using API](https://help.blazemeter.com/apidocs/performance/private_locations_docker_command.htm?tocpath=Performance%7CPrivate%20Locations%7C_____5)
    - Copy Auth_token, harbour_id and ship_id from the docker command

---

### [3.0] Downloading the chart

- Pull/Download the chart - tar file from the GitHub repository 

  [Download the latest Chart](https://github.com/Blazemeter/helm-crane/releases/download/1.2.2/helm-crane-1.2.2.tgz)

- Untar the chart
```bash
tar -xvf helm-crane(version).tgz
```

<!To start with, I recommend adding the blazemeter-crane repo to your helm repo list
<!
<!1. We will add `blazemeter` helm reporsitory to our cluster, [read documentations](https://helm.sh/docs/helm/helm_repo/)
<!```
<!helm repo add blazemeter https://helm-repo-bm.storage.googleapis.com/charts
<!```
<!2. Confirm the addition of this repository using the following:
<!```
<!helm repo list
<!```
<!Once the repository has been added, we can simply use the repository name (blazemeter in our case) to install the charts through chart name (instead of using the complete url all the time).
<!
<!3. Pull the chart
<!```
<!helm pull blazemeter/blazemeter-crane --untar=true
<!```
<!So, `blazemeter` is our repo name as added before [2.3], and `blazemeter-crane` is the chart name. 
<!This above command will by-default pull the latest version of the chart, i.e. 0.1.2 which allows configuring CA_bundle. However, if you are interested in other version please use the flag `--version=` in the pull command. >

---
### [4.0] Configuring the Chart values before installing

- Open the `values` file to make amendments as per requirements. 

#### [4.1] Adding the basic/required configurations
- Add the Harbour_ID, Ship_ID and Auth_token in the `values.yaml` file.  `harbour_id`, `ship_id` and `authtoken` are the one we aquired earlier see: [2.0](#20-generating-harbour_id-ship_id-and-auth_token-in-blazemeter)

```yaml
env: 
  # if you plan to pass the AUTH_TOKEN through secret in the crane ENV variables set secret to yes and add secret name and key
  secret_authtoken:
    enable: no
    secretName: "your-secretName"
    secretKey: "authtoken"
  authtoken:  "MY_SAMPLE_TOKEN-shfowh243owijoidh243o2nosIOIJONo2414"
  harbour_id: "MY_SAMPLE_HARBOURID"
  ship_id: "MY_SAMPLE_SHIPID"
```

- If user/admins require the AUTH_TOKEN for any crane installation to be secret/secure, the ENV values for AUTH_TOKEN can be inherited from the k8s secret. The user needs to make changes to `secret_authtoken` part of the `values` file. In that case, the `authtoken` value will be ignored. Make sure the cluster/namespace has the secret applied in the following format:

```YAML
apiVersion: v1
kind: Secret
metadata:
  name: <your-secretName>
  namespace: blazemeter
type: Opaque
data:
  authtoken: ZjIzZjU0ZTIwODk5ZWYwYzgzYmJkMzZmYzU3ODlhNzc3ODJjYTY1YjJjODIzZTMyMjY3NDcxM2QzZTc3Mzg2Yw==
```


#### [4.2] Configuring the default image settings
- User can configure the settings for image pull-policy, auto-update, etc. in the `image` values. If the `auto-update` is not a desired option, it can be set to `false`, which will disable the auto-update for crane and its components. Similarly, the `pull` policy can be changed to `Always` or `IfNotPresent` as per the requirement. If the cluster cache is configured to preserve the images for longer duration, changing the pull policy is desirable. 

*Note: Do not change the default Blazemeter registry, image or tag values here, use the `imageOverride` section to override the default settings.*

```yaml
image:   
  docker_registry: "gcr.io/verdant-bulwark-278"  #default registry for Blazemeter crane (DO NOT CHANGE)
  image: "gcr.io/verdant-bulwark-278/blazemeter/crane"  #default image for Blazemeter crane (DO NOT CHANGE)
  tag: "latest-master"
  auto_update: true                             
  auto_update_running_containers: false   #Controls auto update of components, default false. Also, either AUTO_UPDATE or AUTO_KUBERNETES_UPDATE must be true for this option to work, depending on the platform Crane is running on.
  pullPolicy: "Always"
```

#### [4.3] Configuring the image override settings

- User can override the default image settings by adding the `imageOverride` section in the `values.yaml` file by switching the `enable` to `yes`. Replace the `docker_registry` and `image` values with the custom registry and image path. Similarly, replace the path:`pathToYourRepo` with the custom image path and available version tag in your private repository. Please refer the commented example in the below snippet. Similary, if the `auto-update` is not a desired option, it can be set to `false`, which will disable the auto-update for crane and its components. Similarly, the `pull` policy can be changed to `Always` or `IfNotPresent` as per the requirement.

```yaml
imageOverride:
  enable: no
  #If imageOverride is enabled, also make sure to change/modify the docker_registry as well as image path below.
  docker_registry: "gcr.io/<custom-registry>"
  image: "gcr.io/<custom-registry>/blazemeter/crane"
  tag: "latest-master"
  auto_update: true
  auto_update_running_containers: false   #Controls auto update of components, default false. Also, either AUTO_UPDATE or AUTO_KUBERNETES_UPDATE must be true for this option to work, depending on the platform Crane is running on.
  # Example: {"blazemeter/crane:latest":"gcr.io/verdant-bulwark-278/blazemeter/crane:3.6.47"}
  images: {"taurus-cloud:latest": "pathToYourRepo/<image_name:version_number>", "torero:latest": "pathToYourRepo/<image_name:version_number>", "blazemeter/service-mock:latest": "pathToYourRepo/<image_name:version_number>", "blazemeter/mock-pc-service:latest": "pathToYourRepo/<image_name:version_number>", "blazemeter/sv-bridge:latest": "pathToYourRepo/<image_name:version_number>", "blazemeter/doduo:latest": "pathToYourRepo/<image_name:version_number>"}
  pullPolicy: "Always"
```


#### [4.4] Adding Proxy config details
- If the [proxy](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-agents-to-use-corporate-proxy.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____10#h_4a05699b-fb2d-4d9b-933d-11b5e3befaca) needs to be configured, change the value for `enable` to `yes`. Now, add the configuration for `http_proxy` or/and `https_proxy`. Make sure the values are set to `yes` before adding the proxy `path`, as shown below:

```yaml
proxy:
  enable: yes
  http_proxy: yes
  http_path: "http://server:port" 
  https_proxy: yes
  no_proxy: "kubernetes.default,127.0.0.1,localhost,myHostname.com"
```

#### [4.5] Adding CA certificates

- If user plan to configure the Kubernetes installation to use [CA certificates](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-kubernetes-agent-to-use-ca-bundle.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____12), make changes to the following section of the values.yaml file:
  -  Change the `enable` to `yes`
  -  Provide the path to the certificate file respectively for both (ca_subpath & aws_subpath). The best thing is to just copy/move these cert files in the same directory as this chart and just provide the name of the certs instead of the complete path.

```yaml
ca_bundle:
  enable: no
  ca_subpath: "certificate.crt"
  aws_subpath: "certificate.crt"
volume:
  volume_name: "volume-cm"
  mount_path: "/var/cm"
```

*This uses the same environment variables as CA_Bundle configration, therefore, either one can be used per deployment*

#### [4.6] Adding gridProxy configuration

- If you plan to configure your crane installation to use [gridProxy](https://help.blazemeter.com/docs/guide/functional-run-gridproxy-over-https.htm?Highlight=grid%20proxy), make changes to the following section of the `values.yaml` file. Grid Proxy enables you to run Selenium functional tests in BlazeMeter without using a local server. You can run Grid Proxy over the HTTPS protocol using the following methods:

```yaml
gridProxy:
  enable: yes
  a_environment: 'https://your.environment.net'
  tlsKeyGrid: "certificate.key"          # The private key for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format. 
  tlsCertGrid: "certificate.crt"         # The public certificate for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format.
  mount_path: "/etc/ssl/certs/doduo"
  doduoPort:  9070                       # The user-defined port where to run Doduo (BlazeMeter Grid Proxy). By default, Doduo listens on port 8000. 
  volume:
    volume_name: "tls-files"
    mount_path: "/etc/ssl/certs/doduo"
    readOnly: true
```
- TLS_CERT_GRID and TLS_KEY_GRID reference the file in the pod where the ConfigMap is mounted

*For functional test only. This uses the same environment variables as CA_Bundle configration, therefore, either one can be used per deployment*


#### [4.5] Deploying Non_priviledge container - NON_ROOT deployment. 
- If you plan to deploy the Blazemeter crane as a non_Priviledged installation, make changes to the following part of the `values` file. Change the `enable` to `yes` and this will automatically run the deployment and consecutive pods as Non_root/Non_priviledge. You can ammend the runAsGroup and runAsUser to any value of your choice. 

```YAML
non_privilege_container:
  enable: no
  runAsGroup: 1337
  runAsUser: 1337
```

*Non-root deployment requires an additional feature to be enabled at account level, please contact support for enabling this feature.*


#### [4.6] Installing Istio based crane for mock service deployment within the k8s cluster
- If this OPL/Private location is going to run mock services using istio-ingress, make changes to the following part of the `values` file. Change `enable` to `yes` and this will automatically setup istio-ingress for this crane deployment. This will allow outside traffic to access the service-virtualisation pod. However, make sure istio is already installed and configured as per the [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____6) 

```yaml
istio_ingress: 
  enable: no
  credentialName: "wildcard-credential"
  web_expose_subdomain: "mydomain.local"
  pre_pulling: "true" 
  istio_gateway_name: "bzm-gateway"
```
*You can either use istio-ingress or nginx-ingress for mock service deployment. However, you cannot use both at the same time.* 


#### [4.7] Installing Nginx Ingress-based crane for mock service deployment 
- If this OPL/Private location is going to run mock services using nginx-ingress, make changes to following part of the `values` file. Change the `enable` to `yes` and this will automatically set up nginx-ingress for this installation, which will allow outside traffic to access the mock-service pod. However, make sure nginx is already installed and configured. [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____6)

```yaml
nginx_ingress:
  enable: yes
  credentialName: "wildcard-credential"
  web_expose_subdomain: "mydomain.local" 
```

*You can either use istio-ingress or nginx-ingress for mock service deployment. However, you cannot use both at the same time.* 


#### [4.9] Configure deployment to support child pods to inherit labels from the crane

- If users/admins require a certain set of labels as part of the deployment of a cluster resource, we can use these `labels` values. These labels will be Inherited from the crane when the child pods are deployed. Because, note that labels added to crane deployment will not be automatically inherited by the child pods. Switch the `enable` to `yes` and add labels in a JSON format as per the example:
```yaml
labels:
  enable: yes 
  labelsJson: {"label_1": "label_1_value", "label_2": "label2value"}
```

#### [4.12] Configure deployment to support node selectors and tolerations 

- The configuration is used to specify the tolerations & nodeselector labels. The crane container will pass these tolerations and node selector elements to child containers when they are deployed. Switch the `enable` to `yes` and add tolerations & nodeselector labels in a Json format as per the example:
```yaml
toleration: 
  enable: yes
  syntax: [{ "effect": "NoSchedule", "key": "lifecycle", "operator": "Equal", "value": "spot" }]

nodeSelector:
  enable: yes
  syntax:  {"label_1": "label_1_value", "label_2": "label_2_value"}
```


#### [4.10] Configure resources limits and requests for the crane & child resources.

- If user/admins require a CPU, or MEM limit or requests to be applied to crane and its child resources, we can use this `craneResources` or `executorResources` value. These values will be applied to crane resource section, as well as will be Inherited by the child pods. You can either use one of them or both. Switch the `enable` to `yes` and add resource limits/requests in a string format as per the example:

```yaml
# CPU & Memory limits & requests for resources for crane deployment. 
craneResources: 
  requests:           # The request resources are enabled by default for efficient agent functions. 
    enable: yes
    CPU: 256m
    MEM: 1024Mi 
  limits:
    enable: no
    CPU: 1
    MEM: 2Gi

# CPU & Memory limits & requests for resources created by agent.
executorResources: 
  requests:           # The request resources are enabled by default for efficient agent functions. 
    enable: yes 
    CPU: 1000m
    MEM: 4096         # This value should be an integer unlike other values that supports k8s standard for declaring resource limits/requests.
  limits:
    enable: no
    CPU: 2
    MEM: 8Gi
```


#### [4.11] Configure deployment to implement ephemeral storage request/limit for the child pods

- If the admin require to setup an ephemeral storage request/limit for the child pods, we can use this `ephemeralStorage` value. The values are in Mi. Switch the `enable` to `yes` and add the values in a string format as per the example:
```yaml
ephemeralStorage:
  enable: no
  limits: 1024         # The values are in Mi
  requests: 100       # Default: 100 (Mi). 
```


#### [5.0] Verify if everything is setup correctly

- Once the values are updated, please verify if the values are correctly used in the helm chart:

```
helm lint <path-to-chart>
helm template <path-to-chart>
```

This will print the template Helm will use to install this chart. Check the values and if something is missing, please make ammends.

### [6.0] Installing the chart

- Install the helm chart
```
helm install crane /path/to/chart --namespace <namespace>
```
**Here, crane is the name we are setting for the chart on our system. Make sure the namespace is declared here.**


### [7.0] Varify the chart installation

- To varify the installation of our Helm chart run:
```
helm list -n <namespace>
```


## [8.0] Recommendations

It is recommended to install this Helm chart onto the auto-scalable cluster for example - [EKS](https://aws.amazon.com/eks/), [GKE](https://cloud.google.com/kubernetes-engine) or [AKS](https://azure.microsoft.com/en-in/products/kubernetes-service/#:~:text=Azure%20Kubernetes%20Service%20(AKS)%20offers,edge%2C%20and%20multicloud%20Kubernetes%20clusters.). 

However, make sure you are scaling the nodes, as it is not recommended to go with EKS Fargate or GKE Autopilot, those types of autoscaling are not supported for Blazemeter crane deployments. 

Therefore, ***always go with Node autoscaling***

## [9.0] Changelog:

- 1.2.3 - Chart can work with resource requests & limits, similarly the ephemeral storage requests & limits can be configured.
- 1.2.2 - Chart now supports gridProxy deployment configurations
- 1.2.1 - Chart now supports node selectors and tolerations
- 1.2.0 - Chart now supports service virtualisation deployment using nginx-ingress
- 1.1.0 - Chart now supports inheriting labels and resourcelimits to child pods from crane environment
- 1.0.1 - The AUTH_TOKEN can now be inherited from a secret
- 1.0.0 - Now supports service virtualisation deployment using istio-ingress
- 0.1.3 - Supports configuration for non_proviledge container deployment, also added a license
- 0.1.2 - Supports Proxy, CA_certs as an additional configuration of Blazemeter crane deployment
- 0.1.1 - Support proxy as an additional configurable aspect of Blazemeter crane deployment 
- 0.1.0 - Supports standard - vanilla Blazemeter crane deployment (no proxy or CA_Bundle configurable)
