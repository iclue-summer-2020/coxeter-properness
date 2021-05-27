#!/usr/bin/env sage
import argparse
import functools
import pathlib
import sys

from tqdm import tqdm
from tqdm.contrib.concurrent import process_map


# Finite families of the finite irreducible Coxeter groups.
TYPES = [
  ['E', 6],
  ['E', 7],
  ['E', 8],
  ['F', 4],
  ['G', 2],
  ['H', 3],
  ['H', 4]
]


def maxw0(W, w):
  '''
  returns maxw_0(W, w) for finite irreducible Coxeter groups.

  W is a Coxeter group.
  w is an element of W.
  '''
  n = W.rank()
  dw = len(w.descents(side='left'))
  t = W.coxeter_type().type()

  if   t == 'A': return binomial(dw+1, 2)
  elif t == 'B': return dw**2
  elif t == 'D': return dw**2-dw if dw > 3 else binomial(dw+1, 2)
  elif t == 'E': return [0,1,3,6,12,20,36,63,120][dw]
  elif t == 'F': return [0,1,4,9,24][dw]
  elif t == 'G': return [0,1,6][dw]
  elif t == 'H': return [0,1,5,15,60][dw]
  elif t == 'I': return n if dw == 2 else dw
  else: raise NotImplementedError('no formula known for type ' + t)


def proper(W, w):
  '''
  returns True if w is proper in W; false otherwise

  W is a Coxeter group.
  w is an element of W.
  '''
  n = W.rank()
  return w.length() <= n + maxw0(W, w)


def reduced_word(w, latex):
  '''
  returns the reduced word of w.

  w is an element of a Coxeter group.
  if latex is True, it will print the word in math LaTex format.
  '''
  rw = w.reduced_word()
  return (
    ''.join(['s_{'+str(s)+'} ' for s in rw])
    if latex else
    ''.join([str(s) for s in rw])
  )


def action(W, latex, w):
  if not proper(W, w): return None
  return reduced_word(w, latex=latex)


def main(args):
  W = CoxeterGroup([args.type, args.n])

  rws = process_map(
    functools.partial(action, W, args.latex),
    W,
    max_workers=args.num_processes,
    chunksize=len(W)//args.num_processes,
  )

  with args.file.open('w') as f:
    for rw in rws:
      if rw is None: continue
      f.write(rw)
      f.write('\n')


if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    'List proper Coxeter group elements for finite families.'
  )
  parser.add_argument(
    '--type', type=str, required=True, help='Coxeter Type',
  )
  parser.add_argument(
    '--file', type=pathlib.Path, required=True, help='File to store results',
  )
  parser.add_argument(
    '--num-processes', type=int, default=1, help='File to store results',
  )
  parser.add_argument(
    '-n', type=int, required=True, help='n',
  )
  parser.add_argument(
    '--latex', action='store_true', help='enables latex pretty printing',
  )
  args = parser.parse_args()
  main(args)
