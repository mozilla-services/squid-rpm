#!/bin/sh

cd $(dirname $0)
BASE=$PWD

set -e

for d in RPMS SRPMS 
do
    echo $d
    if [ ! -e $d ]; then
        mkdir $d
    fi
done

VERSION=$(awk '/^Version: / {print $2}' $BASE/SPECS/squid.spec)
echo $VERSION
SQUID_ARCHIVE="squid-$VERSION.tar.gz"
SQUID_SIGS="$SQUID_ARCHIVE.asc"

if [ ! -e "$BASE/SOURCES/$SQUID_ARCHIVE" ]; then
    curl --fail "http://www.squid-cache.org/Versions/v3/3.3/$SQUID_ARCHIVE" \
        -o $BASE/SOURCES/$SQUID_ARCHIVE
fi

if [ ! -e "$BASE/SOURCES/$SQUID_SIGS" ]; then
    curl --fail "http://www.squid-cache.org/Versions/v3/3.3/$SQUID_SIGS" \
        -o $BASE/SOURCES/$SQUID_SIGS
fi

# Build the SRPM
if [ ! -e "$BASE/SRPMS/squid-${VERSION}-1.el6.src.rpm" ]; then
    echo "BUILDING SRPM"
    mock --root epel-6-x86_64 \
        --buildsrpm \
        --quiet \
        --spec "$BASE/SPECS/squid.spec" \
        --sources "$BASE/SOURCES/" \
        --resultdir "$BASE/SRPMS/" 
fi

# Build the RPM

if [ ! -e "$BASE/RPMS/squid-${VERSION}-1.el6.x86_64.rpm" ]; then
    echo "BUILDING RPM... be patient this could take a while"
    mock --root epel-6-x86_64 \
        --quiet \
        --resultdir "$BASE/RPMS" \
        "$BASE/SRPMS/squid-${VERSION}-1.el6.src.rpm"
fi
