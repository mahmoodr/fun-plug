#!/bin/sh

# switch to safe working directory on ramdisk
cd /

# write a log, in case sth goes wrong
FFP_LOG=/mnt/HD_a2/ffp.log
#FFP_LOG=/dev/null
exec >>$FFP_LOG 2>&1

# real path to ffp
FFP_PATH=/mnt/HD_a4/ffp

# where to search for the install tarball
FFP_TARBALL=/mnt/HD_a2/fun_plug.tgz

# setup script (used for ffp on USB disk)
FFP_SETUP_SCRIPT=/mnt/HD_a2/.bootstrap/setup.sh

# rc file path
FFP_RC=/ffp/etc/rc


echo "**** fun_plug script for DNS-323 (2008-08-11 tp@fonz.de) ****"
date


# check for setup script. an example use for this is to load USB
# kernel modules and mount a USB storage device. The script is
# sourced, that means you can change variables, e.g. FFP_PATH to point
# to the USB device.
if [ -x $FFP_SETUP_SCRIPT ]; then
    echo "* Running $FFP_SETUP_SCRIPT ..."
    . $FFP_SETUP_SCRIPT
fi

# create /ffp link
echo "ln -snf $FFP_PATH /ffp"
ln -snf $FFP_PATH /ffp

# install tarball
if [ -r $FFP_TARBALL ]; then
    echo "* Installing $FFP_TARBALL ..."
    mkdir -p $FFP_PATH && tar xzf $FFP_TARBALL -C $FFP_PATH && /ffp/bin/tar xzf $FFP_TARBALL -C $FFP_PATH
    if [ $? -eq 0 ]; then
        echo "* OK"
    fi
    rm $FFP_TARBALL
fi

# suid busybox
if [ -x /ffp/bin/busybox ]; then
    chown root.root /ffp/bin/busybox
    chmod 0755 /ffp/bin/busybox
    chmod u+s /ffp/bin/busybox
fi

# run fun_plug.init, if present
if [ -x /ffp/etc/fun_plug.init ]; then
    echo "* Running /ffp/etc/fun_plug.init ..."
    /ffp/etc/fun_plug.init
fi

# run fun_plug.local, if present
if [ -x /ffp/etc/fun_plug.local ]; then
    echo "* Running /ffp/etc/fun_plug.local ..."
    /ffp/etc/fun_plug.local
fi

# run commands
if [ -x $FFP_RC ]; then
    echo "* Running $FFP_RC ..."
    $FFP_RC
    echo "*  OK"
else
    echo "$FFP_RC: Not found or not executable"
fi
