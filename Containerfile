FROM quay.io/fedora/fedora-bootc:43

# SETUP FILESYSTEM
RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

#PREPARE PACKAGES
COPY --chmod=0644 ./system/usr_local_share_bootc-min_packages-added /usr/local/share/bootc-min/packages-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/bootc-min/packages-fedora-bootc 

# INSTALL REPOS
RUN dnf -y install dnf5-plugins

# INSTALL PACKAGES
RUN grep -vE '^#' /usr/local/share/bootc-min/packages-added | xargs dnf -y install --allowerasing

# CONFIGURATION
COPY --chmod=0755 ./system/usr_local_bin/* /usr/local/bin/

# USERS
COPY --chmod=0644 ./system/usr_lib_credstore_home.create.admin /usr/lib/credstore/home.create.admin

COPY --chmod=0755 ./scripts/* /tmp/scripts/
RUN /tmp/scripts/config-users
RUN /tmp/scripts/config-authselect && rm -r /tmp/scripts

# SYSTEMD
COPY --chmod=0644 ./systemd/usr_lib_systemd_system_firstboot-setup.service /usr/lib/systemd/system/firstboot-setup.service

RUN systemctl enable firstboot-setup.service

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
