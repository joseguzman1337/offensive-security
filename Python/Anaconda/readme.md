# Pre-Requisite

![Anaconda](https://www.anaconda.com/wp-content/uploads/2022/12/anaconda_secondary_logo.svg)

[Install Anaconda Distribution](https://www.anaconda.com/download/success)

You can start with the most fundamental DS, AI, and ML packages. Using Navigator or the command line, you can easily manage applications, packages, and environments.

# Set 'x' Your Primary Conda/Python Environment (10 One-Liner Steps)

**1. Configure modern solver & update base:**

```bash
conda config --show solver; conda config --set solver libmamba; conda update -n base -c conda-forge conda --yes; conda config --add channels conda-forge bioconda; conda update --all -n base --yes
```

**2. Create new primary Python 3.13.12 environment:**

```bash
conda create -n x -c conda-forge python=3.13.12 --yes && conda activate x
```

**3. Set 'x' as default auto-activated environment:**

##

**Windows:**

```cmd
conda config --set auto_activate false && echo conda activate x >> %USERPROFILE%\.condarc
```

##

**macOS/Linux (zsh + bash):**

```bash
echo 'alias zsh="conda config --set auto_activate_base false && echo \"conda activate x\" >> ~/.zshrc && source ~/.zshrc"' >> ~/.zshrc && source ~/.zshrc && conda config --set auto_activate false && echo "conda activate x" >> ~/.bashrc && source ~/.bashrc
```

**4. Fully update your new primary environment:**

```bash
conda update -n x -c conda-forge --all --yes
```

**5. Fallback to classic solver if needed (run only if errors occur):**

```bash
conda config --set solver classic && conda update --all -n x -c conda-forge --yes
```

**6. Export your environment recipe:**

```bash
conda activate x && conda env export > environment.yml
```

**7. Install essential data science + AI/ML stack ready for development:**

You can now:

- Run local LLMs with Ollama
- Build AI applications with LangChain
- Create web interfaces with Gradio or Streamlit
- Use PyTorch for deep learning
- Access Hugging Face models via Transformers

```bash
conda install -n x -c defaults anaconda-navigator --yes && conda install -n x -c conda-forge anaconda-client jupyterlab pandas scikit-learn seaborn --yes && conda install -n x -c bioconda scipy --yes && conda install -n x -c conda-forge pytorch torchvision transformers huggingface_hub ollama --yes
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

or


```bash
source /opt/homebrew/Caskroom/miniforge/base/bin/activate x && anaconda login
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
conda env update -n x -f environment.yml --yes
```

**Install specific package in 'x':**

```bash
conda install -n x -c conda-forge package-name --yes
```

---

**Bonus:**

[Conda GitHub repository](https://github.com/conda/conda)

[Conda Cheatsheet](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)

Now featuring new AI-powered code generation, insights, and debugging! [Code Online with JupyterLab](https://nb.anaconda.cloud)
