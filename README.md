# omnios-image-builder

Sample scripts for driving the illumos
[image-builder](https://github.com/illumos/image-builder) to produce installed
disk images for various distributions.

## Getting Started

You will need `pfexec` to work for your user account.  Generally, you'll
want to have the `Primary Administrator` profile on your account; e.g., via,

```
# usermod -P 'Primary Administrator' jclulow
```

You will need a Rust toolchain.  You can use a distribution package, or install
[rustup](https://rustup.rs/); e.g., via:

```
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash
```

Once you have that, run the setup step to clone and build some of the tools
we're using here:

```
$ ./setup.sh
```

After that, you need to produce a strap archive -- a pre-installed IPS image
that we can transform into various output shapes.  e.g., for OpenIndiana:

```
$ ./strap_oi.sh
```

This will likely take quite some time, as it has to download and install
packages for the whole OS into an alternate root.  The strap archive is built
in three stages, and we can reuse the output of a prior stage in order to avoid
redoing the most expensive parts of the work.  If you want to discard that work
and start from scratch, the strap scripts accept a `-f` flag to do that.  See
the comments in `strap.sh` for more details.

Once you have a strap archive, you can produce the concrete output image of
your choice.  For example, the noconfig images don't include any automatic
cloud metadata-based setup; they have a blank root password you can use
on the console:

```
$ ./noconfig.sh
```

Once that completes, you'll have a raw disk image; e.g.,

```
$ ls -lh /rpool/images/output/noconfig-ttya-openindiana-hipster.raw
-rw-r--r--   1 root     root       1.95G Sep  3 12:48 /rpool/images/output/noconfig-ttya-openindiana-hipster.raw
```

You can provide that image to your hypervisor somehow; e.g., `dd` onto a zvol
or import into `libvirt`, etc.
