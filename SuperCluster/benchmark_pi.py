# benchmark_pi.py
import time

import numpy as np
from mpi4py import MPI


class PiBenchmark:
    def __init__(self):
        self.comm = MPI.COMM_WORLD
        self.rank = self.comm.Get_rank()
        self.size = self.comm.Get_size()

    def calculate_pi_monte_carlo(self, n_points):
        """Monte Carlo method for Pi calculation"""
        local_count = 0
        np.random.seed(self.rank + int(time.time()))

        for _ in range(n_points // self.size):
            x, y = np.random.random(2)
            if x**2 + y**2 <= 1:
                local_count += 1

        total_count = self.comm.reduce(local_count, op=MPI.SUM, root=0)

        if self.rank == 0:
            pi_estimate = 4 * total_count / n_points
            return pi_estimate
        return None

    def benchmark(self, max_points=10**7):
        """Run scalability benchmarks"""
        points_list = [10**i for i in range(3, int(np.log10(max_points)) + 1)]

        if self.rank == 0:
            results = []

        for n_points in points_list:
            start_time = MPI.Wtime()
            pi = self.calculate_pi_monte_carlo(n_points)
            elapsed = MPI.Wtime() - start_time

            if self.rank == 0:
                results.append(
                    {
                        "points": n_points,
                        "pi_estimate": pi,
                        "time_seconds": elapsed,
                        "nodes": self.size,
                        "points_per_second": n_points / elapsed if elapsed > 0 else 0,
                    }
                )
                print(
                    f"Nodes: {self.size}, Points: {n_points}, Time: {elapsed:.4f}s, Pi: {pi:.10f}"
                )

        if self.rank == 0:
            return results


# Run benchmark
if __name__ == "__main__":
    benchmark = PiBenchmark()

    if MPI.COMM_WORLD.Get_rank() == 0:
        print(
            f"=== MPI Pi Benchmark with {MPI.COMM_WORLD.Get_size()} nodes ===")

    results = benchmark.benchmark()

    if results and MPI.COMM_WORLD.Get_rank() == 0:
        import json

        with open(f"benchmark_{MPI.COMM_WORLD.Get_size()}nodes.json", "w") as f:
            json.dump(results, f, indent=2)
