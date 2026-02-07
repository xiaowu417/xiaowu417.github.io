# Base image: Ruby with necessary dependencies for Jekyll
FROM ruby:3.2

# Allow passing proxy settings at build time (optional)
ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=${HTTP_PROXY} HTTPS_PROXY=${HTTPS_PROXY} http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY}

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy Gemfile into the container (necessary for `bundle install`)
COPY Gemfile ./

# Use a faster RubyGems mirror to avoid network timeouts during build,
# then install bundler and project gems. If you prefer the upstream
# rubygems.org, remove the gem sources line.
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org || true
RUN gem install bundler:2.3.26 && bundle config set mirror.https://rubygems.org https://gems.ruby-china.com/ && bundle install --jobs 4 --retry 3

# Command to serve the Jekyll site
CMD ["jekyll", "serve", "-H", "0.0.0.0", "-w", "--config", "_config.yml,_config_docker.yml"]

