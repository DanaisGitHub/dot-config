FROM fedora:43

# These values are supplied by compose.yaml during the build.
# Matching the host UID/GID prevents root-owned files in mounted projects.
ARG USER_UID=1000
ARG USER_GID=1000
ARG OPENCODE_VERSION=latest

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    EDITOR=nvim \
    VISUAL=nvim

# Install development tools into the image.
RUN dnf install -y \
        bash \
        ca-certificates \
        curl \
        git \
        openssh-clients \
        sudo \
        tmux \
        neovim \
        ripgrep \
        fd-find \
        fzf \
        gcc \
        gcc-c++ \
        make \
        cmake \
        pkgconf-pkg-config \
        openssl-devel \
        libffi-devel \
        golang \
        rust \
        cargo \
        rustfmt \
        nodejs \
        npm \
        python3 \
        python3-pip \
        python3-devel \
        python3-black \
        clang \
        clang-tools-extra \
        clang-format \
        unzip \
        tar \
        gzip \
        bzip2 \
        xz \
        procps-ng \
        findutils \
        which \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Create a non-root development user inside the container.
RUN groupadd --gid "${USER_GID}" dev \
    && useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/bash \
        dev \
    && printf 'dev ALL=(ALL) NOPASSWD:ALL\n' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

# Install OpenCode and the JavaScript formatter globally.
RUN npm install --global "opencode-ai@${OPENCODE_VERSION}" prettier \
    && npm cache clean --force

# Run the development environment as dev, not root.
USER dev

ENV HOME=/home/dev \
    PATH=/home/dev/.local/bin:/home/dev/go/bin:/home/dev/.cargo/bin:$PATH

WORKDIR /workspace

# Keep the container alive so compose exec can open shells and tmux sessions.
CMD ["sleep", "infinity"]
