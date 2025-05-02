# --- Builder Stage ---
FROM elixir:1.18-alpine AS builder

# Set build arguments
ARG MIX_ENV=prod
ARG SECRET_COOKIE=supersecretcookie

# Set environment variables needed for build
ENV MIX_ENV=${MIX_ENV} \
    SECRET_COOKIE=${SECRET_COOKIE}

# Install build dependencies
RUN apk add --no-cache build-base git openssh

# Set the working directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy dependency definition files FIRST
COPY mix.exs mix.lock ./

# Fetch and compile dependencies based on the copied lock file
# This layer is cached as long as mix.exs/mix.lock don't change
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy the rest of the application source code needed for compilation
# This includes config files needed at compile time and source code
COPY config config
COPY lib lib
COPY rel rel
# Add any other directories needed for compile/release (e.g., priv)
# COPY priv priv

# Build the release (this will compile your application code)
# Ensure MIX_ENV is set correctly for the release command
RUN mix release

# --- Release Stage ---
# Use a minimal Alpine image for the final stage
FROM alpine:latest AS app

RUN apk add --no-cache libstdc++ libgcc ncurses-libs

# Set default ENV variables for runtime (can be overridden)
ENV MIX_ENV=prod \
    SECRET_COOKIE=supersecretcookie \
    LANG=C.UTF-8

WORKDIR /app

# Copy the built release from the builder stage
COPY --from=builder /app/_build/prod/rel/minimal_cluster ./

# The default command to be executed by the entrypoint (if your script uses exec "$@")
CMD ["bin/minimal_cluster", "start"] # Adjust as per your release start
