# 🎯 Ultimate Cyber Range Neofetch Configuration

## Overview
This is a comprehensive neofetch configuration designed specifically for cyber security professionals, penetration testers, and full-stack developers. It provides instant visibility into your complete development and security arsenal.

## 🔥 Features

### 🎯 Cyber Range Capabilities Display
- **GPU**: 18-core Metal4 with 36GB Unified Memory
- **Languages**: Python 3.13, Swift 6.2, Rust 1.89, Go 1.24, Node.js 24.5, Java 24
- **Security**: OpenSSL 3.5, SSH 10.0, with optional Nmap detection
- **Cloud**: GCP 533, Docker 28.3, Kubernetes 1.32, Terraform 1.12, Firebase 14.1
- **Compile**: Clang 20.1, GCC 17.0, Homebrew 4.6, Conda 25.7

### 📝 Development Environment
- **Editors**: Neovim 0.11.3, VS Code 1.103.0, Vim 9.1
- **Tools**: Tmux 3.5a, Ripgrep 14.1.1, Bat 0.25.0, Htop 3.4.1
- **Database**: PostgreSQL 14.18, Redis 8.2.0, SQLite 3.50.4

### 📊 Live Performance Metrics
- **Performance**: Real-time load average, disk usage percentage, battery status
- **Network**: Local IP address and connection type monitoring

## 🛠️ Installation

### Requirements
- macOS (tested on macOS 26.0)
- Homebrew package manager
- Neofetch installed

### Quick Setup
```bash
# Install neofetch if not already installed
brew install neofetch

# Backup existing configuration
cp ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.backup

# Apply the cyber range configuration
# (Copy the configuration from this repository to ~/.config/neofetch/config.conf)
```

## 🎨 Configuration Highlights

### Grouped Information Display
Instead of showing 31+ individual tool versions, the configuration intelligently groups related tools:

- **Languages**: All programming languages in one line
- **Security**: Security-related tools and versions
- **Cloud**: DevOps and cloud-native tools
- **Compile**: Compilation and build tools
- **Editors**: Text editors and IDEs
- **Tools**: CLI productivity tools
- **Database**: Database systems
- **Performance**: Real-time system metrics
- **Network**: Network connectivity status

### Dynamic Tool Detection
The configuration automatically detects installed tools and only displays them if present, making it adaptable to different development environments.

## 🔧 Included Tools & Versions

### Programming Languages (6)
- Python 3.13.5
- Swift 6.2
- Rust 1.89.0
- Go 1.24.6
- Node.js 24.5.0 (npm 11.5.2)
- Java 24.0.2

### Security Tools (2+)
- OpenSSL 3.5.2
- SSH 10.0p2
- Nmap (if installed)

### Cloud & DevOps (5)
- Google Cloud SDK 533.0.0
- Docker 28.3.2
- Kubernetes 1.32.2
- Terraform 1.12.2
- Firebase CLI 14.11.1

### Compilation Tools (4)
- Clang 20.1.8
- GCC (Apple Clang wrapper)
- Homebrew 4.6.0
- Conda 25.7.0

### Editors (3)
- Neovim 0.11.3
- Visual Studio Code 1.103.0
- Vim 9.1

### Productivity Tools (4)
- Tmux 3.5a
- Ripgrep 14.1.1
- Bat 0.25.0
- Htop 3.4.1

### Databases (3)
- PostgreSQL 14.18
- Redis 8.2.0
- SQLite 3.50.4

## 📊 Live Metrics

The configuration displays real-time system information:
- **Load Average**: Current system load
- **Disk Usage**: Percentage of disk space used
- **Battery**: Current battery percentage (for laptops)
- **Network**: Local IP address and connection type

## 🎯 Perfect For

- **Red Team Operations**: Complete offensive security toolkit visibility
- **Blue Team Defense**: Security monitoring and analysis tools
- **Full-Stack Development**: Complete development environment overview
- **DevOps Engineers**: Cloud-native and containerization tools
- **Security Researchers**: Comprehensive security tool suite
- **System Administrators**: Real-time system monitoring

## 📋 System Requirements

### Minimum Requirements
- macOS 10.15+
- 8GB RAM
- Homebrew package manager

### Optimal Performance
- macOS 13.0+ 
- Apple Silicon (M-series) processor
- 16GB+ RAM
- Fast SSD storage

## 🚀 Usage

Simply run `neofetch` in your terminal to display the complete cyber range dashboard:

```bash
neofetch
```

The output provides instant visibility into:
- System specifications and performance
- Complete development tool stack
- Security capability assessment
- Real-time system health metrics
- Network connectivity status

## 🔄 Updates

This configuration automatically displays current versions of installed tools. To update tools:

```bash
# Update all Homebrew packages
brew update && brew upgrade

# Update Node.js packages
npm update -g

# Update Python packages
pip install --upgrade pip && pip list --outdated
```

## 📈 Benefits

1. **Instant Assessment**: See all capabilities at a glance
2. **Professional Display**: Clean, organized information layout
3. **Real-time Monitoring**: Live performance and network metrics
4. **Adaptable**: Only shows installed tools
5. **Comprehensive**: Covers security, development, and ops tools
6. **Efficient**: Grouped display reduces information overload

## 🛡️ Security Considerations

This configuration displays tool versions which could provide information to potential attackers. Use with consideration in sensitive environments. The configuration is designed for development and testing environments.

## 📞 Support

For issues or enhancements to this neofetch configuration, please refer to the main offensive-security repository.

---

**🎯 Created for the Ultimate Cyber Range Experience**
*Making every terminal session count!*
