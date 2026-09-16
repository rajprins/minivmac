#!/bin/bash
#
# Example on how to build Mini vMac on Macintosh
# https://minivmac.github.io/gryphel-mirror/c/minivmac/options.html


# Clean all old/generated files
rm -rf ./bld
rm -rf ./cfg
rm -rf ./Makefile
rm -rf ./minivmac*
rm -rf ./build
rm setuptool
rm makefilegen

# we need to build the setup tool first
echo "Building setup tool..."


if [ ! -x ./setuptool ]; then
	gcc -o setuptool setup/tool.c
fi

echo "Running setup tool to generate makefile generator..."
./setuptool \
        -n "minivmac-3.8" \
        -e xcd \
        -t mcar \
        -m II \
        -hres 800 \
        -vres 600 \
        -depth 3 \
        -magnify 1 \
        -mf 2 \
        -sound 1 \
        -sss 3 \
        -sony-sum 1 \
        -sony-tag 1 \
        -speed 4 \
        -ta 2 \
        -em-cpu 2 \
        -mem 8M \
        -chr 0 \
        -drc 1 \
        -fullscreen 0 \
        -var-fullscreen 1 \
        -api cco \
        > makefilegen

# generate makefile and build
echo "Generating makefile..."
. ./makefilegen

echo "Building project..."
xcodebuild

