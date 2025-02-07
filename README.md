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

- Open the `values` file to make amendments as per requirements 
``` 
vi values.yaml
```

#### [4.1] Adding the basic/required configurations
- Add the Harbour_ID, Ship_ID and Auth_token in the `values.yaml` file.  `Harbour_ID`, `Ship_ID` and `authtoken` is the one we aquired before see[2.1]. 

```yaml
env:
  authtoken: "[auth-token]"
  harbour_id: "[harbour-id]"
  ship_id: "[ship-id]"
```

#### [4.2] Adding Proxy config details
- If the [proxy](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-agents-to-use-corporate-proxy.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____10#h_4a05699b-fb2d-4d9b-933d-11b5e3befaca) needs to be configured, change the value for `enable` to `yes`. Now, add the configuration for `http_proxy` or/and `https_proxy`. Make sure the values are set to `yes` before adding the proxy `path`, as shown below:

```yaml
proxy:
  enable: yes
  http_proxy: yes
  http_path: "http://server:port" 
  https_proxy: yes
  no_proxy: "kubernetes.default,127.0.0.1,localhost,myHostname.com"
```

#### [4.3] Adding CA certificates
- Now, if you want to configure your Kubernetes installation to use [CA certificates](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-kubernetes-agent-to-use-ca-bundle.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____12), make changes to this section of the values.yaml file:
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

#### [4.4] Additional basic configurations
- Please avoid switching the `serviceAccount.create`  to `yes`, as serviceAccount other than `default` will cause issues with Blazemeter crane deployments. Though I have set up a code that will successfully create a new serviceAccount and assign it to all resources in this Helm chart, this is something we need to avoid for now. 

- Change `auto_update: false` if you do not want the cluster to be [auto-updated](https://help.blazemeter.com/docs/guide/private-locations-how-to-enable-auto-upgrade-for-running-containers.html?tocpath=Private%20Locations%7CPrivate%20Locations%20Knowledge%20Base%7C_____3) (Not recommended though).
```yaml
  auto_update: "'true'"
```

- Lastly, you can name the namespace for this deployment, just add the name in `namespace`, and this helm chart will be installed under that namespace. Leave it to default for no specific namespace, the chart will be installed in the `default` namespace.
```yaml
deployment:
  name: crane
  namespace: "default"
```
#### [4.5] Deploying Non_provoledge container - NON_ROOT deployment. 
- If you plan to deploy the Blazemeter crane as a non_Priviledged installation, make changes to this part of the `values` file.
```YAML
non_privilege_container:
  enable: no
  runAsGroup: 1337
  runAsUser: 1337
```
Change the `enable` to `yes` and this will automatically run the deployment and consecutive pods as Non_root/Non_priviledge.

#### [4.6] Installing Istio based crane for mock service deployment within the k8s cluster
- If this OPL/Private location is going to run mock services using istio-ingress, make changes to this part of the `values` file.
```yaml
istio_ingress: 
  enable: no
  credentialName: "wildcard-credential"
  web_expose_subdomain: "mydomain.local"
  pre_pulling: "true" 
  istio_gateway_name: "bzm-gateway"
```
Change the `enable` to `yes` and this will automatically setup istio-ingress for this installation. Which will allow outside traffic to access the mock-service pod. However, make sure istio is already installed and configured as per the [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____6) 

#### [4.7] Installing Nginx Ingress-based crane for mock service deployment 
- If this OPL/Private location is going to run mock services using nginx-ingress, make changes to this part of the `values` file.
```yaml
nginx_ingress:
  enable: yes
  credentialName: "wildcard-credential"
  web_expose_subdomain: "mydomain.local" 
```
Change the `enable` to `yes` and this will automatically set up nginx-ingress for this installation, which will allow outside traffic to access the mock-service pod. However, make sure nginx is already installed and configured. [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____6)

#### [4.8] Inheriting the AUTH_TOKEN for crane from your k8s secret
- If user/admins require the AUTH_TOKEN for any crane installation to be secret/secure, the ENV values for AUTH_TOKEN can be inherited from the k8s secret. The user needs to make changes to this part of the `values` file.
```yaml
env:
  authToken: 
    # if you want to pass the AUTH_TOKEN through secret in the crane ENV variables set secret to yes and add secret name and key
    secret:
      enable: yes
      secretName: "your-secretName"
      secretKey: "auth-token"
    # if secret is not enabled, please enter the AUTH_TOKEN below directly. 
    token:  "MY_SAMPLE_TOKEN-shfowh243owijoidh243o2nosIOIJONo2414"
```
Change the `enable` to `yes` and this will automatically inherit the AUTH_TOKEN values from the secret user provided in the following values. Make sure the cluster/namespace has the secret applied in the following format:
```YAML
apiVersion: v1
kind: Secret
metadata:
  name: your-secretName
  namespace: blazemeter
type: Opaque
data:
  auth-token: ZjIzZjU0ZTIwODk5ZWYwYzgzYmJkMzZmYzU3ODlhNzc3ODJjYTY1YjJjODIzZTMyMjY3NDcxM2QzZTc3Mzg2Yw==
```

#### [4.9] Configure deployment to support child pods to inherit labels from the crane
- If users/admins require a certain set of labels as part of the deployment of a cluster resource, we can use these `labels` values. These labels will be Inherited from the crane when the child pods are deployed. Because, note that labels added to crane deployment will not be automatically inherited by the child pods. Switch the `enable` to `yes` and add labels in a JSON format as per the example:
```yaml
labels:
  enable: yes 
  labelsJson: {"label_1": "label_1_value", "label_2": "label2value"}
```

#### [4.10] Configure deployment to implement child pods to inherit resource limits from the crane
- If user/admins require a CPU, or MEM limit or requests to be applied to all cluster resources, we can use this `resources` value. These resource limits/requests will be Inherited from the crane ENV when the child pods are deployed. Note that resource limits/requests added to crane deployment will not be automatically inherited by the child pods. You can either use one of them or both. Switch the `enable` to `yes` and add resource limits/requests in a string format as per the example:
```yaml
resources: 
  limits:
    enable: no
    CPU: 2
    MEM: 8Gi
  requests:           # The request resources are enabled by default for efficient agent functions. 
    enable: yes 
    CPU: 1000m
    MEM: 4096 
```
#### [4.11] Configure deployment to implement ephemeral storage request/limit for the child pods
- If the admin require to setup an ephemeral storage request/limit for the child pods, we can use this `ephemeralStorage` value. The values are in Mi. Switch the `enable` to `yes` and add the values in a string format as per the example:
```yaml
ephemeralStorage:
  enable: no
  limits: 1024         # The values are in Mi
  requests: 100       # Default: 100 (Mi). 
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

#### [4.13] Configure deployment to support gridProxy functionality
Switch the `enable` to `yes` and add the details below to use the gridProxy functionality.

- DuduoPort is the user-defined port where to run Doduo (BlazeMeter Grid Proxy). By default, Doduo listens on port 8000. 
- `tslCertGrid` is the public certificate for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format.
- `tlsKeyGrid` is the private key for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format.`

```yaml
gridProxy:
  enable: no
  doduoPort:  9070    
  tlsCertGrid: wdfrg 
  tlsKeyGrid: sefgwg  
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
helm install crane helm-crane
```
Here, crane is the name we are setting for the chart on our system and helm-crane is the actual name of the chart. Make sure the namespace is declared here if you plan to install the chart in a different namespace than `default` i.e. the same as the one we declared in the values file [see 4.4 section].
You can use the namespace with `-n` flag similar to `kubectl` flag. 

### [7.0] Varify the chart installation

- To varify the installation of our Helm chart run:
```
helm list -A
```

## [8.0] Recommendations

It is recommended to install this Helm chart onto the auto-scalable cluster for example - [EKS](https://aws.amazon.com/eks/), [GKE](https://cloud.google.com/kubernetes-engine) or [AKS](https://azure.microsoft.com/en-in/products/kubernetes-service/#:~:text=Azure%20Kubernetes%20Service%20(AKS)%20offers,edge%2C%20and%20multicloud%20Kubernetes%20clusters.). 

However, make sure you are scaling the nodes, as it is not recommended to go with EKS Fargate or GKE Autopilot, those types of autoscaling are not supported for Blazemeter crane deployments. 

Therefore, ***always go with Node autoscaling***

## [9.0] Changelog:

- 1.2.3 - Chart can work with resource requests & limits, similarly the ephemeral storage requests & limits can be configured.[4.10](#410-configure-deployment-to-implement-child-pods-to-inherit-resource-limits-from-the-crane) [4.11](#411-configure-deployment-to-implement-ephemeral-storage-requestlimit-for-the-child-pods)
- 1.2.2 - Chart now supports gridProxy deployment configurations see: [4.13](#413-configure-deployment-to-support-gridproxy-functionality)
- 1.2.1 - Chart now supports node selectors and tolerations see: [4.12](#412-configure-deployment-to-support-node-selectors-and-tolerations)
- 1.2.0 - Chart now supports service virtualisation deployment using nginx-ingress [4.7](#47-installing-nginx-ingress-based-crane-for-mock-service-deployment)
- 1.1.0 - Chart now supports inheriting labels and resourcelimits to child pods from crane environment [4.9](#49-configure-deployment-to-support-child-pods-to-inherit-labels-from-the-crane) & [4.10](#410-configure-deployment-to-support-child-pods-to-inherit-resource-limits-from-the-crane)
- 1.0.1 - The AUTH_TOKEN can now be inherited from a secret [4.8](#48-inheriting-the-auth_token-for-crane-from-your-k8s-secret)
- 1.0.0 - Now supports service virtualisation deployment using istio-ingress [4.6](#46-installing-istio-based-crane-for-mock-service-deployment-within-the-k8s-cluster)
- 0.1.3 - Supports configuration for non_proviledge container deployment, also added a license [4.5](#46-installing-istio-based-crane-for-mock-service-deployment-within-the-k8s-cluster)
- 0.1.2 - Supports Proxy, CA_certs as an additional configuration of Blazemeter crane deployment [4.3](#43-adding-ca-certificates)
- 0.1.1 - Support proxy as an additional configurable aspect of Blazemeter crane deployment [4.2](#42-adding-proxy-config-details)
- 0.1.0 - Supports standard - vanilla Blazemeter crane deployment (no proxy or CA_Bundle configurable)
