FROM ubuntu:18.04

# Change default shell for RUN from Dash to Bash
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# COnfigure environment
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci && \
	echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci && \
	apt-get update && apt-get install -y locales && \
	locale-gen en_US.UTF-8 && \
	rm -rf /var/lib/apt/lists/*

ENV PATH=/home/circleci/bin:/home/circleci/.local/bin:$PATH \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
		autoconf \
		build-essential \
		ca-certificates \
		curl \
		git \
		gnupg \
		gzip \
		jq \
		groff \
		# popular DB lib - MariaDB
		libmariadb-dev \
		# allows MySQL users to use MariaDB lib
		libmariadb-dev-compat \
		# popular DB lib - PostgreSQL
		libpq-dev \
		make \
		# for ssh-enabled builds
		nano \
		net-tools \
		netcat \
		openssh-client \
		parallel \
		software-properties-common \
		sudo \
		tar \
		tzdata \
		unzip \
		# for ssh-enabled builds
		vim \
		wget \
		zip && \
	rm -rf /var/lib/apt/lists/*

# Install Docker - needs the setup_remote_docker CircleCI step to work
ENV DOCKER_VERSION 5:19.03.13~3-0~ubuntu-
RUN apt-get update && apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
	add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
	apt-get install -y docker-ce=${DOCKER_VERSION}$(lsb_release -cs) docker-ce-cli=${DOCKER_VERSION}$(lsb_release -cs) containerd.io && \
	# Quick test of the Docker install
	docker --version && \
	rm -rf /var/lib/apt/lists/*

# Install Docker Compose - see prerequisite above
ENV COMPOSE_VERSION 1.27.3
RUN curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose && \
	# Quick test of the Docker Compose install
	docker-compose version

RUN apt-get update
RUN apt-get install ruby-full
RUN gem install aptible-cli -v 0.16.7

# install node
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs
RUN rm -rf nodesource_setup.sh
RUN npm install -g yarn
RUN npm install -g jira-connector
RUN npm install -g shelljs
RUN npm install -g lerna
RUN npm install -g npm-run-all

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Match the default CircleCI working directory
WORKDIR /home/circleci/project