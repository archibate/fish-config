FROM ubuntu:latest

ARG HTTP_PROXY
ARG HTTPS_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY

RUN echo 'Acquire::http::Proxy "$HTTP_PROXY";' >> /etc/apt/apt.conf
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt-get clean && apt-get update
RUN apt-get install -y curl

USER ubuntu
RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/home/ubuntu/.opencode/bin:$PATH"
RUN mkdir -p /home/ubuntu/.config/opencode

USER root
RUN apt-get install -y git
RUN apt-get install -y tmux
RUN apt-get install -y python3-dev python3-pip
RUN apt-get install -y nodejs npm
RUN apt-get install -y sudo

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
# RUN printf "#!/usr/bin/bash\necho Operation Denied by User: Please DO NOT use git in this session.\n" > /home/ubuntu/.opencode/bin/git && chmod +x /home/ubuntu/.opencode/bin/git

USER docker
CMD /bin/bash
