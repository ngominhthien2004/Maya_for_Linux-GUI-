FROM rockylinux:9.3

# Install packages
RUN dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
    alsa-lib \
    audiofile-devel \
    compat-openssl11 \
    dbus \
    e2fsprogs-libs \
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
    qt5-qtbase \
    qt5-qtbase-gui \
    xcb-util \
    xcb-util-image \
    xcb-util-keysyms \
    xcb-util-renderutil \
    xcb-util-wm \
    xorg-x11-fonts-ISO8859-1-100dpi \
    xorg-x11-fonts-ISO8859-1-75dpi \
    zlib \
    tigervnc-server \
    xorg-x11-xinit \
    xterm \
    procps-ng \
    net-tools \
    openbox \
    && \
    dnf clean all && rm -rf /var/cache/dnf

# Continue with the rest...
COPY Autodesk_Maya_2024_2_Update_Linux_64bit /install
WORKDIR /install/Packages

# For Licencing
RUN yum install -y adskflexnetclient-11.18.0-0.x86_64.rpm \
    adlmapps28-28.0.11-0.x86_64.rpm \
    adsklicensing13.0.0.8122-0-0.x86_64.rpm \
    adskflexnetserverIPV6-11.18.0-0.x86_64.rpm

# Maya
RUN yum install -y Maya2024_64-2024.0-4763.x86_64.rpm

# Create required directories with proper permissions
RUN mkdir -p /var/opt/Autodesk/AdskLicensingService && \
    mkdir -p /usr/tmp && \
    chmod -R 777 /var/opt/Autodesk && \
    chmod 777 /usr/tmp

# Create no-root user
RUN adduser user

# Setup VNC for user
RUN mkdir -p /home/user/.vnc && \
    echo "mayavnc" | vncpasswd -f > /home/user/.vnc/passwd && \
    chmod 600 /home/user/.vnc/passwd && \
    chown -R user:user /home/user/.vnc

# VNC startup script - use openbox instead of fluxbox
RUN echo '#!/bin/sh' > /home/user/.vnc/xstartup && \
    echo 'openbox &' >> /home/user/.vnc/xstartup && \
    echo 'xterm &' >> /home/user/.vnc/xstartup && \
    chmod +x /home/user/.vnc/xstartup && \
    chown user:user /home/user/.vnc/xstartup

WORKDIR /home/user

# Copy scripts
COPY maya4docker/start_licensing_service.sh start_licensing_service.sh
RUN sed -i 's/\r$//' start_licensing_service.sh && \
    chmod +x start_licensing_service.sh

# Create license monitoring script
RUN echo '#!/bin/bash' > /usr/local/bin/license_monitor.sh && \
    echo 'LICENSING_SERVICE_PID=$1' >> /usr/local/bin/license_monitor.sh && \
    echo 'echo "[Monitor] Started with licensing service PID: $LICENSING_SERVICE_PID"' >> /usr/local/bin/license_monitor.sh && \
echo 'while true; do' >> /usr/local/bin/license_monitor.sh && \
    echo '  HIGH_CPU_AGENTS=$(ps aux | awk '"'"'/AdskLicensingAgent/ && $3 > 50.0 && !/awk/ {print $2}'"'"')' >> /usr/local/bin/license_monitor.sh && \
    echo '  if [ ! -z "$HIGH_CPU_AGENTS" ]; then' >> /usr/local/bin/license_monitor.sh && \
    echo '    echo "[$(date)] Found high CPU agents, killing..."' >> /usr/local/bin/license_monitor.sh && \
    echo '    for pid in $HIGH_CPU_AGENTS; do' >> /usr/local/bin/license_monitor.sh && \
    echo '      echo "[$(date)] Killing agent PID: $pid"' >> /usr/local/bin/license_monitor.sh && \
    echo '      kill -9 $pid 2>/dev/null' >> /usr/local/bin/license_monitor.sh && \
    echo '    done' >> /usr/local/bin/license_monitor.sh && \
    echo '  fi' >> /usr/local/bin/license_monitor.sh && \
    echo '  if ! ps -p $LICENSING_SERVICE_PID > /dev/null 2>&1; then' >> /usr/local/bin/license_monitor.sh && \
    echo '    echo "[$(date)] WARNING: Licensing service died, restarting..."' >> /usr/local/bin/license_monitor.sh && \
    echo '    pkill -9 AdskLicensingService 2>/dev/null || true' >> /usr/local/bin/license_monitor.sh && \
    echo '    pkill -9 AdskLicensingAgent 2>/dev/null || true' >> /usr/local/bin/license_monitor.sh && \
    echo '    sleep 2' >> /usr/local/bin/license_monitor.sh && \
    echo '    /opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &' >> /usr/local/bin/license_monitor.sh && \
    echo '    LICENSING_SERVICE_PID=$!' >> /usr/local/bin/license_monitor.sh && \
    echo '    echo "[$(date)] Restarted licensing service with PID: $LICENSING_SERVICE_PID"' >> /usr/local/bin/license_monitor.sh && \
    echo '  fi' >> /usr/local/bin/license_monitor.sh && \
    echo '  sleep 10' >> /usr/local/bin/license_monitor.sh && \
    echo 'done' >> /usr/local/bin/license_monitor.sh && \
    chmod +x /usr/local/bin/license_monitor.sh

