# Implementation README
This repository is for the case-study of my master's thesis "A Lightweight Experimental Approach to Measure the Antifragility of Cloud-based Systems".
## Structure

- [Setup_Notes.md](./Setup_Notes.md): Notes on how to setup the experimental environment and helpful commands within kubectl, helm and litmus
- [Processing_Pipeline](./Processing_Pipeline): 
  - Jupyter Notebook [Processing_Pipeline.ipynb](./Processing_Pipeline/Processing_Pipeline.ipynb) used for calculating the antifragility score for the bank of anthos.
  - increase_load_*.txt: Log Output from [Increase Load Experiment](./Chaos%20Scenarios/10%20Trials%20Experiments/increase_load.sh) (used to extract timestamps)
  - perform_update_*.txt: Log Output from [Perform Update Experiment](./Chaos%20Scenarios/10%20Trials%20Experiments/perform_update.sh) (used to extract timestamps)
  - experiments_*.csv: Contain meta information for the litmus chaos experiments
  - inbound_traffic_*.csv: POST /login outbound latency within 2000ms
  - outbound_traffic_*.csv: POST /login inbound latency within 2000ms
  - login_requests_*.csv: POST /login requests within 2000ms latency and overall POST /login requests
  - slo_*.csv: "Service Level Objectives", percentage of requests within predefined latency
  - *.pdf and *.svg: Exported Graphs from the Jupyter Notebook
- [Chaos Scenarios](./Chaos%20Scenarios/): 
  - Litmus Experiments
  - [10 Trials Experiment](./Chaos%20Scenarios/10%20Trials%20Experiments/): Experiments that were actually executed and analyzed for the case study 
- [Experiment Results](./Experiment%20Results/):
  - Results of the Experiments
- [Prometheus](./prometheus/): Dashboards for Grafana
- [linkerd](./linkerd/): cluser certificates
- [bank-of-anthos](./bank-of-anthos/): Cloned repo of [Google's Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos), but not modified
- [litmus](./litmus/): litmus helm chart, but not modified
