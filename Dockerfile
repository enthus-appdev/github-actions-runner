FROM ghcr.io/actions/actions-runner:2.334.0

RUN sudo apt update -y && \
    sudo apt install -y curl wget rsync && \
    rm -rf /etc/apt/sources.list.d/temp.list