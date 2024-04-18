# Use ubuntu:latest as the base image for amd64 architecture
FROM ubuntu:latest

# Set architecture
ENV ARCH=amd64
ENV ARCHX=x64
ENV NAME=ado-agent-linux
ENV AZP_URL=https://dev.azure.com/hammadhchandio/
ENV AZP_POOL=master-pool

# Set additional environment variables
ENV AGENT_VERSION=${AGENT_VERSION:-3.220.0}
LABEL agent_version=$AGENT_VERSION

# Update and upgrade package lists
RUN DEBIAN_FRONTEND=noninteractive apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get install -y -qq --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        apt-utils \
        iputils-ping \
        curl \
        file \
        git \
        gnupg \
        gnupg-agent \
        locales \
        sudo \
        time \
        unzip \
        wget \
        zip \
        jq \
        netcat \
        software-properties-common \
        build-essential \
        python3 \
        python3-pip \
        dnsutils \
        iputils-ping \
        openssl \
        net-tools \
        lld \
        libcurl4 \
        libxss1 \
        libnss3 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libxkbcommon0 \
        libpango-1.0-0 \
        libcairo2 \
        libatk1.0-0 \
        default-jdk

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash

# Install az extensions
RUN az extension add --name managementpartner

# Install azd
RUN curl -fsSL https://aka.ms/install-azd.sh | bash -s -- -a ${ARCH}

# Install bicep
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-${ARCHX} \
&& chmod a+x ./bicep \
&& mv ./bicep /usr/local/bin/bicep

#  Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt update && apt install terraform

# Install PowerShell core (latest)
RUN response=$(curl -s -L -I -o /dev/null -w '%{url_effective}' https://github.com/PowerShell/PowerShell/releases/latest) \
    && PSLatestVersion=$(basename "$response" | tr -d 'v') \
    && curl -Lo powershell.tar.gz "https://github.com/PowerShell/PowerShell/releases/download/v$PSLatestVersion/powershell-$PSLatestVersion-linux-${ARCHX}.tar.gz" \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    && rm -rf /powershell.tar.gz

# Install poweshell modules
RUN pwsh -c 'Install-Module -Name Az -Scope AllUsers -Force'

# Clean apt-get installation packages
RUN rm -rf /var/lib/apt/lists/* && apt-get clean

# # Copy the .env file into the Docker image
# COPY .env /.env

# # Read variables from .env file and set them as build arguments
# ARG NAME
# ARG AZP_URL
# ARG AZP_POOL

# Set environment variables using build arguments
# ENV NAME=$NAME
# ENV AZP_URL=$AZP_URL
# ENV AZP_POOL=$AZP_POOL

WORKDIR /myagent/

# Download the Agent
RUN curl -LSs "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${ARCHX}-${AGENT_VERSION}.tar.gz" | tar -xz

RUN adduser --disabled-password agent \
    && usermod -aG sudo agent \
    && chown -R agent /myagent \
    && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

COPY ./start.sh ./
RUN chmod +x ./start.sh

USER agent

ENTRYPOINT ["./start.sh"]





# # Set locale
# RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
#     locale-gen

# # Set the default shell to bash for interactive terminals
# ENV SHELL /bin/bash

# # Set the entrypoint
# CMD ["sleep", "infinity"]

