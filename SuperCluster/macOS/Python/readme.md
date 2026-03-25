# Upgrade Pip Script only for MacOS

## Overview

This script is designed to upgrade all installed Python Pip packages, using MPI (Message Passing Interface) for parallel processing. It includes functionality to install missing type stubs and upgrade a specific Python Pip package, across multiple CPUs.

## Requirements

Install Python 3.x & MPI (Message Passing Interface) accordingly to Your operating system, following this wiki page: https://github.com/4k4xs4pH1r3/offensive-security/tree/master/SuperCluster

## To upgrade Python Pip packages using MPI, execute the following command

```bash
chmod +x ./upgradepip.py && mpirun -v --use-hwthread-cpus python ./upgradepip.py
```
