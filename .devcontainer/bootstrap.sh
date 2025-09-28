#!/bin/bash

echo "🚀 Bootstrapping Rails Development Environment..."

# Ensure .ssh directory exists and set permissions
mkdir -p /home/vscode/.ssh
sudo chown -R vscode:vscode /home/vscode/.ssh
sudo chmod 700 /home/vscode/.ssh
sudo chmod 600 /home/vscode/.ssh/* 2>/dev/null || true

# Set up user gem directory (version-agnostic)
echo "🔧 Setting up user gem directory..."
export PATH="/usr/local/bin:/usr/bin:/bin"
GEM_RUBY_VER=$(gem environment version | cut -d' ' -f1)
export GEM_HOME=/home/vscode/.gem/ruby/$GEM_RUBY_VER
export GEM_PATH=$GEM_HOME
export PATH=$GEM_HOME/bin:$PATH
mkdir -p $GEM_HOME/bin

# Update system packages
echo "⬆️  Updating system packages..."
sudo apt-get update 

echo "🛠️  Installing essential development tools..."
# Install essential development tools
sudo apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql-client \
  sqlite3 \
  libsqlite3-dev \
  curl \
  git \
  vim \
  zsh

echo "💻 Ensuring zsh is the default shell for vscode user..."
# Set zsh as default shell for vscode user if not already
if [ "$(getent passwd vscode | cut -d: -f7)" != "/usr/bin/zsh" ]; then
  sudo chsh -s /usr/bin/zsh vscode
fi

echo "💎 Installing Rails, Bundler, and Railties..."
# Install Rails, railties, and bundler to user gem directory
sudo gem update --system
gem install rails bundler railties

echo "📦 Checking for Gemfile and initializing Rails or devtools support if needed..."
if [ ! -f Gemfile ]; then
  echo "⚠️  No Gemfile detected."
  read -p "Do you want to initialize a new Rails API project here? (y/n): " INIT_RAILS
  if [ "$INIT_RAILS" = "y" ] || [ "$INIT_RAILS" = "Y" ]; then
    echo "📦 Initializing new Rails application..."
    rails new . --skip-git --database=sqlite3 --skip-docker --api
    # Add development gems
    echo "" >> Gemfile
    echo "group :development, :test do" >> Gemfile
    echo "  gem 'rspec-rails'" >> Gemfile
    echo "  gem 'factory_bot_rails'" >> Gemfile
    echo "  gem 'debug', platforms: %i[ mri mingw x64_mingw ]" >> Gemfile
    echo "end" >> Gemfile
  else
    echo "� Creating minimal Gemfile for development tools..."
    cat > Gemfile <<EOL
source 'https://rubygems.org'
gem 'bundler'
group :development, :test do
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-performance'
  gem 'rubocop-rails-omakase'
end
EOL
  fi
fi

# Install gems and setup database if Gemfile exists
echo "📚 Installing gems with Bundler..."
bundle install
if grep -q "gem ['\"]rails['\"]" Gemfile; then
  echo "🗄️  Setting up database..."
  bundle exec rails db:create
  bundle exec rails db:migrate
fi

# Install RuboCop and related gems
echo "🔍 Installing RuboCop and related gems..."
gem install rubocop rubocop-rails rubocop-performance rubocop-rails-omakase
bundle install

echo "✅ Bootstrap complete! Rails development environment is ready."
echo "🎯 You can now start the server with: rails server"
