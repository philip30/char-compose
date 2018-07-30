import sys
from collections import Counter

counts = Counter()
for line in sys.stdin:
  counts.update(line.strip().split())

for key, count in sorted(counts.items(), key=lambda x: -x[1]):
  print(key, count)

