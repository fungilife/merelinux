#!/bin/bash -e
# shellcheck disable=SC2154,SC1090
. "$CIRCLE_WORKING_DIRECTORY"/.env
if [ -n "$pkg" ] ; then
    pacman -Syu --noconfirm
    . "$pkg"/PKGBUILD
    proposed="${pkgver}-${pkgrel}"
    current="$(pacman -Sl | grep "${pkgname} " | cut -d' ' -f3)"
    if [ "$(printf '%s\n' "$proposed" "$current" | \
            sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4 | \
            tail -n1)" != "$proposed" ]; then
        printf "The proposed version '%s' appears to be less \
than the current version '%s'\n" "$proposed" "$current"
        exit 1
    fi
    install -d /mere/logs /mere/sources
    cd "$pkg"
    sed -i '/MAKEFLAGS=/s@=.*@=@' /etc/makepkg.conf
    makepkg -Ls --noconfirm
    if [ "$(git rev-parse --abbrev-ref HEAD)" = 'master' ]; then
        makepkg --allsource
        mv ./*.src.tar.xz /tmp/staging
    fi
else
    printf 'No packages are required to build in this commit.\n'
fi
