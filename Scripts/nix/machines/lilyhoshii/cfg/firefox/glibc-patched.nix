{ glibc }:

# https://thebrokenrail.com/2022/12/31/xfinity-stream-on-linux.html#how-do-i-actually-do-this

glibc.overrideAttrs (old: {
	patches = old.patches ++ [ ./disable-GLIBC_ABI_DT_RELR-check.patch ];
	doCheck = false;
})
