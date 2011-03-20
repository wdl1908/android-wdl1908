#!/bin/bash

find . -type f | grep -v template | grep -E '\.png' | xargs rm -f
find . -type f | grep -v template | grep -E '\.svg' | xargs rm -f

