## Creating a SuperCluster

### Tested with (Open MPI) version 5.0.2 - In MacOS, Kali Linux, and ArchLinux

https://docs.open-mpi.org/en/main/getting-help.html

https://www-lb.open-mpi.org/software/ompi/

https://github.com/open-mpi/ompi
#
#

#### Project Overview:
The project aims to automate CyberSecurity processes.

Leveraging popular security tools like Metasploit, Nmap, Shodan, Maltego, BurpSuite, and others, employing techniques such as port scanning, vulnerability search, exploitation, reporting, and ticket generation.

#### Implementation Strategy:

Utilizes a CI/CD pipeline and GitHub deployment through a SuperCluster.
Employs crawling and fuzzing techniques to enhance solution scope, identifying vulnerabilities across various operating systems and IoT / OT devices.

#### Business Model:

Proposes a sales model, projecting long-term income by offering the solution as a service to organizations.
Initial costs involve hiring developers and security experts, with simulations indicating feasibility.

#### Automation for Efficiency:
This solution enhances computer security efficiency by automating vulnerability detection and resolution for swift response.

Creating a Small Cluster:
For a basic cluster using five devices:

1. Choose a suitable OS (e.g., Linux) and install it on all devices.

2. Install cluster computing software like OpenMPI or MPICH.

3. Configure network settings for communication.

4. Set up SSH for remote access and control.

5. Configure the cluster using a hostfile containing device IPs and processor details.

6. Configure the cluster to execute the following command to create a hostfile: that contains the IP addresses of each device and the number of processors available on each device.

```
nano hostfile
```

Then, add the IP addresses of each device and the number of processors available on each device, like this:

```
192.168.1.1 slots=2
192.168.1.2 slots=2
192.168.1.3 slots=1
192.168.1.4 slots=1
192.168.1.5 slots=1
```

7. Test the cluster: Test the cluster by running some simple parallel applications, such as calculating the value of pi with Python. For example, type the following command to calculate the value of pi using 4 processors, and also all the available processors:

```
clear && nano pi_value.py
```

```python
from mpi4py import MPI
import os
import subprocess

def pi_leibniz(n):
    result = 0.0
    for i in range(n):
        if i % 2 == 0:
            result += 4.0 / (2 * i + 1)
        else:
            result -= 4.0 / (2 * i + 1)
    return result

try:
    # Guess MPI_HOME by finding the location of mpirun
    mpi_location = subprocess.check_output(['which', 'mpirun'], universal_newlines=True).strip()
    mpi_home = os.path.dirname(os.path.dirname(mpi_location))

    # Print MPI_HOME for debugging
    print(f"MPI_HOME: {mpi_home}")

    # Set MPI environment variables
    os.environ['PATH'] = f"{mpi_home}/bin:{os.environ.get('PATH', '')}"
    os.environ['LD_LIBRARY_PATH'] = f"{mpi_home}/lib:{os.environ.get('LD_LIBRARY_PATH', '')}"

    # Print paths for debugging
    print(f"PATH: {os.environ['PATH']}")
    print(f"LD_LIBRARY_PATH: {os.environ['LD_LIBRARY_PATH']}")

    # Check if the MPI_HOME path is correct
    if not os.path.exists(os.path.join(mpi_home, 'bin', 'mpirun')):
        raise FileNotFoundError(f"mpirun not found in {mpi_home}/bin. Check MPI installation.")

    # Initialize MPI
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()

    # Debugging output to see the rank of each process
    print(f"Process {rank}: MPI Initialized")

    # Calculate pi with 10000 terms
    pi_approx = pi_leibniz(10000)

    # Debugging output to see the rank and the result from each process
    print(f"Process {rank}: Pi approximation (Leibniz, 10000 terms): {pi_approx:.10f}")

except Exception as e:
    # Print the exception and traceback for detailed debugging
    import traceback
    print(f"An error occurred: {e}")
    traceback.print_exc()

finally:
    # Finalize MPI
    MPI.Finalize()
```

```
clear && chmod +x pi_value.py && python3 -m pip install --upgrade pip && pip install mpi4py 
```
```
mpirun -v --hostfile hostfile -np 4 python ./pi_value.py
```
```
mpirun -v --hostfile hostfile --mca btl tcp,self -x DISPLAY=localhost:0 python ./pi_value.py
```
```
mpirun -v --use-hwthread-cpus python ./pi_value.py
```

You can also compile and run your own parallel applications using OpenMPI.

You can also test locally in Linux or MacOS by running
```
mpirun -v -np 4 python ./pi_value.py 
```

That's it! You have now created Your own SuperCluster and it's working like a charm.

## SuperCluster Documentation

### Architecture
┌─────────────────────────────────────────────┐
│ Master Node                                 │
│ • MPI Rank 0                                │
│ • Job Scheduler                             │
│ • Results Aggregator                        │
│ • Web Dashboard                             │
└───────────────┬─────────────────────────────┘
                │
     ┌──────────┴───────────┐
     ▼                      ▼
┌─────────┐           ┌─────────┐
│ Worker 1│           │ Worker N│
│ Rank 1  │ ...       │ Rank N  │
└─────────┘           └─────────┘

text

### Quick Start
1. Run quick setup: `./quick_setup.sh`
2. Start monitoring: `python monitor_cluster.py`
3. Run security scan: `./scan_network.sh 192.168.1.0/24`

### Performance Tips
- Use `--mca btl tcp,self` for better network performance
- Adjust slot counts in hostfile based on CPU cores
- Enable process affinity for CPU-intensive tasks

### Key Improvements Made
- Automation: Added bootstrap and setup scripts
- Monitoring: Implemented real-time cluster monitoring dashboard
- Security Integration: Added distributed security scanner framework
- Benchmarking: Enhanced performance measurement tools
- CI/CD: Added GitHub Actions workflow for automated testing
- Containerization: Docker setup for easy deployment
- Documentation: Improved structure and quick start guides
- Optimization: MPI environment tuning for better performance
- Scalability: Dynamic hostfile generation and resource allocation
- Error Handling: Better exception handling and logging