FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages including Nginx
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    sudo \
    curl \
    wget \
    unzip \
    vim \
    git \
    openssh-server \
    build-essential \
    python3 \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common \
    lsb-release \
    nginx

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Configure SSH
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "ubuntu:password" | chpasswd && \
    usermod -aG sudo ubuntu && \
    usermod -aG docker ubuntu && \
    mkdir /var/run/sshd && \
    ssh-keygen -A

# Set up Nginx to serve your website
COPY ./PortfolioTest /var/www/html/

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose SSH and HTTP ports
EXPOSE 22 80

# Start Docker daemon, SSH service, and Nginx
CMD ["sh", "-c", "dockerd & service ssh start && service nginx start && tail -f /dev/null"]
