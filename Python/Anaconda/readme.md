# Pre-Requisite

![Anaconda](https://www.anaconda.com/wp-content/uploads/2022/12/anaconda_secondary_logo.svg)

[Install Anaconda Distribution](https://www.anaconda.com/download/success)

You can start with the most fundamental DS, AI, and ML packages. Using Navigator or the command line, you can easily manage applications, packages, and environments.


# Set 'x' Your Primary Conda/Python Environment (10 One-Liner Steps)

**1. Configure modern solver & update base:**
```bash
conda config --show solver; conda config --set solver libmamba; conda update -n base -c conda-forge conda; conda config --add channels conda-forge; conda update --all -n base
```

**2. Create new primary Python 3.14 environment:**
```bash
conda create -n x python=3.14 -y && conda activate x
```

**3. Set 'x' as default auto-activated environment:**
**Windows:**
```cmd
conda config --set auto_activate_base false && echo conda activate x >> %USERPROFILE%\.condarc
```
**macOS/Linux:**
```bash
conda config --set auto_activate_base false && echo "conda activate x" >> ~/.bashrc && source ~/.bashrc
```

**4. Fully update your new primary environment:**
```bash
conda update -n x -c conda-forge conda && conda update --all -n x
```

**5. Fallback to classic solver if needed (run only if errors occur):**
```bash
conda config --set solver classic && conda update --all -n x
```

**6. Export your environment recipe:**
```bash
conda env export > environment.yml
```

**7. Install essential data science stack:**
```bash
conda install -n x anaconda-client jupyterlab pandas scikit-learn seaborn -y
```

**8. Upgrade pip and all pip packages:**
**macOS/Linux:**
```bash
pip install --upgrade pip && pip list --format=freeze | awk -F '==' '{print $1}' | xargs -n1 pip install -U
```
**Windows PowerShell:**
```powershell
pip install --upgrade pip; pip list --format=freeze | ForEach-Object {$_.Split('==')[0]} | ForEach-Object {pip install -U $_}
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

**Switch back to base environment temporarily:**
```bash
conda activate base
```

**Replicate environment from file:**
```bash
conda env update -n x -f environment.yml
```

**Install specific package in 'x':**
```bash
conda install -n x package-name -y
```

**Conda GitHub repository:**

[conda](https://github.com/conda/conda)

**Conda cheat sheet:**

[Conda Cheatsheet](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)

**Code Online:**

Now featuring new AI-powered code generation, insights, and debugging! [JupyterLab](https://nb.anaconda.cloud)
