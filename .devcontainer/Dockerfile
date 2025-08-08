FROM ubuntu:24.04

RUN apt-get update && \
    apt-get -y install vim wget sudo git 

# User account
ENV USER=ubuntu

# Setup default user
RUN echo "$USER:ubuntu" | chpasswd && adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/$USER
USER $USER

