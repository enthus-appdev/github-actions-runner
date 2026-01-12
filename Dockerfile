FROM ghcr.io/actions/actions-runner:2.331.0

RUN sudo apt update -y && \
    sudo apt install -y curl wget git-all && \
    rm -rf /etc/apt/sources.list.d/temp.list