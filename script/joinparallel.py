import sys


f1 = open(sys.argv[1])
f2 = open(sys.argv[2])

for l1, l2 in zip(f1, f2):
  l1 = l1.strip()
  l2 = l2.strip()

  print(l1 + " ||| " + l2)

f1.close()
f2.close()
