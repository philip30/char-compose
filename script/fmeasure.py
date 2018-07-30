
import sys
import argparse
from collections import Counter, defaultdict

parser = argparse.ArgumentParser()
parser.add_argument("count_vocab")
parser.add_argument("src")
parser.add_argument("ref")
parser.add_argument("hyp")
parser.add_argument("ref_align")
parser.add_argument("hyp_align")
parser.add_argument("--min_length", type=int, default=1)
parser.add_argument("--max_count", type=int, default=1e6)
args = parser.parse_args()

counts = defaultdict(int)
with open(args.count_vocab) as fp:
  for line in fp:
    line = line.strip().split(" ")
    counts[line[0]] = int(line[1])

def to_align_map(align_map):
  ret = defaultdict(set)
  for align in align_map:
    left, right = list(map(int, align.split("-")))
    ret[left].add(right)
  return ret

def count_aligned_long_rare(src, trg, align):
  ret_map = defaultdict(int)
  for trg_i, src_idxs in align.items():
    for src_i in src_idxs:
      if len(src[src_i]) >= args.min_length and counts[src[src_i]] <= args.max_count:
        ret_map[trg[trg_i]] += 1
        break
  return Counter(ret_map)

def f(tp, ref_len, hyp_len):
  if ref_len == 0 or hyp_len == 0:
    return 0
  p = tp / hyp_len
  r = tp / ref_len
  if p == 0 or r == 0:
    return 0
  else:
    return 2*p*r/(p+r)

tps = []
ref_lens = []
hyp_lens = []
with open(args.src) as src_fp, \
     open(args.ref) as ref_fp, \
     open(args.hyp) as hyp_fp, \
     open(args.ref_align) as refalign_fp, \
     open(args.hyp_align) as hypalign_fp:
  for src, ref, hyp, ref_align, hyp_align in zip(src_fp, ref_fp, hyp_fp, refalign_fp, hypalign_fp):
    src = src.strip().split()
    ref = ref.strip().split()
    hyp = hyp.strip().split()
    ref_align = to_align_map(ref_align.strip().split())
    hyp_align = to_align_map(hyp_align.strip().split())
    
    ref_stat = count_aligned_long_rare(src, ref, ref_align)
    hyp_stat = count_aligned_long_rare(src, hyp, hyp_align)
    
    ref_hyp = ref_stat & hyp_stat
    tp = sum(ref_hyp.values())
    ref_len = sum(ref_stat.values())
    hyp_len = sum(hyp_stat.values())

    tps.append(tp)
    ref_lens.append(ref_len)
    hyp_lens.append(hyp_len)

    print(f(tp, ref_len, hyp_len), file=sys.stderr)

tp = sum(tps)
ref_len = sum(ref_lens)
hyp_len = sum(hyp_lens)

print(tp/hyp_len)
print(tp/ref_len)
print(f(tp, ref_len, hyp_len))

