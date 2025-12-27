## SuperCluster Guide

Tested with Open MPI 5.0.2 on macOS, Kali Linux, and Arch Linux. This project automates cybersecurity workflows (scanning, exploitation, reporting) using distributed compute. Use the steps below to stand up, validate, and tune the cluster.

### What’s Included

- Bootstrap helpers: `bootstrap_cluster.sh`, `quick_setup.sh`
- Benchmarks and samples: `benchmark_pi.py` (Pi estimate), `optimized_mpi_settings.sh`
- Ops tools: `monitor_cluster.py` (Flask dashboard), `security_scanner.py` (distributed scan)
- Docker: `docker-compose-cluster.yml` for containerized experiments
- Reference workflow: `pentesting.md`

### Installation

- Follow platform setup in `ArchLinux/readme.md`, `Kali/readme.md`, and `macOS/readme.md` for OS packages and service enablement.
- Return here after OS prep to configure hostfiles, run MPI jobs, and use the monitoring/scanning tools.

### Architecture at a Glance

- Single master (MPI rank 0) schedules jobs, aggregates results, and can host the dashboard.
- Workers execute scans or compute tasks; all nodes share SSH trust and a common `hostfile`.
- Typical hostfile for five nodes:
  ```
  192.168.1.1 slots=4 max_slots=8   # master
  192.168.1.2 slots=2 max_slots=4
  192.168.1.3 slots=2 max_slots=4
  192.168.1.4 slots=1 max_slots=2
  192.168.1.5 slots=1 max_slots=2
  ```

### Prerequisites

- Python 3.11+, Open MPI (or vendor package), SSH enabled.
- Python deps after OS setup: `pip3 install mpi4py python-nmap flask psutil requests pandas`
- Harden SSH keys across nodes (`ssh-keygen` + `ssh-copy-id`) before running multi-node jobs.

### Quick Setup (Automated)

1. Run the guided installer:  
   `chmod +x quick_setup.sh && ./quick_setup.sh`
2. Edit the generated `hostfile` to match your IPs/slots.
3. Smoke-test MPI:  
   `mpirun --hostfile hostfile -np 2 python - <<'PY'\nfrom mpi4py import MPI; c=MPI.COMM_WORLD; print(f'hello {c.Get_rank()}/{c.Get_size()}')\nPY`

### Manual Bootstrap

- Generate a hostfile and install Open MPI from source: `chmod +x bootstrap_cluster.sh && ./bootstrap_cluster.sh`
- To add/remove nodes later, update `hostfile` and re-sync SSH keys.

### Run a Pi Benchmark

Validate parallel execution end-to-end:

```
mpirun --hostfile hostfile -np 4 python benchmark_pi.py
```

Local-only: `mpirun -np 4 python benchmark_pi.py`

### Monitoring, Security, and Cyber Ops

- Dashboard: `FLASK_APP=monitor_cluster.py flask run --host 0.0.0.0 --port 5000` then open `/` for status; `/api/metrics` returns JSON.
- Distributed scan: `mpirun --hostfile hostfile -np <workers> python security_scanner.py 192.168.1.0/24`
- Extend workloads with your tooling (e.g., Nmap, Metasploit modules) by wrapping them in MPI-driven scripts; log results on the master for reporting/ticketing.

### Performance Tips

- If no InfiniBand, use `--mca btl tcp,self`; tune slots per node to core/NUMA layout.
- Pin processes when CPU-bound: `mpirun --bind-to core --map-by socket ...`
- Rebuild or adjust the `hostfile` after topology changes; keep SSH trust in sync.

### Further Reading

- Open MPI docs: https://docs.open-mpi.org/en/main/getting-help.html
- Source releases: https://github.com/open-mpi/ompi
