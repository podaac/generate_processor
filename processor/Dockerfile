# Stage 0 - Create from Perl 5.34.1-slim-buster image and install dependencies
# FROM perl:5.34.1-slim-buster AS stage0
FROM perl:5.34.1-slim-buster
RUN apt update && apt install -y tcsh libfreetype6 libxpm4 libxmu6 libidn11 procps iputils-ping curl libxinerama-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libXpm.so.4.11.0 /usr/lib/x86_64-linux-gnu/libXp.so.6

# Stage 1 - Copy Generate code
# FROM stage0 AS stage1
RUN /bin/mkdir /data
COPY . /app

# Stage 2 - IDL installation
# FROM stage1 AS stage2
RUN /bin/mkdir /root/idl_install \
    && /bin/tar -xf /app/idl/install/$IDL_INSTALLER -C /root/idl_install/ \
    && /bin/cp /app/idl/install/idl_answer_file /root/idl_install/ \
    && /root/idl_install/install.sh -s < /root/idl_install/idl_answer_file \
    && /bin/echo $LICENSE_SERVER > /usr/local/idl/license/lic_server.dat \
    && /bin/ln -s /usr/local/idl/$IDL_VERSION/bin/idl /usr/local/bin

# Stage 3 - Clean up
# FROM stage2 AS stage3
RUN /bin/rm -rf /app/idl/install \
    && /bin/rm -rf /root/idl_install

# Stage 4 - postfix/mailutils setup
# FROM stage3 AS stage4
RUN echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections \
    && echo "postfix postfix/mailname string reporter.generate" | debconf-set-selections \
    && echo "postfix postfix/mailname string reporter.generate.com" | debconf-set-selections \
    && apt install -y postfix \
    && /usr/sbin/postconf -e "inet_interfaces = loopback-only" \
    && /usr/sbin/postconf -e "local_transport = error:local delivery is disabled" \
    && apt install -y mailutils \
    && /usr/bin/mkfifo /var/spool/postfix/public/pickup \
    && /usr/sbin/service postfix restart

# Stage 5 - Execute code
# FROM stage4 AS stage5
LABEL version="0.1" \
    description="Containerized Generate: Processor"
ENTRYPOINT [ "/bin/tcsh", "/app/shell/ghrsst_seatmp_manager.sh" ]