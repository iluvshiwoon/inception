# VM Requirements for Inception Project

## Required Software

- **QEMU** - version 7.0+ (qemu-system-x86_64)
- **libvirt** - version 8.0.0+ (for virsh)
- **Optional**: virt-manager or GNOME Boxes (see notes)

## System Requirements

- CPU with virtualization support (Intel VT-x / AMD-V)
- `/dev/kvm` must be accessible

## Verification Commands

```bash
# Check KVM hardware support
kvm-ok

# Check QEMU version
qemu-system-x86_64 --version

# Check libvirt session connection
virsh --connect qemu:///session list
```

## Installation & Setup

### 1. Create Storage Directory
```bash
mkdir -p ~/vms  # or use /media/kgriset/Nix_Store/vms
```

### 2. Download Debian ISO
```bash
wget -O ~/vms/debian.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso
```

### 3. Create Disk Image
```bash
qemu-img create -f qcow2 ~/vms/inception-vm.qcow2 5G
```

### 4. Run VM (Two Options)

**Option A - Direct QEMU (Recommended)**
```bash
qemu-system-x86_64 \
  -m 512 -smp 1 \
  -hda ~/vms/inception-vm.qcow2 \
  -cdrom ~/vms/debian.iso \
  -boot d \
  -net nic -net user
```

**Option B - With virt-install (clean env required)**
```bash
env -i PATH=/usr/bin:/bin DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR LANG=C virt-install \
  --connect qemu:///session \
  --name inception-vm \
  --ram 512 --vcpus 1 \
  --disk path=~/vms/inception-vm.qcow2,size=5,format=qcow2 \
  --cdrom ~/vms/debian.iso \
  --os-variant debian12 \
  --network network=default \
  --graphics vnc
```

## Notes

- Use `qemu:///session` (not `qemu:///system`) to avoid permission issues
- If GNOME Boxes/virt-install fail with GLIBC errors, use direct `qemu-system-x86_64`
- After installing OS, remove `-cdrom` and `-boot` flags to boot from disk
- For headless: add `-vnc :0` and connect via VNC client to localhost:5900
