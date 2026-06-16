# Hermes Agent — Apple Container image (Ubuntu base)
#
# Runs the NousResearch/hermes-agent inside a lightweight Linux micro-VM via
# Apple `container`. As root the official installer uses an FHS layout:
#   code    -> /usr/local/lib/hermes-agent
#   command -> /usr/local/bin/hermes
#   data    -> /root/.hermes   (we bind-mount ./hermes-data here at runtime)
FROM docker.io/library/ubuntu:24.04

# NOTE: DEBIAN_FRONTEND is apt/dpkg's "no interactive prompts" flag. Ubuntu uses
# apt/dpkg too (it is Debian-derived), so this applies here — it does NOT mean
# the base OS is Debian. The base image above is ubuntu:24.04.
ENV DEBIAN_FRONTEND=noninteractive \
    HERMES_HOME=/root/.hermes \
    PATH=/usr/local/bin:/root/.local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin

# System prerequisites the installer expects, pre-installed so it never needs
# sudo at build time (in a container we are already root).
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        build-essential \
        python3-dev \
        libffi-dev \
        ripgrep \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes Agent non-interactively.
#   --skip-setup      : no interactive API-key/model wizard at build time (M4, runtime)
#   --skip-browser    : skip heavy Playwright/Chromium download (add later if needed)
#   --non-interactive : never block on prompts
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
      | bash -s -- --skip-setup --skip-browser --non-interactive

# Move the seeded data dir aside so a fresh bind-mount can be populated on first
# run without the empty mount masking the baked defaults.
RUN if [ -d /root/.hermes ] && [ -n "$(ls -A /root/.hermes 2>/dev/null)" ]; then \
        mkdir -p /opt/hermes-seed && cp -a /root/.hermes/. /opt/hermes-seed/ ; \
    else \
        mkdir -p /opt/hermes-seed ; \
    fi \
    && mkdir -p /root/.hermes

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["hermes"]
