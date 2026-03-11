FROM rockylinux:9.3

# See https://help.autodesk.com/view/MAYAUL/2024/ENU/?guid=GUID-D2B5433C-E0D2-421B-9BD8-24FED217FD7F for the list of packages to install
# RUN yum update -y
# RUN dnf install -y libnsl
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf install -y epel-release && \
    dnf install -y \
    audiofile-devel \
    compat-openssl11 \
    dbus \
    e2fsprogs-libs \
    flite \
    fontconfig \
    freetype \
    glibc \
    libcap \
    libdrm \
    liberation-fonts-common \
    liberation-mono-fonts \
    liberation-sans-fonts \
    liberation-serif-fonts \
    libICE \
    libmng \
    libnsl \
    libpng15 \
    libSM \
    libX11 \
    libXau \
    libxcb \
    libXcomposite \
    libxcrypt-compat \
    libXcursor \
    libXdamage \
    libXext \
    libXfixes \
    libXi \
    libXinerama \
    libxkbcommon \
    libxkbcommon-x11 \
    libXmu \
    libXp \
    libXpm \
    libXrandr \
    libXrender \
    libXScrnSaver \
    libxshmfence \
    libXt \
    libXtst \
    mesa-libGLU \
    mesa-libGLw \
    nss \
    openssl-libs \
    pciutils-libs \
    qt5 \
    speech-dispatcher \
    xcb-util \
    xcb-util-image \
    xcb-util-keysyms \
    xcb-util-renderutil \
    xcb-util-wm \
    xorg-x11-fonts-ISO8859-1-100dpi \
    xorg-x11-fonts-ISO8859-1-75dpi \
    zlib \
    && \
    dnf clean all && rm -rf /var/cache/dnf

# Install VNC server and window manager
RUN dnf install -y \
    tigervnc-server \
    xfce4-session \
    xfce4-panel \
    xfce4-settings \
    xfwm4 \
    xfdesktop \
    xfce4-terminal \
    supervisor \
    procps-ng \
    novnc \
    python3-websockify \
    && \
    dnf clean all && rm -rf /var/cache/dnf

# See https://help.autodesk.com/view/MAYAUL/2024/ENU/?guid=GUID-E7E054E1-0E32-4B3C-88F9-BF820EB45BE5
COPY Autodesk_Maya_2024_2_Update_Linux_64bit /install
WORKDIR /install/Packages

# For Licencing
RUN yum install -y --disablerepo=epel \
    adskflexnetclient-11.18.0-0.x86_64.rpm \
    adlmapps29-29.0.2-0.x86_64.rpm \
    adsklicensing13.3.1.9694-0-0.x86_64.rpm \
    adskflexnetserverIPV6-11.18.0-0.x86_64.rpm

# Maya
RUN yum install -y --disablerepo=epel Maya2024_64-2024.2-180.x86_64.rpm

# Create necessary directories for licensing
RUN mkdir -p /var/opt/Autodesk/Adlm/Maya2024 && \
    mkdir -p /usr/tmp && \
    chmod 777 /usr/tmp

# Create no-root user
RUN adduser user && \
    echo "user:user" | chpasswd && \
    mkdir -p /home/user/.vnc && \
    chown -R user:user /home/user

WORKDIR /home/user
COPY maya4docker/start_licensing_service.sh start_licensing_service.sh
RUN chmod +x start_licensing_service.sh

# Configure VNC
RUN echo "user" | vncpasswd -f > /home/user/.vnc/passwd && \
    chmod 600 /home/user/.vnc/passwd && \
    chown -R user:user /home/user/.vnc

# Create VNC startup script
RUN echo '#!/bin/bash' > /home/user/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /home/user/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /home/user/.vnc/xstartup && \
    echo 'startxfce4 &' >> /home/user/.vnc/xstartup && \
    chmod +x /home/user/.vnc/xstartup && \
    chown user:user /home/user/.vnc/xstartup

ENV LD_LIBRARY_PATH=/opt/Autodesk/AdskLicensing/13.3.1.9694/AdskLicensingAgent/lib

# Expose VNC port
EXPOSE 5901
# Expose noVNC port
EXPOSE 6080

# Create entrypoint script
COPY maya4docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
