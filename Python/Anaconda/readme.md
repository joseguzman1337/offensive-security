<div align="center">

# ![Anaconda](https://www.anaconda.com/wp-content/uploads/2022/12/anaconda_secondary_logo.svg) Anaconda & Python Environment Optimizer

</div>

---

## 🚀 Phase 1: Pre-Requisite & Installation

[Install Anaconda Distribution](https://www.anaconda.com/download/success)

> Start with the most fundamental DS, AI, and ML packages. Using Navigator or the command line, you can easily manage applications, packages, and environments.

---

## 🛠 Phase 2: Set 'x' Your Primary Conda/Python Environment

**Core Setup:** This phase establishes your persistent development environment named `x`, optimized with the `rattler` solver for speed and pre-configured for the 2026 AI/ML stack.

<details>
<summary><b>📦 Click to expand: 10 One-Liner Setup Steps</b></summary>

#### **1. Configure modern solver & update base**

```bash
command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh; command -v pnpm >/dev/null 2>&1 || { command -v corepack >/dev/null 2>&1 && corepack enable && corepack prepare pnpm@latest --activate; }; command -v pnpm >/dev/null 2>&1 || curl -fsSL https://get.pnpm.io/install.sh | env SHELL="$(command -v bash)" sh -; conda config --show solver; conda config --set solver rattler; conda config --append channels conda-pypi; conda config --append channels repos/joseguzman1337/offensive-security/Python/Anaconda; conda update -n base -c conda-forge conda --yes; conda config --add channels conda-forge bioconda; conda update --all -n base --yes

```

#### **2. Create new primary Python 3.14.4 environment**

```bash
conda create -n x -c conda-forge python=3.14.4 --yes && conda activate x

```

#### **3. Set 'x' as default auto-activated environment**

**Windows:**

```cmd
conda config --set auto_activate false && echo conda activate x >> %USERPROFILE%\.condarc

```

**macOS/Linux (zsh + bash):**

```bash
echo 'alias zsh="conda config --set auto_activate_base false && echo \"conda activate x\" >> ~/.zshrc && source ~/.zshrc"' >> ~/.zshrc && source ~/.zshrc && conda config --set auto_activate false && echo "conda activate x" >> ~/.bashrc && source ~/.bashrc

```

#### **4. Fully update your new primary environment**

```bash
conda update -n x -c conda-forge --all --yes

```

#### **5. Fallback to classic solver if needed**

```bash
conda config --set solver classic && conda update --all -n x -c conda-forge --yes

```

#### **6. Export your environment recipe**

```bash
conda activate x && conda env export > environment.yml

```

#### **7. Install essential data science + AI/ML stack**

- Run local LLMs with **Ollama**
- Build AI applications with **LangChain**
- Create web interfaces with **Gradio** or **Streamlit**
- Use **PyTorch** for deep learning
- Access **Hugging Face** models via Transformers

```bash
conda install -n x -c defaults anaconda-navigator --yes && conda install -n x -c conda-forge anaconda-client jupyterlab pandas scikit-learn seaborn --yes && conda install -n x -c bioconda scipy --yes && conda install -n x -c conda-forge pytorch torchvision transformers huggingface_hub ollama --yes

```

#### **8. Install uv and upgrade uv-managed packages**

**macOS/Linux:**

```bash
conda install -n x -c conda-forge uv --yes; conda run -n x uv pip install --upgrade pip; packages="$(conda run -n x uv pip list --format=freeze | awk -F '==' 'NF {print $1}')"; [ -z "$packages" ] || conda run -n x uv pip install -U $packages

```

**Windows PowerShell:**

```powershell
conda install -n x -c conda-forge uv --yes; $packages = conda run -n x uv pip list --format=freeze | ForEach-Object { $_.Split('==')[0] } | Where-Object { $_ }; if ($packages) { conda run -n x uv pip install -U $packages }

```

#### **9. Login to Anaconda Cloud (optional)**

```bash
anaconda login

```

_or in macos using miniforge_

```bash
source /opt/homebrew/Caskroom/miniforge/base/bin/activate x && anaconda login

```

#### **10. Verify your new primary environment**

```bash
conda info && conda list | grep python

```

</details>

---

## ⚙️ Phase 3: Utility One-Liners

**Maintenance:** Essential commands for keeping your environment clean and synchronized across different machines.

<details>
<summary><b>🛠 Click to expand: Environment Utilities</b></summary>

| Task               | Command                                                |
| ------------------ | ------------------------------------------------------ |
| **Clean Cache**    | `conda clean --all -y`                                 |
| **Switch to Base** | `conda activate base`                                  |
| **Replicate Env**  | `conda env update -n x -f environment.yml --yes`       |
| **Install in 'x'** | `conda install -n x -c conda-forge package-name --yes` |

</details>

---

## 🎁 Bonus Resources & Links

- **[Conda Cheatsheet](https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf)**: Essential commands at a glance.
- **[Conda GitHub Repository](https://github.com/conda/conda)**: Source code and issue tracking.
- **[Code Online with JupyterLab](https://nb.anaconda.cloud)**: Featuring new AI-powered code generation and debugging!
