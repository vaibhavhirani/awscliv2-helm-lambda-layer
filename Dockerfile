# Download the official aws cli Docker image
# see https://hub.docker.com/r/amazon/aws-cli
FROM amazon/aws-cli:2.7.35

RUN mkdir -p /opt
WORKDIR /tmp

#
# Install necessary tools
#

RUN yum update -y \
    && yum install -y zip unzip wget tar gzip \
    && yum clean all

#
# Download Helm v3.15.3 and move to /opt/helm
#

RUN wget https://get.helm.sh/helm-v3.15.3-linux-amd64.tar.gz \
    && tar -zxvf helm-v3.15.3-linux-amd64.tar.gz \
    && mkdir -p /opt/helm \
    && mv linux-amd64/helm /opt/helm/helm \
    && chmod +x /opt/helm/helm \
    && rm -rf linux-amd64 helm-v3.15.3-linux-amd64.tar.gz

#
# Organize AWS CLI for self-contained usage
#

RUN mv /usr/local/aws-cli /opt/awscli \
    && ln -s /opt/awscli/v2/2.*/bin/aws /opt/awscli

#
# Cleanup unnecessary files
#
RUN rm -rf /opt/awscli/v2/2.*/dist/awscli/examples \
    && rm -rf /usr/local/aws-cli/v2/2.*/doc

#
# Test AWS CLI and Helm installation
#

RUN /opt/awscli/aws --version
RUN /opt/helm/helm version


#
# Create the bundle
#

RUN cd /opt \
    && zip --symlinks -r ../layer.zip * \
    && echo "/layer.zip is ready" \
    && ls -alh /layer.zip;

WORKDIR /
ENTRYPOINT [ "/bin/bash" ]
