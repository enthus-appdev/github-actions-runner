FROM ghcr.io/actions/actions-runner:2.335.1

# gh intentionally unpinned: like GitHub-hosted runners, the image tracks the latest CLI on each rebuild.
# The keyring fingerprint check pins the apt trust anchor to GitHub's published signing key.
RUN sudo rm -rf /etc/apt/sources.list.d/temp.list && \
    sudo apt update -y && \
    sudo apt install -y curl wget rsync gnupg && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /tmp/githubcli-archive-keyring.gpg && \
    gpg --show-keys --with-colons /tmp/githubcli-archive-keyring.gpg | grep -q '^fpr:::::::::2C6106201985B60E6C7AC87323F3D4EA75716059:' && \
    sudo install -m 0644 /tmp/githubcli-archive-keyring.gpg /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    rm /tmp/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    sudo apt update -y && \
    sudo apt install -y gh && \
    gh --version && \
    sudo rm -rf /var/lib/apt/lists/*
