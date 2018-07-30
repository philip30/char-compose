
import sys
from collections import Counter

counter = Counter()

for line in sys.stdin:
  counter.update(line.strip().split())

for key, count in sorted(counter.items(), key=lambda x: -x[1]):
  print(key, count)
