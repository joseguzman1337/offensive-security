# Pre-Requisite

![Anaconda](https://www.anaconda.com/wp-content/uploads/2022/12/anaconda_secondary_logo.svg)

[Install Anaconda Distribution](https://www.anaconda.com/download/success)

You can start with the most fundamental DS, AI, and ML packages. Using Navigator or the command line, you can easily manage applications, packages, and environments.

0. Accept Terms of Service for required channels:

```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

# Set 'x' Your Primary Conda/Python Environment (10 One-Liner Steps)

**1. Configure modern solver & update base:**

```bash
conda config --show solver; conda config --set solver libmamba; conda update -n base -c conda-forge conda --yes; conda config --add channels conda-forge; conda update --all -n base --yes
```

**2. Create new primary Python 3.14 environment:**

```bash
conda create -n x -c ad-testing/label/py314 python=3.14.0rc2 --yes && conda activate x
```

**3. Set 'x' as default auto-activated environment:**
**Windows:**

```cmd
conda config --set auto_activate false && echo conda activate x >> %USERPROFILE%\.condarc
```

**macOS/Linux:**

```bash
conda config --set auto_activate false && echo "conda activate x" >> ~/.bashrc && source ~/.bashrc
```

**4. Fully update your new primary environment:**

```bash
conda update -n x -c ad-testing/label/py314 --all --yes
```

**5. Fallback to classic solver if needed (run only if errors occur):**

```bash
conda config --set solver classic && conda update --all -n x -c ad-testing/label/py314 --yes
```

**6. Export your environment recipe:**

```bash
conda activate x && conda env export > environment.yml
```

**7. Install essential data science stack:**

```bash
conda install -n x -c ad-testing/label/py314 anaconda-navigator anaconda-client jupyterlab pandas scikit-learn seaborn --yes
```

**8. Upgrade pip and all pip packages:**
**macOS/Linux:**

```bash
python -m ensurepip --upgrade; pip install --upgrade pip; pip list --format=freeze | awk -F '==' '{print $1}' | xargs -n1 pip install -U
```

**Windows PowerShell:**

```powershell
python -m ensurepip --upgrade; pip list --format=freeze | ForEach-Object {$_.Split('==')[0]} | ForEach-Object {pip install -U $_}
```

**9. Login to Anaconda Cloud (optional):**

```bash
anaconda login
```

**10. Verify your new primary environment:**

```bash
conda info && conda list | grep python
```

---

# Utility One-Liners

**Clean Conda cache:**

```bash
conda clean --all -y
```

**Switch back to base environment temporarily (Only in case you need to use the previous Python 3.13 version:**

```bash
conda activate base
```

**Replicate environment from file:**

```bash
conda env update -n x -f environment.yml --yes
```

**Install specific package in 'x':**

```bash
conda install -n x -c ad-testing/label/py314 package-name --yes
```

---

**Bonus:**

[Conda GitHub repository](https://github.com/conda/conda)

[Conda Cheatsheet](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)

Now featuring new AI-powered code generation, insights, and debugging! [Code Online with JupyterLab](https://nb.anaconda.cloud)