# Create VNC start script
RUN echo '#!/bin/bash' > /home/user/start_vnc.sh && \
    echo 'echo "========================================="' >> /home/user/start_vnc.sh && \
    echo 'echo "Starting Maya VNC Container with License Fix"' >> /home/user/start_vnc.sh && \
    echo 'echo "========================================="' >> /home/user/start_vnc.sh && \
    echo 'echo "Cleaning up old licensing processes..."' >> /home/user/start_vnc.sh && \
    echo 'pkill -9 AdskLicensingService 2>/dev/null || true' >> /home/user/start_vnc.sh && \
    echo 'pkill -9 AdskLicensingAgent 2>/dev/null || true' >> /home/user/start_vnc.sh && \
    echo 'sleep 2' >> /home/user/start_vnc.sh && \
    echo 'echo "Removing lock files..."' >> /home/user/start_vnc.sh && \
    echo 'rm -f /var/opt/Autodesk/AdskLicensingService/*.lock 2>/dev/null || true' >> /home/user/start_vnc.sh && \
    echo 'rm -f /tmp/*license* 2>/dev/null || true' >> /home/user/start_vnc.sh && \
    echo 'echo "Starting Autodesk Licensing Service..."' >> /home/user/start_vnc.sh && \
echo '/opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &' >> /home/user/start_vnc.sh && \
    echo 'LICENSING_PID=$!' >> /home/user/start_vnc.sh && \
    echo 'echo "Licensing service PID: $LICENSING_PID"' >> /home/user/start_vnc.sh && \
    echo 'echo "Waiting for licensing service to initialize..."' >> /home/user/start_vnc.sh && \
    echo 'sleep 10' >> /home/user/start_vnc.sh && \
    echo 'echo "Registering Maya license..."' >> /home/user/start_vnc.sh && \
    echo '/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register -pk 657P1 -pv 2024.0.0.F -el EN_US -cf /var/opt/Autodesk/Adlm/Maya2024/MayaConfig.pit' >> /home/user/start_vnc.sh && \
    echo 'echo "Verifying license registration..."' >> /home/user/start_vnc.sh && \
    echo '/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list' >> /home/user/start_vnc.sh && \
    echo 'echo "Starting licensing agent monitor..."' >> /home/user/start_vnc.sh && \
    echo '/usr/local/bin/license_monitor.sh $LICENSING_PID >> /tmp/license_monitor.log 2>&1 &' >> /home/user/start_vnc.sh && \
    echo 'echo "Monitor started in background"' >> /home/user/start_vnc.sh && \
    echo 'echo "Starting VNC server..."' >> /home/user/start_vnc.sh && \
    echo 'su - user -c "vncserver :1 -geometry 1920x1080 -depth 24"' >> /home/user/start_vnc.sh && \
    echo 'echo "========================================="' >> /home/user/start_vnc.sh && \
    echo 'echo "VNC Server Started Successfully"' >> /home/user/start_vnc.sh && \
    echo 'echo "========================================="' >> /home/user/start_vnc.sh && \
    echo 'echo "VNC Port: 5901"' >> /home/user/start_vnc.sh && \
    echo 'echo "VNC Password: mayavnc"' >> /home/user/start_vnc.sh && \
    echo 'echo "Resolution: 1920x1080"' >> /home/user/start_vnc.sh && \
    echo 'echo ""' >> /home/user/start_vnc.sh && \
    echo 'echo "Connect using: localhost:5901"' >> /home/user/start_vnc.sh && \
    echo 'echo "========================================="' >> /home/user/start_vnc.sh && \
    echo 'tail -f /dev/null' >> /home/user/start_vnc.sh && \
    chmod +x /home/user/start_vnc.sh

# Set environment
ENV LD_LIBRARY_PATH=/opt/Autodesk/AdskLicensing/13.0.0.8122/AdskLicensingAgent/lib
ENV MAYA_DISABLE_CIP=1
ENV MAYA_DISABLE_CER=1

# Expose VNC port
EXPOSE 5901

# Default command
CMD ["/home/user/start_vnc.sh"]
