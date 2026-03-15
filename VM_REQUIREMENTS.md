# VM Requirements for Inception Project

## Required Software

- **KVM (Kernel-based Virtual Machine)** - version 8.0.0 or higher
- **libvirt** - version 8.0.0 or higher
- **GNOME Boxes** or **virt-manager** (VM management tools)

## System Requirements

- CPU with virtualization support (Intel VT-x / AMD-V)
- `/dev/kvm` must be accessible

## Verification Commands

```bash
# Check KVM is available
kvm-ok

# Check libvirt version
virsh --version

# Check KVM module is loaded
lsmod | grep kvm
```

## Notes

- KVM provides hardware-accelerated virtualization
- Works natively on Linux (no additional VM software needed)
- Compatible with Docker for the Inception project
