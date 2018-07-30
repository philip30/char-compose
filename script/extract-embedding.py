import argparse
import sys

from xnmt.param_collection import ParamManager
from xnmt.persistence import initialize_if_needed, YamlPreloader, LoadSerialized, save_to_file


parser = argparse.ArgumentParser()
parser.add_argument("filename")
parser.add_argument("output_vocab")
parser.add_argument("output_embed")
parser.add_argument("--embedding", choices=["src", "trg"], default="src")
args = parser.parse_args()

ParamManager.init_param_col()
load_experiment = LoadSerialized(
  filename=args.filename,
)

uninitialized_experiment = YamlPreloader.preload_obj(load_experiment, exp_dir="/tmp/dummy", exp_name="dummy")
experiment = initialize_if_needed(uninitialized_experiment)


if args.embedding == "src":
  vocab = experiment.model.src_reader.vocab
  tensor = experiment.model.src_embedder.embeddings
else:
  vocab = experiment.model.trg_reader.vocab
  tensor = experiment.model.trg_embedder.embeddings

with open(args.output_vocab, mode="w") as fp:
  for word in vocab.i2w:
    print(word, file=fp)

with open(args.output_embed, mode="w") as fp:
  for t in tensor.npvalue().transpose():
    print("\t".join(map(str, t)), file=fp)

