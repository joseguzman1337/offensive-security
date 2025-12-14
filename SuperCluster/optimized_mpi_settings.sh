# optimized_mpi_settings.sh
#!/bin/bash

# Optimize MPI for security scanning workloads
export OMPI_MCA_btl="tcp,self"
export OMPI_MCA_btl_tcp_if_include="eth0"
export OMPI_MCA_orte_keep_fqdn_hostnames="1"
export OMPI_MCA_pml="ob1"
export OMPI_MCA_coll="basic,self"
export OMPI_MCA_io="romio321"

# Set process affinity for better performance
export OMPI_MCA_hwloc_base_binding_policy="core"

# Memory management
export OMPI_MCA_mpi_leave_pinned="1"
export OMPI_MCA_btl_tcp_eager_limit="524288"

# Network tuning
export OMPI_MCA_btl_tcp_port_min_v4="20000"
export OMPI_MCA_btl_tcp_port_max_v4="30000"

echo "MPI environment optimized for security scanning"