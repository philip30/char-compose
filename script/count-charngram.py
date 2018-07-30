import sys
import argparse
from collections import Counter
from functools import lru_cache

parser = argparse.ArgumentParser()
parser.add_argument("ngram", type=int, default=4)
parser.add_argument("--top", type=int, default=-1)
args = parser.parse_args()

k = args.ngram
counts = Counter()

@lru_cache(maxsize=32000)
def charngram(word):
  ret = Counter()
  for i in range(len(word)):
    for j in range(i+1, min(i+k+1, len(word)+1)):
      ret[word[i:j]] += 1
  return ret


for line in sys.stdin:
  words = line.strip().split()
  for word in words:
    counts.update(charngram(word))
  
for i, (key, count) in enumerate(sorted(counts.items(), key=lambda x: -x[1])):
  if args.top != -1:
    if i == args.top:
      break
  print(key)


