#!/bin/bash
# quick_setup.sh

echo "Setting up SuperCluster in 5 steps..."

# Step 1: Prerequisites
echo "[1/5] Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl nodejs python3-dev build-essential \
    openmpi-bin libopenmpi-dev nmap sshpass git
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
if ! command -v pnpm >/dev/null 2>&1; then
    if command -v corepack >/dev/null 2>&1; then
        corepack enable
        corepack prepare pnpm@latest --activate
    else
        curl -fsSL https://get.pnpm.io/install.sh | env SHELL="$(command -v bash)" sh -
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME:$PATH"
    fi
fi

# Step 2: Python packages
echo "[2/5] Installing Python packages..."
uv pip install --system mpi4py python-nmap flask psutil requests pandas

# Step 3: Generate SSH keys
echo "[3/5] Setting up SSH..."
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "supercluster-$(hostname)"
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

# Step 4: Configure hostfile
echo "[4/5] Configuring cluster..."
read -p "Enter number of worker nodes: " NUM_WORKERS
uv run python -c "
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
mpirun --hostfile hostfile -np 2 uv run --with mpi4py python -c "from mpi4py import MPI; print(f'Hello from rank {MPI.COMM_WORLD.Get_rank()}/{MPI.COMM_WORLD.Get_size()}')"

echo "Setup complete! Run './start_monitor.sh' to start the dashboard."
