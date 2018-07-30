import argparse

parser = argparse.ArgumentParser()
parser.add_argument("src")
parser.add_argument("trg")
parser.add_argument("src_out")
parser.add_argument("trg_out")
parser.add_argument("--max_len", type=int, default=50)
parser.add_argument("--min_len", type=int, default=4)
args = parser.parse_args()

src_out = open(args.src_out, mode="w")
trg_out = open(args.trg_out, mode="w")

with open(args.src) as src_fp, open(args.trg) as trg_fp:
  for src, trg in zip(src_fp, trg_fp):
    src_tok = src.strip().split()
    trg_tok = trg.strip().split()

    if args.min_len <= len(src_tok) <= args.max_len and \
       args.min_len <= len(trg_tok) <= args.max_len:
      print(src, end="", file=src_out)
      print(trg, end="", file=trg_out)

src_out.close()
trg_out.close()

