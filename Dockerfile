FROM ghcr.io/actions/actions-runner:2.333.1

RUN sudo apt update -y && \
    sudo apt install -y curl wget rsync libatomic1 && \
    rm -rf /etc/apt/sources.list.d/temp.list