FROM quay.io/fedora/fedora-bootc:43

# SETUP FILESYSTEM
RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

#PREPARE PACKAGES
COPY --chmod=0644 ./system/usr_local_share_sway-bootc_packages-removed /usr/local/share/sway-bootc/packages-removed
COPY --chmod=0644 ./system/usr_local_share_sway-bootc_packages-added /usr/local/share/sway-bootc/packages-added
RUN jq -r .packages[] /usr/share/rpm-ostree/treefile.json > /usr/local/share/sway-bootc/packages-fedora-bootc 

# INSTALL REPOS
RUN dnf -y install dnf5-plugins

# INSTALL PACKAGES
RUN grep -vE '^#' /usr/local/share/sway-bootc/packages-added | xargs dnf -y install --allowerasing

# REMOVE PACKAGES
# RUN grep -vE '^#' /usr/local/share/sway-bootc/packages-removed | xargs dnf -y remove
RUN dnf -y autoremove
RUN dnf clean all

# CONFIGURATION
COPY --chmod=0644 ./system/etc_skel_sway-bootc /etc/skel/.bashrc.d/sway-bootc

# USERS
RUN useradd -m -u 1000 -G wheel zpeppler \
  && echo 'zpeppler:password' | chpasswd
RUN echo 'root:password' | chpasswd

# SYSTEMD

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
