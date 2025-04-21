# Pre-Requisite

![Anaconda](https://www.anaconda.com/wp-content/uploads/2022/12/anaconda_secondary_logo.svg)

[Install Anaconda Distribution](https://www.anaconda.com/download/success)

You can start with the most fundamental DS, AI, and ML packages. Using Navigator or the command line, you can easily manage applications, packages, and environments.

# Install Conda Environment | Python 3.13.2 (in 10 Steps)

**Adjust environment names and commands as needed for your specific setup.**

Use the "classic" solver or "libmamba." This is a good approach because sometimes "libmamba" might have compatibility issues or might not be the best choice for all situations.
Using "classic" may provide a more reliable fallback option.

1. **Configure Solver & Update Base:** Set the solver to "classic" (in case "libmamba" has issues), then update Conda and all packages in the base environment (including from "conda-forge").

   ```bash
   conda config --show solver; conda config --set solver classic; conda update -n base -c conda-forge conda; conda config --add channels conda-forge; conda update --all -n base; conda upgrade --all
   ```

   **Configure Solver & Update Base:** Set the solver to "libmamba"), then update Conda and all packages in the base environment (including from "conda-forge").

   ```bash
   conda config --show solver; conda config --set solver libmamba; conda update -n base -c conda-forge conda; conda config --add channels conda-forge; conda update --all -n base; conda upgrade --all
   ```

2. **Create & Update New Environment:** Create a new environment named "x" with Python 3.13.2, then update it to match your base environment (using an exported environment file if needed).

   ```bash
   conda create -n x python=3.13.2; conda activate x; conda env export > environment.yml; conda env update -n x -f environment.yml
   ```

3. **Fully Update All Environments:** Ensure Conda, all packages, and any outdated components are updated in both the "base" and "x" environments.

   ```bash
   conda update -n base -c conda-forge conda; conda update --all -n base; conda upgrade --all; conda update -n x -c conda-forge conda; conda update --all -n x; conda upgrade --all; conda update -n base -c defaults conda; conda update -n base -c defaults anaconda-navigator; conda list anaconda-navigator
   ```

4. **Install Specific Conda Version (Optional):** If you need a specific Conda version, install it in both environments.

   ```bash
   conda install -n base conda=25.3.1; conda install -n x conda=25.3.1
   ```

5. **Upgrade Pip:** Upgrade the Pip package manager and all installed Pip packages.

   ## macOS + Linux

   ```bash
   python -m ensurepip --upgrade; pip install --upgrade pip; pip list --format=freeze | awk -F '==' '{print $1}' | xargs -n1 pip install -U
   ```

   ## Windows PowerShell

   ```bash
   python -m ensurepip --upgrade; pip list --format=freeze | ForEach-Object {$_.Split('==')[0]} | ForEach-Object {pip install -U $_}
   ```

6. **Install Anaconda Client:** Install the client to interact with Anaconda Cloud.

   ```bash
   conda install anaconda-client
   ```

7. **Log in to Anaconda Cloud (Optional):**
   ```bash
   anaconda login
   ```

# Resources

In case you need to clean the conda cache

```bash
conda clean --all -y
```

8. **Conda GitHub repository:**

   [conda](https://github.com/conda/conda)

9. **Conda cheat sheet:**

   [Conda Cheatsheet](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)

10. **Code Online:**

    Now featuring new AI-powered code generation, insights, and debugging! [JupyterLab](https://nb.anaconda.cloud)
