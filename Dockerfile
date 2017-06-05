FROM centos:7

LABEL name="Apache Archiva Repository Manager" \
            vendor="Apache" \
            version="2.2.3"
            
# OpenShift Labels
LABEL io.k8s.description="Apache Archiva Repository Manager" \
      io.k8s.display-name="Apache Archiva Repository Manager"

RUN yum -y install --setopt=tsflags=nodocs java-1.8.0-openjdk-devel.x86_64 maven lsof curl tar && yum clean all

ENV ARCHIVA_VERSION 2.2.3
ENV ARCHIVA_HOME /opt/archiva
ENV ARCHIVA_URL=http://www.nic.funet.fi/pub/mirrors/apache.org/archiva/${ARCHIVA_VERSION}/binaries/apache-archiva-${ARCHIVA_VERSION}-bin.tar.gz

RUN groupadd -r archiva -g 433 && useradd -u 431 -r -g archiva -d /opt/archiva -s /sbin/nologin -c "Archiva user" archiva

# Install the binaries
RUN mkdir -p ${ARCHIVA_HOME} \
  && curl --fail --silent --location --retry 3 \
    ${ARCHIVA_URL} \
  | gunzip \
  | tar x -C /tmp apache-archiva-${ARCHIVA_VERSION}-bin \
  && mv /tmp/apache-archiva-${ARCHIVA_VERSION}-bin/* ${ARCHIVA_HOME}/ \
  && rm -rf /tmp/apache-archiva-${ARCHIVA_VERSION}-bin

ADD scripts /opt/archiva/bin/scripts

RUN chown -R archiva:0 ${ARCHIVA_HOME}
RUN chmod 774 -R ${ARCHIVA_HOME}

USER 431

WORKDIR $ARCHIVA_HOME

CMD ["/opt/archiva/bin/scripts/launch_archiva.sh"]
