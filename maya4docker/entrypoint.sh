#!/bin/bash

# Create necessary directories
mkdir -p /var/opt/Autodesk/Adlm/Maya2024
mkdir -p /usr/tmp
mkdir -p /var/opt/Autodesk/AdskLicensing

# Copy MayaConfig.pit to the correct location
if [ -f /install/MayaConfig.pit ]; then
    cp /install/MayaConfig.pit /var/opt/Autodesk/Adlm/Maya2024/
fi

# Function to keep licensing service running
keep_licensing_alive() {
    while true; do
        if ! pgrep -f "AdskLicensingService" > /dev/null; then
            echo "Restarting Autodesk Licensing Service..."
            /opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &
        fi
        sleep 30
    done
}

# Start licensing service (as root)
echo "Starting Autodesk Licensing Service..."
/opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &
sleep 5

# Register Maya
echo "Registering Maya 2024..."
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper register \
    -pk 657P1 \
    -pv 2024.0.0.F \
    -el EN_US \
    -cf /var/opt/Autodesk/Adlm/Maya2024/MayaConfig.pit

# List registered products
echo "Checking registered products..."
/opt/Autodesk/AdskLicensing/Current/helper/AdskLicensingInstHelper list

# Start watchdog for licensing service
keep_licensing_alive &

# Start VNC server as user
echo "Starting VNC server..."
su - user -c "vncserver :1 -geometry 1920x1080 -depth 24"

# Start noVNC websockify
echo "Starting noVNC websockify..."
websockify --web /usr/share/novnc/ 6080 localhost:5901 &

# Keep container running
tail -f /dev/null
