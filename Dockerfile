# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
FROM perl:5.39-slim-bookworm as stage0
RUN apt update && apt install -y tcsh libfreetype6 libxpm4 libxmu6 libidn11-dev procps build-essential iputils-ping curl libxinerama-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4.11.0 /usr/lib/x86_64-linux-gnu/libXp.so.6

# Stage 1 - Copy Generate code
# FROM stage0 as stage1
RUN /bin/mkdir /data
COPY . /app
RUN /bin/chmod +x /app/python/notify.py

# Stage 2 - IDL installation
# FROM stage1 as stage2
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
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.apache.sshd.sftp_2.6.0.v20210201-2003.jar \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.eclipse.jetty.http_10.0.5.jar \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.eclipse.jetty.io_10.0.5.jar \
    && /bin/rm -rf /usr/local/idl/$IDL_VERSION/bin/bin.linux.x86_64/idlde/plugins/org.eclipse.jetty.server_10.0.5.jar

# Stage 3 - Local Perl Library
# FROM stage2 as stage3
RUN /usr/bin/yes | /usr/local/bin/cpan App::cpanminus \
    && /usr/local/bin/cpanm Bit::Vector \
    && /usr/local/bin/cpanm Date::Calc \
    && /usr/local/bin/cpanm Bundle::LWP \
    && /usr/local/bin/cpanm File::NFSLock \
    && /usr/local/bin/cpanm JSON

# Stage 4 - Install Python
# FROM stage3 as stage4
RUN apt update && apt install -y software-properties-common python3-launchpadlib \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y python3 python3-pip python3-venv \
    && /usr/bin/python3 -m venv /app/env \
    && /app/env/bin/pip install boto3 requests

# Stage 5 - Execute code
# FROM stage4 as stage5
LABEL version="0.1" \
    description="Containerized Generate: Processor"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/ghrsst_seatmp_manager.sh" ]