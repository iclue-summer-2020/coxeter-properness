#!/usr/bin/env bash

export LD_LIBRARY_PATH="/data/keeling/a/davidb2/software/Python-3.6.9/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/sw/gcc-9.3.0/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/sw/gcc-9.3.0/lib:$LD_LIBRARY_PATH"
# export LD_PRELOAD="/sw/gcc-9.3.0/lib64/libcc1.so"
export PATH="/data/keeling/a/davidb2/software/sage-9.3:$PATH"
export PATH="/data/keeling/a/davidb2/software/sage-9.3/src/bin:$PATH"
export PATH="/data/keeling/a/davidb2/software/Python-3.6.9/bin:$PATH"

set -e
set -x

srun \
  --time=120:00:00 \
  --nodes=1 \
  --ntasks-per-node=1 \
  --cpus-per-task=12 \
  --mem-per-cpu=4096 \
  --partition=node \
  --pty \
  /usr/bin/env bash


# export LD_PRELOAD="/sw/gcc-9.3.0/lib64/libcc1.so"
# /data/keeling/a/davidb2/software/sage-9.3/sage proper.sage --type=E -n=8 --num-processes=12 --file=data/E8.txt
