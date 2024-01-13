#!/usr/bin/bash
read -p "path to file:" file
cp -L $file tmp/ && rm $file && mv $tmp/file .
