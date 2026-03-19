FROM ghcr.io/actions/actions-runner:2.333.0

RUN sudo apt update -y && \
    sudo apt install -y curl wget git-all rsync && \
    rm -rf /etc/apt/sources.list.d/temp.list