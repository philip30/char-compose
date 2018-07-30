import sys
import argparse
from collections import Counter

parser = argparse.ArgumentParser()
parser.add_argument("--min_count", type=int, default=1)
args = parser.parse_args()

all_words = Counter()
for line in sys.stdin:
  words = line.strip().split()
  for word in words:
    chars = "^"+ word + "$"
    for i in range(len(chars)-2):
      trigram = chars[i:i+3]
      all_words[trigram] += 1

if args.min_count > 1:
  all_words = [key for key, value in all_words.items() if value >= args.min_count]
else:
  all_words = list(all_words.keys())

for word in sorted(all_words):
  print(word)

