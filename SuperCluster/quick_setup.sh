#!/bin/bash
# quick_setup.sh

echo "Setting up SuperCluster in 5 steps..."

# Step 1: Prerequisites
echo "[1/5] Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-dev build-essential \
    openmpi-bin libopenmpi-dev nmap sshpass git

# Step 2: Python packages
echo "[2/5] Installing Python packages..."
pip3 install mpi4py python-nmap flask psutil requests pandas

# Step 3: Generate SSH keys
echo "[3/5] Setting up SSH..."
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "supercluster-$(hostname)"
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# Step 4: Configure hostfile
echo "[4/5] Configuring cluster..."
read -p "Enter number of worker nodes: " NUM_WORKERS
python3 -c "
import socket
master_ip = socket.gethostbyname(socket.gethostname())
with open('hostfile', 'w') as f:
    f.write(f'{master_ip} slots=4\\n')
    for i in range($NUM_WORKERS):
        f.write(f'192.168.1.{i+2} slots=2\\n')
print(f'Hostfile created with master IP: {master_ip}')
"

# Step 5: Test
echo "[5/5] Testing setup..."
mpirun --hostfile hostfile -np 2 python3 -c "from mpi4py import MPI; print(f'Hello from rank {MPI.COMM_WORLD.Get_rank()}/{MPI.COMM_WORLD.Get_size()}')"

echo "Setup complete! Run './start_monitor.sh' to start the dashboard."