# Latest version of Erlang-based Elixir installation: https://hub.docker.com/_/elixir/
FROM elixir:latest

# Create and set home directory
WORKDIR /opt/rtp_lab1_forecast

# Configure required environment
ENV MIX_ENV prod

# Install hex (Elixir package manager)
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Copy all dependencies files
COPY mix.* ./

# Install all production dependencies
RUN mix deps.get --only prod

# Compile all dependencies
RUN mix deps.compile

# Copy all application files
COPY . .

# Compile the entire project
RUN mix compile

# Run the application itself
CMD mix run