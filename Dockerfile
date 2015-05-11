FROM pandastrike/arch_plus
#FROM base/archlinux
MAINTAINER David Harper (david@pandastrike.com)
#===============================================================================
# Panda-Cluster: Hook Server
#===============================================================================
# This Dockerfile does not contain the code for panda-hook.  It describes a server
# that can accept requests from an instance of panda-hook targeting it.

# This Dockerfile describes a hook-server tailored to act upon an app running
# the CoreOS stack.  Hook-servers contain "bare" git repositories with one or
# more githooks, scripts you trigger with git commands.

# Hook-Server & CoreOS Requirements: (1) git, (2) fleetctl
# Install requirements, a couple dependencies, and some tools that make life easier.
# TODO: Uncomment this when we move away from "arch_plus" usage.
#RUN pacman -Syu --noconfirm
#RUN pacman-db-upgrade
#RUN pacman -S --noconfirm git nodejs openssh wget vim tmux
#RUN npm install -g coffee-script

# On Archlinux, fleet is only available as an AUR community package, so we'll have
# to jump through a few extra hoops.  Download the AUR package and place the
# executables into our $PATH.
RUN mkdir aur-packages && cd aur-packages && \
  wget https://github.com/coreos/fleet/releases/download/v0.8.3/fleet-v0.8.3-linux-amd64.tar.gz && \
  tar -xvf fleet-v0.8.3-linux-amd64.tar.gz && \
  cd fleet-v0.8.3-linux-amd64 && \
  mv fleetctl /usr/bin/. && mv fleetd /usr/bin/.

# Clean up the download directory.
RUN rm -rf aur-packages

# Create directories to hold static data.  "files" is one big repository.
RUN mkdir repos && mkdir files
RUN git config --global user.email 'you@example.com' && git config --global user.name 'Your Name'
RUN cd files && git init

# Create directory to hold SSH data
RUN mkdir root/.ssh               && \
  touch root/.ssh/authorized_keys && \
  chmod -R 700 root/.ssh

# Add a configuration file so the hook-server allows agent-forwarding and isn't picky
# about connecting to wherever we ask.
RUN echo "Host *" >> root/.ssh/config                     && \
  echo "  ForwardAgent yes "  >> root/.ssh/config         && \
  echo "StrictHostKeyChecking no" >> root/.ssh/config     && \
  echo "UserKnownHostsFile=/dev/null" >> root/.ssh/config
