FROM ubuntu:xenial

RUN apt-get update &&\
    apt-get install -y wget curl git jq zip

### CF CLI ###
RUN wget "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" -O - | tar zxvf - cf &&\
    install -m 755 ./cf /usr/local/bin/ &&\
    rm ./cf

### BOSH CLI v2 ###
RUN apt-get install -y build-essential zlibc zlib1g-dev libssl-dev libreadline-dev
RUN curl -vL https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-`curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest | jq -r .name | tr -d 'v'`-linux-amd64 -o /usr/local/bin/bosh &&\
    chmod +x /usr/local/bin/bosh

### Ruby ###
WORKDIR /root
RUN git clone https://github.com/riywo/anyenv $HOME/.anyenv &&\
    echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> $HOME/.profile &&\
    echo 'eval "$(anyenv init -)"' >> $HOME/.profile &&\
    . $HOME/.profile &&\
    anyenv install rbenv &&\
    . $HOME/.profile &&\
    rbenv install 2.4.1 &&\
    rbenv global 2.4.1 &&\
    gem install bundler --no-ri --no-rdoc

### UAA CLI ###
RUN . $HOME/.profile &&\
    gem install cf-uaac --no-ri --no-rdoc

### Concourse CLI ###
RUN curl -vL https://github.com/concourse/concourse/releases/download/`curl -s https://api.github.com/repos/concourse/concourse/releases/latest | jq -r .tag_name`/fly_linux_amd64 -o /usr/local/bin/fly &&\
    chmod +x /usr/local/bin/fly

### Minio CLI ###
RUN curl -vL https://dl.minio.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc &&\
    chmod +x /usr/local/bin/mc

### Vault ###
#TODO#

### safe (a Vault CLI) ###
#TODO#
#RUN curl -vL https://github.com/starkandwayne/safe/releases/download/`curl -s https://api.github.com/repos/starkandwayne/safe/releases/latest | jq -r .tag_name`/safe-linux-amd64 -o /usr/local/bin/safe &&\
#    chmod +x /usr/local/bin/safe

### genesis ###
#TODO#
#see... http://www.starkandwayne.com/blog/using-genesis-to-deploy-cloud-foundry/

### CF CLI plugins ###
RUN cf install-plugin -f -r CF-Community update-cli

### additional tools ###
RUN apt-get install -y vim tmux tree pwgen

### create workspace directory ###
RUN mkdir /work
WORKDIR /work

ENTRYPOINT ["/bin/bash", "--login"]
