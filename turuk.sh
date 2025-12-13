#!/bin/bash
tar -xzf turuk-profile.tar.gz -C /
apt update
apt install -y $(cat /turuk-profile/packages.txt)
update-grub
update-initramfs -u
