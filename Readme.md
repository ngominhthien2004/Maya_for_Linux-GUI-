# Maya for Linux
Autodesk id:
email: 
password: 
## About

This repository contains scripts and instructions to help install and run Autodesk Maya on Linux systems.

For now it only supports Maya 2024 using Docker or Nix.


> **🚨 Help Wanted! 🚨**
>
> We are currently working to package Maya 2026.2 for Linux. If you have experience, ideas, or just want to contribute, **all help is welcome!** Please open an issue or pull request to join the effort.

## How to use it

first, you need to [download](https://manage.autodesk.com/products)  the official Autodesk Maya archive and extract it at the root of this repository.
It should create a folder named `Autodesk_Maya_2024_2_Update_Linux_64bit`.

Then you can either use the Docker or Nix method.

### Docker

Build the docker image:
```sh
docker build -f maya4docker/Dockerfile -t maya:2024.2 .
```

#### Method 1: Direct X11 forwarding (Linux Only)

⚠️ **This method only works on Linux hosts with X11.**

**For Windows users:** You can use this method with WSL2 + X Server:
1. Install WSL2 with Docker Desktop
2. Install an X Server on Windows: [VcXsrv](https://sourceforge.net/projects/vcxsrv/), [Xming](http://www.straightrunning.com/XmingNotes/), or [X410](https://x410.dev/)
3. Start X Server with "Disable access control" option
4. **Set DISPLAY in WSL terminal:**
   ```sh
   # Get Windows host IP from WSL
   export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
   
   # Or manually set it (replace with your Windows IP)
   export DISPLAY=172.x.x.x:0.0
   
   # Verify it's set
   echo $DISPLAY
   ```
   
   To make it permanent, add to `~/.bashrc` or `~/.zshrc`:
   ```sh
   echo 'export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk "{print \$2}"):0.0' >> ~/.bashrc
   source ~/.bashrc
   ```

5. **Make sure X Server is running on Windows**, then run in WSL:
   ```sh
   # Override entrypoint to use X11 instead of VNC
   docker run \
       -ti \
       --rm \
       -e DISPLAY=$DISPLAY \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       --entrypoint /bin/bash \
       maya:2024.2
   ```
   
   Then inside container:
   ```sh
   # Start licensing service
   /opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &
   sleep 3
   
   # Run Maya as user with X11
   su - user -c "maya"
   ```
   
   **Note:** If X11 forwarding doesn't work, check:
   - X Server is running on Windows with "Disable access control"
   - Windows Firewall allows connections on port 6000
   - Try testing with a simple app first: `su - user -c "xeyes"` or `su - user -c "xclock"`

**For native Linux:**
```sh
xhost +
docker run \
    -ti \
    --rm \
    --network host \
    -e DISPLAY=${DISPLAY} \
    -e XDG_RUNTIME_DIR=/tmp/runtime-user \
    --device /dev/dri:/dev/dri \
    -v /run/user/$(id -u):/tmp/runtime-user \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --entrypoint /bin/bash \
    maya:2024.2
```

Then inside container:
```sh
# Start licensing service
/opt/Autodesk/AdskLicensing/Current/AdskLicensingService/AdskLicensingService --run &
sleep 3

# Run Maya as user
su - user -c "maya"
```

#### Method 2: VNC (Easiest for Windows / macOS / Remote Access)

Run the container with VNC:
```sh
docker run \
    -d \
    --name maya-vnc \
    -p 5901:5901 \
    maya:2024.2
```

Connect to VNC:
- VNC Server: `localhost:5901` (or your server IP)
- Password: `user`
- You can use any VNC client (TigerVNC, TightVNC, RealVNC, etc.)

Once connected via VNC:
1. Open terminal in XFCE
2. Run Maya:
   ```sh
   maya
   ```

To stop the container:
```sh
docker stop maya-vnc
docker rm maya-vnc
```

To view logs:
```sh
docker logs maya-vnc
```

### Nix

First, you need to set the path to the extracted Maya archive in `maya4nix/flake.nix`

Then you can run Maya and the licensing service with:

```sh
cd maya4nix
NIXPKGS_ALLOW_INSECURE=1 nix run --impure .#adskLicensingService -- --run&
NIXPKGS_ALLOW_INSECURE=1 nix run --impure .#maya 
```

Remark:
- The first time, you need to register maya. After starting the licensing service, run: `NIXPKGS_ALLOW_INSECURE=1 nix run --impure .#adskLicensingInstHelper -- register -pk 657P1 -pv 2024.0.0.F -el EN_US -cf /path/to/Autodesk_Maya_2024_2_Update_Linux_64bit/MayaConfig.pit`
- For the licensing service to run, you need to have a folder `/var/opt/Autodesk` writable by your user.
- For Maya to start, you need to have a folder `/usr/tmp` writable by your user.
- the insecure option is because of openssl-1.1.1, needed by Maya
- To check that maya was register, run `NIXPKGS_ALLOW_INSECURE=1 nix run --impure .#adskLicensingInstHelper list`
- You can also start a development shell with `NIXPKGS_ALLOW_INSECURE=1 nix develop --impure` and run `maya2024` and `AdskLicensingService13` commands directly.