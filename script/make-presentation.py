import argparse
import os
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument("--input_configs", type=str, nargs="+", required=True)
args = parser.parse_args()

class LogFile(object):
  def __init__(self, name, training, checkpoints, final):
    self.name = name
    self.training = training
    self.checkpoints = checkpoints
    self.final = final
    self.process()

  @staticmethod
  def from_file(file_inp):
    if not os.path.exists(file_inp):
      return None
    with open(file_inp) as fp:
      checkpoints = []
      training = []
      final = []
      name = None
      state = -1
      for line in fp:
        line = line.strip()
        if name is None and line.startswith("["):
          name = line.strip().split()[0][1:-1]
        if line.startswith("> Training"):
          state = 0
        elif line.startswith("> Checkpoint"):
          checkpoint = []
          state = 1
        elif line.startswith("> Performing final evaluation"):
          state = 2
        elif state == 0:
          training.append(line)
        elif state == 1:
          checkpoint.append(line)
          if "checkpoint took" in line:
            state = 0
            checkpoints.append(checkpoint)
        elif state == 2:
          final.append(line)
    return LogFile(name, training, checkpoints, final)

  def process(self):
    i = 0
    scores = defaultdict(list)
    for i in range(len(self.final)):
      if self.final[i].startswith("---------"):
        break
    for line in self.final[i+1:]:
      line = line.split(" | ")[-1]
      cols = line.split(" ")
      if cols[0] == "|":
        cols = cols[1:]
      key = cols[0][:-1]
      val = cols[1]

      if key == "Loss": continue
      try:
        val = float(val)
      except:
        val = float(val[:-1])
      scores[key].append(val)
    if "BLEU4" in scores:
      scores["BLEU4"] = [100*x for x in scores["BLEU4"]]
    self.scores = scores

logfiles = []
for f in args.input_configs:
  logfiles.append(LogFile.from_file(f))

logfiles = filter(lambda x: x is not None, logfiles)

for logfile in logfiles:
  out = []
  out.append(logfile.name)
  for key in (logfile.scores):
    out.extend(["%.4f" % (x) for x in logfile.scores[key]])
  print(" ".join(map(str,out)))



