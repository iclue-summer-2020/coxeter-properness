import argparse
import logging
import pathlib
import os
import tempfile
from typing import IO, Any, List, Optional, Text, Union

import py7zr
from halo import Halo

from proper import proper
from tqdm import tqdm

logger = logging.getLogger(__name__)
FORMAT = "[%(filename)s:%(lineno)s - %(funcName)20s()] %(message)s"
logging.basicConfig(format=FORMAT)
logger.setLevel(logging.DEBUG)

Word = Any

def validate(W: CoxeterGroup, *, line: Union[str, bytes]) -> Optional[Word]:
  # be careful !!!
  try:
    raw_elements = eval(line)
  except Exception as e:
    logger.error(f"got error for error={e}:\n\t for {line=}")
    return None

  if not isinstance(raw_elements, list) or not all(isinstance(x, int) for x in raw_elements):
    logger.warn(f"dropping invalid {line=}")
    return None

  elements: List[int] = raw_elements
  try:
    return W.from_reduced_word(word=elements)
  except Exception as e:
    logger.warn(f"dropping invalid word w/ {elements=}")
    return None

def process(W: CoxeterGroup, *, in_path: pathlib.Path, out_path: pathlib.Path) -> None:
  with out_path.open(mode='a') as out_file:
    with in_path.open(mode="r") as in_file:
      for raw_line in tqdm(in_file, desc="processing"):
        line: str = raw_line
        if (w := validate(W, line=line)) is None:
          continue

        if not proper(W, w):
          continue

        formatted = ''.join([str(x) for x in w.reduced_word()])
        out_file.write(formatted + '\n')


def main(args: argparse.Namespace) -> None:
    W = CoxeterGroup([args.type, args.n], implementation='permutation')
    out_dir: pathlib.Path = args.out_dir

    with py7zr.SevenZipFile(args.in_file, mode='r') as z:
      spinner = Halo()
      file_infos = sorted(z.list(), key=lambda info: int(info.filename[3:]))
      for info in tqdm(file_infos, desc="iterating over files"):
        file_info: py7zr.FileInfo = info
        with tempfile.TemporaryDirectory() as temp_dirname:
          with Halo(text=f"extracting {file_info.filename}"):
            z.extract(path=temp_dirname, targets=[file_info.filename])
            z.reset()
          
          temp_path = pathlib.Path(f"{temp_dirname}/{file_info.filename}")

          with Halo(text=f"processing {file_info.filename}"):
            out_path = pathlib.Path(f"{out_dir.resolve()}/{file_info.filename}")
            process(W, in_path=temp_path, out_path=out_path)
          
          spinner = Halo(text=f"removing file {temp_path}")
          spinner.start()
        spinner.succeed("finished removing file")
    

if __name__ == '__main__':
  parser = argparse.ArgumentParser(
    'List proper Coxeter group elements for finite families.'
  )
  parser.add_argument(
    '--type', type=str, required=True, help='Coxeter Type',
  )
  parser.add_argument(
    '--in-file', type=pathlib.Path, required=True, help='File to read elements',
  )
  parser.add_argument(
    '--out-dir', type=pathlib.Path, required=True, help='File to store results',
  )
  parser.add_argument(
    '-n', type=int, required=True, help='n',
  )
  args = parser.parse_args()
  main(args)