# Implementation README

- Tooling:
Gitops:
  - ArgoCD?
Observability:
  - Prometheus
  - Elastic Search/Logstash/Kibana oder fluentd
Chaos:  
  - Litmus
Service Mesh:
  - Linkerd/Istio?
Application:
  - Bank of Anthos

## Lokales Windows Setup

1. Ubuntu on windows
    1. Install zsh (sudo apt-get install zsh)
    2. Install oh-my-zsh (sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
    3. Install brew https://docs.brew.sh/Homebrew-on-Linux
    4. Install kubectx `brew install kubectx`
    5. Install kube-ps1 plugin
    6. `vim .zshrc`
        ```
        export ZSH="$HOME/.oh-my-zsh"

        ZSH_THEME="robbyrussell"

        plugins=(git kubectl kube-ps1 kubectx)

        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

        autoload -Uz compinit && compinit

        source $ZSH/oh-my-zsh.sh

        PROMPT='$(kube_ps1)'$PROMPT

        alias kns="kubens"
        alias kctx="kubectx"
        ```

2. Install WSL2
3. Install Docker Desktop
4. Install minikube
5. Copy kubectl config in ubuntu on windows
    ```
    kubectl config view --context=minikube
    ```
6. Change paths
  ```
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority: /mnt/c/Users/Rubi/.minikube/ca.crt 
      extensions:
      - extension:
          last-update: Thu, 27 Apr 2023 17:29:01 CEST
          provider: minikube.sigs.k8s.io
          version: v1.30.1
        name: cluster_info
      server: https://127.0.0.1:64151
    name: minikube
  contexts:
  - context:
      cluster: minikube
      extensions:
      - extension:
          last-update: Thu, 27 Apr 2023 17:29:01 CEST
          provider: minikube.sigs.k8s.io
          version: v1.30.1
        name: context_info
      namespace: default
      user: minikube
    name: minikube
  current-context: minikube
  kind: Config
  preferences: {}
  users:
  - name: minikube
    user:
      client-certificate: /mnt/c/Users/Rubi/.minikube/profiles/minikube/client.crt 
      client-key: /mnt/c/Users/Rubi/.minikube/profiles/minikube/client.key 
  ```
7.  `minikube mount D:\minikube:/data/pv-storage` (funktioniert nicht mit mongodb)
8. Install argocd
    ```
    helm repo add argo https://argoproj.github.io/argo-helm
    helm install --namespace argocd argo argo/argo-cd
    ```
9. Add repository to argocd
10. Create app-of-apps:
    ```
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: 'app-of-apps'
    spec:
      project: default
      source:
        repoURL: 'https://github.com/Feederhigh5/master-thesis-gitops.git'
        path: .
        targetRevision: main
      destination:
        server: 'https://kubernetes.default.svc'
      syncPolicy:
        automated:
          prune: true
    ```

## Helm related

### search helm charts from repo
```
helm search repo prometheus-community/prometheus
```

### Inspect helm templates from repo

```
helm template repo grafana/grafana | code -
```

### Show values from repo helm chart

```
helm show values grafana/grafana | code - 
```


## Litmus Realted
### Create Workflow via GraphQL

```
mutation createChaosWorkflow($chaosWorkflowRequest: ChaosWorkFlowRequest!) {
  createChaosWorkFlow(request: $chaosWorkflowRequest) {
    workflowID
    workflowName
    isCustomWorkflow
    workflowDescription
  }
}
```

Query Variable:
```
{
  "chaosWorkflowRequest": {
    "workflowName": "Test",
    "workflowManifest": "{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"Workflow\",\"metadata\":{\"generateName\":\"argowf-chaos-bank-of-anthos-resiliency-\",\"namespace\":\"litmus\",\"labels\":{\"subject\":\"{{workflow.parameters.appNamespace}}_bank-of-anthos\"}},\"spec\":{\"entrypoint\":\"argowf-chaos\",\"serviceAccountName\":\"argo-chaos\",\"securityContext\":{\"runAsUser\":1000,\"runAsNonRoot\":true},\"arguments\":{\"parameters\":[{\"name\":\"adminModeNamespace\",\"value\":\"litmus\"},{\"name\":\"appNamespace\",\"value\":\"bank\"}]},\"templates\":[{\"name\":\"argowf-chaos\",\"steps\":[[{\"name\":\"install-application\",\"template\":\"install-application\"}],[{\"name\":\"install-chaos-experiments\",\"template\":\"install-chaos-experiments\"}],[{\"name\":\"pod-network-loss\",\"template\":\"pod-network-loss\"}],[{\"name\":\"revert-chaos\",\"template\":\"revert-chaos\"}],[{\"name\":\"delete-application\",\"template\":\"delete-application\"}]]},{\"name\":\"install-application\",\"container\":{\"image\":\"litmuschaos/litmus-app-deployer:latest\",\"args\":[\"-namespace=bank\",\"-typeName=resilient\",\"-operation=apply\",\"-timeout=400\",\"-app=bank-of-anthos\",\"-scope=cluster\"]}},{\"name\":\"install-chaos-experiments\",\"container\":{\"image\":\"litmuschaos/k8s:latest\",\"command\":[\"sh\",\"-c\"],\"args\":[\"kubectl apply -f https://hub.litmuschaos.io/api/chaos/master?file=charts/generic/experiments.yaml -n {{workflow.parameters.adminModeNamespace}} ; sleep 30\"]}},{\"name\":\"pod-network-loss\",\"inputs\":{\"artifacts\":[{\"name\":\"pod-network-loss\",\"path\":\"/tmp/chaosengine.yaml\",\"raw\":{\"data\":\"apiVersion: litmuschaos.io/v1alpha1\nkind: ChaosEngine\nmetadata:\n  generateName: pod-network-loss-chaos\n  namespace: {{workflow.parameters.adminModeNamespace}}\n  labels:\n    context: \"{{workflow.parameters.appNamespace}}_bank-of-anthos\"\n    workflow_run_id: \"{{workflow.uid}}\"\nspec:\n  appinfo:\n    appns: \"bank\"\n    applabel: name in (balancereader,transactionhistory)\n    appkind: \"deployment\"\n  jobCleanUpPolicy: retain\n  engineState: \"active\"\n  chaosServiceAccount: litmus-admin\n  components:\n    runner:\n      imagePullPolicy: Always\n  experiments:\n    - name: pod-network-loss\n      spec:\n        probe:\n          - name: check-frontend-access-url\n            type: httpProbe\n            httpProbe/inputs:\n              url: http://frontend.bank.svc.cluster.local:80\n              responseTimeout: 100\n              method:\n                get:\n                  criteria: ==\n                  responseCode: \"200\"\n            mode: Continuous\n            runProperties:\n              probeTimeout: 2\n              interval: 1\n              retry: 2\n        components:\n          env:\n            - name: TOTAL_CHAOS_DURATION\n              value: \"90\"\n            - name: NETWORK_INTERFACE\n              value: \"eth0\"\n            - name: NETWORK_PACKET_LOSS_PERCENTAGE\n              value: \"100\"\n            - name: CONTAINER_RUNTIME\n              value: \"docker\"\n            - name: SOCKET_PATH\n              value: \"/var/run/docker.sock\"\n\"}}]},\"container\":{\"name\":\"\",\"image\":\"litmuschaos/litmus-checker:latest\",\"args\":[\"-file=/tmp/chaosengine.yaml\",\"-saveName=/tmp/engine-name\"],\"resources\":{}}},{\"name\":\"delete-application\",\"container\":{\"image\":\"litmuschaos/litmus-app-deployer:latest\",\"args\":[\"-namespace=bank\",\"-typeName=resilient\",\"-operation=delete\",\"-app=bank-of-anthos\"]}},{\"name\":\"revert-chaos\",\"container\":{\"image\":\"litmuschaos/k8s:latest\",\"command\":[\"sh\",\"-c\"],\"args\":[\"kubectl delete chaosengine -l workflow_run_id={{workflow.uid}} -n {{workflow.parameters.adminModeNamespace}}\"]}}]}}",
    "projectID": "a8113699-50f2-463e-b340-0223a59f6f6f",
    "isCustomWorkflow": true,
    "clusterID": "934286c9-b729-4581-92a3-b75e5a29b62f",
    "cronSyntax": "- - - - -",
    "workflowDescription": "testing",
    "weightages": [{
      "experimentName": "pod-network-loss",
      "weightage": 5
    }
    ]
  }
}
```


### Manually create one liner JSON

1. Convert yaml to json
    ```
    yq chaos-workflow.yml -o json | jq '.' > chaos-workflow2.json?
    ```
2. Convert json to oneline
    ```
    jq -c . < chaos-workflow2.json > output2.json      
    ```
3. Correct quotation marks
    **replace "** `(?<!\\)"` with `\"`

### Delete completed pods
```
kdelp -n litmus --field-selector=status.phase==Succeeded 
```

### GraphQL list workflows

```
# Write your query or mutation here
query listWorkflows($workflowInput: ListWorkflowsRequest!){
  listWorkflows(request: $workflowInput){
    totalNoOfWorkflows
  }
}
```

**Query Variables**

```
{
  "workflowInput": {
    "projectID": "a8113699-50f2-463e-b340-0223a59f6f6f"
  }
}
```

### GraphQL list clusters
```
query {
  listClusters(projectID: "a8113699-50f2-463e-b340-0223a59f6f6f") {
    clusterID
  }
}
```