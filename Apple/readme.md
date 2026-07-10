√ Tested on Apple M5 via macOS Golden Gate 27.0 (26A5368g) arm64, also under Intel Chipsets 

🍎

# Pre-Requisite

Install Python https://www.python.org/downloads/

This will take up to a few minutes, now is a great time to go for a coffee ☕...

1. Install Homebrew

```ShellSession
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

IaC equivalent for all macOS nodes, including reinstall fallback for problematic packages:

```ShellSession
ansible-playbook -i ../Python/Anaconda/Ansible/inventory.ini ansible_macos.yml
```

#

3. Install Rosetta, Xcode, and Brew, including Formulae and Casks, and Upgrade Pip packages

```ShellSession
sudo softwareupdate --install-rosetta --agree-to-license
```

```ShellSession
sudo gem install xcode-install && xcversion update && xcversion list
```

#

```ShellSession
brew install -y powershell dotnet python colima podman skopeo gpg pyenv rust nginx PostgreSQL pnpm htop act jq npm node scons helm kubectl git-filter-repo fastfetch frum screenfetch minikube newman kops awscli sqlmap colortail zsh-syntax-highlighting zsh-autosuggestions subfinder xclip hashcat dnsmap git shellcheck git-lfs git-gui gopls pcre2 mysql libarchive az gobuster docker-compose mpi4py cmatrix jython jruby istioctl aom fb303 libnghttp2 apr fbthrift icu4c krb5 libpng python-setuptools snappy R mono apr-util fdupes imath libpq argon2 fizz gradle isl open-mpi oniguruma aircrack-ng linkerd nushell sslscan testssl yasm bandit c7n cargo-audit cyrus-sasl dcfldd flawfinder gosec hubble ipv6toolkit kube-score bower kube-bench libxmlsec1 lynis nss opensaml prowler rats scorecard sf-pwgen suricata terrascan tfsec xml-security-c zeek sqlite aspell asdf fmt libsodium openexr autoconf folly jansson openjdk fontconfig ruby mmdbinspect jenv libtasn1 openldap bash-completion freetds jpeg libtiff openssl telnet bdw-gc freetype jpeg-xl libtool p11-kit boost gcc libunistring brotli gd libuv tidy-html5 c-ares terraform mvn libvmaf php unbound ca-certificates gdbm libzip nuclei tor fuzzy-find pipx unixodbc gettext kubernetes-cli lua pkg-config wangle gflags libavif lz4 protobuf watchman giflib libcbor m4 pv webp composer tree libconfig python-tabulate wget coreutils glog libevent mpdecimal python@3.13 python@3.14 xz curl gmp libffi mpfr yarn gnutls libfido2 mycli readline zstd grep libidn2 gh rtmpdump double-conversion guile liblinear emacs libmpc nettle screenresolution zsh zsh-completions go skaffold trivy luarocks snyk-cli checkov rbenv ruby-build tfstacks nmap libssh2 --formula grype && for cask in finch podman-desktop keybase burp-suite metasploit android-platform-tools copilot-cli; do brew install --cask -y $cask; done && rbenv install $(rbenv install -l | grep -v -E '[a-z]' | tail -1) && rbenv global $(rbenv install -l | grep -v -E '[a-z]' | tail -1) && brew list | wc -l
```

```ShellSession
(brew list tfenv >/dev/null 2>&1 || (brew unlink terraform 2>/dev/null; brew install tfenv)) && (brew list tgenv >/dev/null 2>&1 || brew install tgenv) && (brew list pipx >/dev/null 2>&1 || brew install pipx) && (which bower >/dev/null 2>&1 || npm install -g bower) && softwareupdate --all --install --force && brew update-reset && brew update && brew upgrade && brew link --overwrite tfenv 2>/dev/null && (tfenv list | grep -q "1.12.2" || tfenv install latest) && tfenv use latest && tfenv list && terraform -v && bower update --allow-root 2>/dev/null && pipx upgrade-all --force && pip list --outdated --format=freeze 2>/dev/null | cut -d = -f 1 | xargs -n1 pip install -U -q --no-warn-script-location 2>/dev/null && pip3 list --outdated --format=freeze 2>/dev/null | cut -d = -f 1 | xargs -n1 pip3 install -U -q --no-warn-script-location 2>/dev/null
```

#

4. Upgrade Apple Store + Apple Developer + Brew packages

```ShellSession
softwareupdate --all --install --force && brew update-reset && brew update -q && brew upgrade --greedy
```

5. Install Terraform with Tfenv / amd64 for chip Mac + Terragrunt with Tgenv

```ShellSession
brew install tgenv && TFENV_ARCH=amd64 tfenv install latest && tfenv use latest && tfenv list && tfenv list && terraform -v && tgenv install latest && tgenv use latest && terragrunt -version && terraform -version && brew cleanup

```

Install Ruby Gems + Update Apple 🍏 Developer Beta + Simulators for iOS, watchOS, and tvOS

Pre-Requisite Java + Java JDK

```ShellSession
curl -sL https://raw.githubusercontent.com/joseguzman1337/offensive-security/master/Apple/ruby.sh | bash
```

```ShellSession
export RUBY_CFLAGS="-Wno-error=implicit-function-declaration" RUBY_CONFIGURE_OPTS="--disable-install-doc" CFLAGS="-O2" && rm -rf ~/.rbenv/versions/4.0.1 && LATEST_RUBY=$(rbenv install -l | grep -E '^[0-9.]+$' | tail -1) && rbenv install $LATEST_RUBY --keep && cd ~/.rbenv/sources/$LATEST_RUBY/ruby-$LATEST_RUBY && find . -name "*.dSYM" -type d -exec rm -rf {} + 2>/dev/null && make install && rbenv global $LATEST_RUBY && eval "$(rbenv init -)" && ruby -v
```

Enjoy ✅ 🎧

#

(Optional)

# See full list of available Brew packages online

```ShellSession
brew list
```
