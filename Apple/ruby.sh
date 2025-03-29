#!/bin/bash

# --- Prerequisites ---
# 1. RVM MUST be manually removed first (run 'rvm implode', check dotfiles).
# 2. Your shell configuration (~/.zshrc, ~/.bash_profile) should be free of errors.
# 3. Homebrew MUST be installed.
# 4. Oracle JDK 24 MUST be installed.
# 5. Build tools likely needed: Xcode Command Line Tools (`xcode-select --install`), potentially `brew install libyaml gmp`.

# --- Configuration ---
set -e # Exit on errors

echo "INFO: Step 1 - Setting JAVA_HOME for Oracle JDK 24..."
export JAVA_HOME=$(/usr/libexec/java_home -v 24)
if [ -z "$JAVA_HOME" ]; then
  echo "ERROR: Oracle JDK 24 not found. Please install it."
  exit 1
fi
echo "INFO: JAVA_HOME set to $JAVA_HOME"
java -version

echo "INFO: Step 2 - Installing rbenv and ruby-build via Homebrew..."
if ! command -v brew &> /dev/null; then
  echo "ERROR: Homebrew not found. Please install it first."
  exit 1
fi
export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '/\.rbenv/ {next} {print}' | sed 's/:$//')
brew update
brew install rbenv ruby-build || brew upgrade rbenv ruby-build

echo "INFO: Step 3 - Configuring shell for rbenv..."
RBENV_INIT_LINE='eval "$(rbenv init -)"'
SHELL_CONFIG_ZSH="$HOME/.zshrc"
SHELL_CONFIG_BASH="$HOME/.bash_profile"

add_line_if_missing() {
  local line="$1"
  local file="$2"
  if [ -f "$file" ]; then
    if ! grep -Fxq "$line" "$file"; then
      echo "INFO: Adding rbenv init line to $file"
      echo "$line" >> "$file" || echo "WARN: Failed to add init line to $file (permissions?)."
    else
      echo "INFO: rbenv init line already found in $file."
    fi
  elif [ "$file" == "$SHELL_CONFIG_BASH" ]; then
      if [ ! -f "$SHELL_CONFIG_ZSH" ] || [ "$(basename "$SHELL")" != "zsh" ]; then
           echo "INFO: Creating $file and adding rbenv init."
           echo "$line" > "$file" || echo "WARN: Failed to create/add init line to $file (permissions?)."
      fi
  fi
}

add_line_if_missing "$RBENV_INIT_LINE" "$SHELL_CONFIG_ZSH"
add_line_if_missing "$RBENV_INIT_LINE" "$SHELL_CONFIG_BASH"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
echo "INFO: rbenv initialized for current script session."

# --- Use correct identifier for rbenv/ruby-build ---
JRUBY_VERSION_RBENV="jruby-9.4.12.0"

echo "INFO: Step 4 - Setting _JAVA_OPTIONS and Installing $JRUBY_VERSION_RBENV..."
export _JAVA_OPTIONS="--add-opens=java.base/java.security=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=org.jruby.dist --add-exports=java.base/sun.misc=org.jruby.dist"
echo "INFO: _JAVA_OPTIONS set to: $_JAVA_OPTIONS"

echo "INFO: Installing $JRUBY_VERSION_RBENV (if not already installed)..."
if ! rbenv versions --bare | grep -q "^${JRUBY_VERSION_RBENV}$"; then
  rbenv install $JRUBY_VERSION_RBENV
else
  echo "INFO: $JRUBY_VERSION_RBENV already installed."
fi
echo "INFO: $JRUBY_VERSION_RBENV installation command finished."
rbenv rehash

echo "INFO: Unsetting _JAVA_OPTIONS."
unset _JAVA_OPTIONS

echo "INFO: Step 5 - Installing compatible gems for $JRUBY_VERSION_RBENV..."
rbenv shell $JRUBY_VERSION_RBENV
echo "INFO: Temporarily switched shell to $JRUBY_VERSION_RBENV"
echo "INFO: Installing latest compatible Rails and Puma 6.6.0..."
gem install rails puma:6.6.0 --no-document # Let bundler pick latest compatible Rails
rbenv rehash # Update shims after gem install
echo "INFO: Rails and Puma gems installed for $JRUBY_VERSION_RBENV."
rbenv shell --unset
echo "INFO: Switched shell back from JRuby."

echo "INFO: Step 6 - Force Reinstalling MRI Ruby 3.4.2 (YJIT Disabled)..."
MRI_RUBY_VERSION="3.4.2"
echo "INFO: Force Reinstalling MRI Ruby $MRI_RUBY_VERSION..."

# --- Disable YJIT to work around potential linking issues ---
export RUBY_CONFIGURE_OPTS="--disable-yjit"
echo "INFO: Set RUBY_CONFIGURE_OPTS=$RUBY_CONFIGURE_OPTS"

# --- Force reinstall using -f to ensure it builds with YJIT disabled ---
rbenv install --force $MRI_RUBY_VERSION

unset RUBY_CONFIGURE_OPTS
echo "INFO: Unset RUBY_CONFIGURE_OPTS."

echo "INFO: MRI Ruby $MRI_RUBY_VERSION reinstallation command finished."
rbenv rehash

echo "INFO: Step 7 - Setting global default Ruby..."
rbenv global $MRI_RUBY_VERSION
echo "INFO: Global default Ruby set to $MRI_RUBY_VERSION."

echo "INFO: Step 8 - Verifying installation..."
echo "--- Installed Ruby Versions ---"
rbenv versions
echo "--- Global Default Version ---"
rbenv global
echo "--- Current Ruby Version (should be default) ---"
ruby -v
echo "--- JRuby Executable Path ---"
RBENV_VERSION=$JRUBY_VERSION_RBENV rbenv which jruby || echo "JRuby executable not found for $JRUBY_VERSION_RBENV."
echo "--- Rails Executable Path (in JRuby) ---"
RBENV_VERSION=$JRUBY_VERSION_RBENV rbenv which rails || echo "Rails executable not found for $JRUBY_VERSION_RBENV."

echo "SUCCESS: Script finished."
echo "IMPORTANT: Please restart your terminal or run 'source ~/.zshrc' / 'source ~/.bash_profile' etc. for changes to take full effect."
echo "IMPORTANT: Ensure RVM was completely removed manually."
echo "NOTE: If MRI Ruby build failed again, check build tools (Xcode Command Line Tools, brew install ...) and logs in /tmp/ruby-build.*.log"
