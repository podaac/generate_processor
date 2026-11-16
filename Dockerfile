# Base OS Patching & Dependencies
FROM perl:5.39-slim-bookworm

# 1. Update, upgrade, install dependencies, and clean cache in one layer
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    tcsh libfreetype6 libxpm4 libxmu6 libidn11-dev \
    procps build-essential iputils-ping curl libxinerama-dev && \
    export ARCH=$(dpkg-architecture -q DEB_HOST_MULTIARCH) && \
    ln -s /usr/lib/$ARCH/libXpm.so.4 /usr/lib/$ARCH/libXp.so.6 && \
    rm -rf /var/lib/apt/lists/*

# 2. Copy Generate code
RUN /bin/mkdir /data
COPY . /app
RUN /bin/chmod +x /app/python/notify.py

# 3. IDL installation
ARG IDL_INSTALLER
ARG IDL_VERSION
RUN /bin/mkdir /root/idl_install \
    && /bin/tar -xf /app/idl/install/$IDL_INSTALLER -C /root/idl_install/ \
    && /bin/cp /app/idl/install/idl_answer_file /root/idl_install/ \
    && /root/idl_install/install.sh -s < /root/idl_install/idl_answer_file \
    && /bin/cp /app/idl/install/lic_server.dat /usr/local/idl/license/ \
    && /bin/ln -s /usr/local/idl/$IDL_VERSION/bin/idl /usr/local/bin \
    && /bin/rm -rf /app/idl/install/$IDL_INSTALLER \
    && /bin/rm -rf /root/idl_install \
    && /bin/rm -rf /app/idl/install \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.eclipse.jgit* \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.apache.sshd.sftp_* \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.eclipse.jetty.* 

# 4. Local Perl Library
RUN /usr/bin/yes | /usr/local/bin/cpan App::cpanminus \
    && /usr/local/bin/cpanm Bit::Vector Date::Calc Bundle::LWP File::NFSLock JSON \
    && rm -rf ~/.cpanm

# 5. Install Python natively (No Ubuntu PPAs) & Purge Build Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv && \
    /usr/bin/python3 -m venv /app/env && \
    /app/env/bin/pip install --no-cache-dir boto3 requests && \
    apt-get purge -y build-essential curl iputils-ping && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

LABEL version="0.1" \
      description="Containerized Generate: Processor"

ENTRYPOINT [ "/bin/tcsh", "/app/shell/ghrsst_seatmp_manager.sh" ]