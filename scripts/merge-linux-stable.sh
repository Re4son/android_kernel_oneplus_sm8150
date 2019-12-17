#!/bin/sh

# This is the easiest and fastest way to import "linux-stable" from,
# But remember to change the "-t" (tag) if needed.

git pull https://kernel.googlesource.com/pub/linux-stable.git -t v4.14.149
