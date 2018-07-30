import sys
from string import Template

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--break_line", type=int, nargs="+")
args = parser.parse_args()

table = []
for line in sys.stdin:
  line = line.rstrip("\n").split("\t")
  table.append(line)

def format_table(table):
  lines = []
  for line in table:
    lines.append(" & ".join(line) + r" \\")
  format = ["l", "l"] + ["c" for _ in range(len(table[0])-2)]
  if args.break_line:
    for brk in args.break_line:
      lines[brk] = lines[brk] + r" \hline"

  return "|".join(format), "\n".join(lines)

assert all([len(x) == len(table[0]) for x in table])
template = Template(
r"""
\begin{table*}
  \begin{tabular}{|$TABLE_FORMAT|}
    \hline
    $TABLE_CONTENT
    \hline
    \end{tabular}
\end{table*}
""")

format, content = format_table(table)
print(template.substitute(TABLE_FORMAT=format, TABLE_CONTENT=content).strip())

