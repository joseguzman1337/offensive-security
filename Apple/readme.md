√ Tested on Apple M2 + M3, and Intel Chipsets using macOS sequoia

🍎

# Pre-Requisite

Install Python https://www.python.org/downloads/

This will take up to a few minutes, now is a great time to go for a coffee ☕...

1. Install Homebrew

```ShellSession
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
brew install --cask gitfinder powershell dotnet keepassxc visual-studio-code@insiders && brew install cask && brew install python && brew install macfuse && brew link cask && brew tap hashicorp/tap && brew install hashicorp/tap/tfstacks && brew install gpg pyenv rust nginx PostgreSQL pnpm htop act jq keybase cask npm node scons helm kubectl git-filter-repo neofetch frum python-argcomplete screenfetch minikube newman kops awscli sqlmap colortail zsh-syntax-highlighting zsh-autosuggestions subfinder xclip hashcat dnsmap nmap git shellcheck git-lfs git-gui gopls pcre2 mysql libarchive burp-suite metasploit az gobuster telegram-desktop docker-compose mpi4py cmatrix jython jruby istioctl aom fb303 helm libnghttp2 six apr fbthrift icu4c krb5 libpng python-setuptools snappy R mono apr-util fdupes imath libpq node argon2 fizz gradle isl open-mpi oniguruma metasploit aircrack-ng linkerd nushell sslscan testssl yasm bandit c7n cargo-audit cyrus-sasl dcfldd flawfinder gosec hubble ipv6toolkit kube-score bower kubeaudit libprelude libxmlsec1 lynis nss opensaml prowler rats scorecard sf-pwgen suricata terrascan tfsec xml-security-c zeek sqlite aspell asdf fmt istioctl libsodium openexr autoconf folly jansson libssh2 openjdk fontconfig ruby mmdbinspect jenv libtasn1 openldap bash-completion freetds jpeg libtiff openssl telnet bdw-gc freetype jpeg-xl libtool p11-kit boost gcc libunistring pcre brotli gd libuv pcre2 tidy-html5 ruby c-ares terraform mvn libvmaf php unbound ca-certificates gdbm krb5 libzip nuclei tor fuzzy-find pipx unixodbc gettext kubernetes-cli lua pkg-config wangle gflags libavif lz4 protobuf watchman giflib libcbor m4 pv webp composer tree libconfig python-tabulate wget coreutils glog libevent mpdecimal python@3.14 xz curl gmp libffi mpfr yarn gnutls libfido2 mycli readline zstd grep libidn2 gh rtmpdump double-conversion guile liblinear emacs libmpc nettle screenresolution zsh zsh-completions && brew install --cask github telegram telegram-desktop && brew tap anchore/grype && brew install grype && brew install go && brew install powershell && brew install jq && brew install wget && brew install --cask colorwell remoteviewer && brew install skaffold && brew install aquasecurity/trivy/trivy && brew install luarocks && brew install android-platform-tools && brew install aws/tap/copilot-cli && brew install --cask temurin && brew install --cask rubymine && brew install snyk-cli && brew install checkov && brew install --cask bootstrap-studio && brew install rbenv ruby-build && rbenv install latest && rbenv global latest && brew list | wc -l
```

```ShellSession
(brew list tfenv >/dev/null 2>&1 || (brew unlink terraform 2>/dev/null; brew install tfenv)) && (brew list tgenv >/dev/null 2>&1 || brew install tgenv) && (brew list pipx >/dev/null 2>&1 || brew install pipx) && (which bower >/dev/null 2>&1 || npm install -g bower) && softwareupdate --all --install --force && brew update-reset && brew update && brew upgrade && brew link --overwrite tfenv 2>/dev/null && (tfenv list | grep -q "1.12.2" || tfenv install latest) && tfenv use last && tfenv list && terraform -v && bower update --allow-root 2>/dev/null && pipx upgrade-all --force && pip list --outdated --format=freeze 2>/dev/null | cut -d = -f 1 | xargs -n1 pip install -U -q --no-warn-script-location 2>/dev/null && pip3 list --outdated --format=freeze 2>/dev/null | cut -d = -f 1 | xargs -n1 pip3 install -U -q --no-warn-script-location 2>/dev/null
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
rbenv global latest && ruby -v && gem install digest-crc unf_ext --no-document && gem install xcode-install --no-document && sudo xcversion update && xcversion list && xcversion simulators
```

Enjoy ✅ 🎧

#

(Optional)

# See full list of available Brew packages online

```ShellSession
brew list
```
