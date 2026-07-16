FROM ghcr.io/actions/actions-runner:2.335.1

# gh intentionally unpinned: like GitHub-hosted runners, the image tracks the latest CLI on each rebuild.
# The fingerprint allowlist pins the apt trust anchor to exactly GitHub's published signing keys.
RUN sudo rm -rf /etc/apt/sources.list.d/temp.list && \
    sudo apt update -y && \
    sudo apt install -y curl wget rsync gnupg && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /tmp/githubcli-archive-keyring.gpg && \
    [ "$(gpg --show-keys --with-colons /tmp/githubcli-archive-keyring.gpg | awk -F: '/^pub/{getline; print $10}' | sort | tr '\n' ' ')" = "2C6106201985B60E6C7AC87323F3D4EA75716059 7F38BBB59D064DBCB3D84D725612B36462313325 " ] && \
    sudo install -m 0644 /tmp/githubcli-archive-keyring.gpg /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    rm /tmp/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    sudo apt update -y && \
    sudo apt install -y gh && \
    gh --version && \
    sudo rm -rf /var/lib/apt/lists/*
