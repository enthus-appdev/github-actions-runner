FROM ghcr.io/actions/actions-runner:2.335.1

# gh intentionally unpinned: like GitHub-hosted runners, the image tracks the latest CLI on each rebuild.
# The fingerprint allowlist pins the apt trust anchor to exactly GitHub's published signing keys.
RUN sudo rm -rf /etc/apt/sources.list.d/temp.list && \
    sudo apt update -y && \
    sudo apt install -y curl wget rsync gnupg libatomic1 && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /tmp/githubcli-archive-keyring.gpg && \
    # Primary-key fingerprints, trust-on-first-use from the keyring served by cli.github.com
    # on 2026-07-16 (GitHub publishes only the keyring URL, not fingerprints). Detects future
    # rotation/substitution, not a compromise of that initial download. On mismatch: re-fetch
    # per https://github.com/cli/cli/blob/trunk/docs/install_linux.md and update the list.
    gnupgtmp="$(mktemp -d)" && \
    actual="$(GNUPGHOME=$gnupgtmp gpg --show-keys --with-colons /tmp/githubcli-archive-keyring.gpg | awk -F: '$1=="pub"{p=1;next} p&&$1=="fpr"{print $10;p=0}' | LC_ALL=C sort | paste -sd' ')" && \
    rm -rf "$gnupgtmp" && \
    { [ -n "$actual" ] || { echo "gh keyring: no fingerprints extracted (download or gpg parse failed)" >&2; exit 1; }; } && \
    expected="2C6106201985B60E6C7AC87323F3D4EA75716059 7F38BBB59D064DBCB3D84D725612B36462313325" && \
    { [ "$actual" = "$expected" ] || { echo "gh keyring fingerprint mismatch: got [$actual] want [$expected]" >&2; exit 1; }; } && \
    sudo install -m 0644 /tmp/githubcli-archive-keyring.gpg /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    rm /tmp/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    sudo apt update -y && \
    sudo apt install -y gh && \
    gh --version && \
    sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/*
