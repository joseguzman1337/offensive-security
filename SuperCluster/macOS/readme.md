### Tested with mpirun (Open MPI) 5.0.2

To install OpenMPI on macOS, you can use the Homebrew package manager. Homebrew simplifies the process of installing various software packages on macOS. Here are the steps to install OpenMPI using Homebrew:

### Step 1: Install Homebrew (if not already installed)

If you don't have Homebrew installed, you can install it by following the instructions on the Homebrew website: [https://brew.sh/](https://brew.sh/)

### Step 2: Install OpenMPI

Open a terminal and run the following commands:

```bash
# Update Homebrew to make sure you have the latest formulae
brew update

# Install OpenMPI
brew install open-mpi && sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist && sudo launchctl list | grep ssh

# Python dependencies for repo tools
python3 -m pip install --upgrade pip && pip install mpi4py python-nmap flask psutil requests pandas
```

### Step 3: Verify the installation

After the installation is complete, you can verify it by checking the OpenMPI version:

```bash
mpirun --version
```

This command should display the version of OpenMPI that you installed.

### Step 4: Test MPI

You can test your OpenMPI installation with a simple MPI program. Save the following code into a file named `hello.c`:

```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // Initialize MPI
    MPI_Init(NULL, NULL);

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Print a hello message
    printf("Hello from process %d of %d\n", world_rank, world_size);

    // Finalize MPI
    MPI_Finalize();

    return 0;
}
```

Compile and run the program using the following commands:

```bash
mpicc -o hello hello.c
mpirun -np 4 hello
```

This will compile and execute the program on 4 processes. Adjust the `-np` parameter based on the number of processes you want to run.

If everything is set up correctly, you should see output messages from each process indicating their rank and the total number of processes.

That's it! You now have OpenMPI installed on your macOS system.

### Quick MPI smoke test with repo hostfile

Run after generating `hostfile` in the repo root:

```bash
mpirun --hostfile ../hostfile -np 2 python - <<'PY'
from mpi4py import MPI
c = MPI.COMM_WORLD
print(f'hello {c.Get_rank()}/{c.Get_size()}')
PY
```
