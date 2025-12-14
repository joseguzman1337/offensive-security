#!/bin/bash
# bootstrap_cluster.sh

# Configuration
NUM_WORKERS=4
MASTER_IP="192.168.1.1"
NETWORK_RANGE="192.168.1.0/24"
MPI_VERSION="5.0.2"
PYTHON_VERSION="3.11"

# Function to generate hostfile dynamically
generate_hostfile() {
    echo "# Auto-generated hostfile for SuperCluster" > hostfile
    echo "# Generated on $(date)" >> hostfile
    echo "" >> hostfile
    
    # Master node with more slots
    echo "$MASTER_IP slots=4 max_slots=8" >> hostfile
    
    # Worker nodes
    for i in $(seq 1 $NUM_WORKERS); do
        IP="192.168.1.$((i+1))"
        echo "$IP slots=2 max_slots=4" >> hostfile
    done
    
    echo "# Total slots: $((4 + 2*NUM_WORKERS))" >> hostfile
}

# Install dependencies
install_mpi() {
    echo "Installing OpenMPI $MPI_VERSION..."
    wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-$MPI_VERSION.tar.gz
    tar -xzf openmpi-$MPI_VERSION.tar.gz
    cd openmpi-$MPI_VERSION
    ./configure --prefix=/usr/local
    make -j$(nproc)
    sudo make install
    sudo ldconfig
}

# Setup SSH keys for passwordless access
setup_ssh() {
    echo "Setting up SSH keys..."
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
}

# Main execution
main() {
    echo "=== SuperCluster Bootstrap ==="
    generate_hostfile
    install_mpi
    setup_ssh
    
    echo "Installing Python dependencies..."
    pip3 install --upgrade pip
    pip3 install mpi4py numpy pandas scipy
    
    echo "Creating test directory structure..."
    mkdir -p /cluster/{scripts,data,results,logs}
    
    echo "SuperCluster bootstrap complete!"
    echo "Hostfile generated:"
    cat hostfile
}

main