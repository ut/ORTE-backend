# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .tool-versions
FROM registry.docker.com/library/ruby:3.2.6-slim AS base

# Rails app lives here
WORKDIR /rails

ARG RAILS_MASTER_KEY
# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git ffmpeg imagemagick default-libmysqlclient-dev  yarnpkg

RUN ln -s /usr/bin/yarnpkg /usr/bin/yarn

# Install application gems
COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN bundle config set --local without test development && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

RUN yarn install

# Copy application code
COPY . .

RUN groupadd rails && \
    useradd rails -g rails --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp && \
    chown -R rails:rails db log storage tmp

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN ./bin/rails assets:precompile

# Final stage for app image
FROM base

ARG ORTE-backend_GID=1000
ARG ORTE-backend_UID=1000

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl ffmpeg imagemagick default-libmysqlclient-dev  && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd rails && \
    useradd rails -g rails --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
