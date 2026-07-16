FROM ghcr.io/actions/actions-runner:2.335.1

# gh intentionally unpinned: like GitHub-hosted runners, the image tracks the latest CLI on each rebuild
RUN sudo apt update -y && \
    sudo apt install -y curl wget rsync && \
    sudo rm -rf /etc/apt/sources.list.d/temp.list && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    sudo apt update -y && \
    sudo apt install -y gh && \
    sudo rm -rf /var/lib/apt/lists/*
