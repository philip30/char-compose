import sys
import argparse
import os

from string import Template

parser = argparse.ArgumentParser()
parser.add_argument("--src_lang", required=True)
parser.add_argument("--trg_lang", required=True)
parser.add_argument("--train_prefix", required=True)
parser.add_argument("--dev_prefix", required=True)
parser.add_argument("--test_prefix", nargs="+", required=True)
parser.add_argument("--dev_ref_prefix", required=True)
parser.add_argument("--test_ref_prefix", nargs="+", required=True)
parser.add_argument("--test_hyp", required=True, nargs="+")
parser.add_argument("--vocab_prefix", required=True)
parser.add_argument("--charvocab_prefix", required=True)
parser.add_argument("--output_prefix", required=True)
parser.add_argument("--countngram")
parser.add_argument("--chargram_ngram_size", default="4")
parser.add_argument("--encoder", choices=["bilstm",  "lookup",
                                          "seg-sum", "seg-avg", "seg-max", "seg-bilstm", "seg-conv", "seg-chargram",
                                          "join-sum", "join-max", "join-bilstm", "join-avg", "join-conv", "join-chargram"],
                                 required=True)
parser.add_argument("--name", required=True)
parser.add_argument("--post_process", default="join-piece")
parser.add_argument("--reader_trigram", action="store_true")
args = parser.parse_args()

template = Template("""
$NAME: !Experiment
  exp_global: !ExpGlobal
    model_file: $OUTPUT_PREFIX/{EXP}/mod
    log_file: $OUTPUT_PREFIX/{EXP}/log
    default_layer_dim: 512
    dropout: 0.5
  train: !SimpleTrainingRegimen
    batcher: !WordTrgSrcBatcher
      words_per_batch: 2048
    run_for_epochs: 45
    restart_trainer: True
    lr_decay: 0.5
    lr_decay_times: 3
    trainer: !AdamTrainer {}
    src_file: $SRC_TRAIN
    trg_file: $TRG_TRAIN
    dev_tasks:
      - !LossEvalTask
        src_file: $SRC_DEV
        ref_file: $TRG_DEV
      - !AccuracyEvalTask
        eval_metrics: bleu
        src_file: $SRC_DEV
        ref_file: $REF_DEV   
        hyp_file: $OUTPUT_PREFIX/{EXP}/dev_hyp
  evaluate:
    $EVALUATE 
  model: !DefaultTranslator
    src_reader: $SRC_READER
      vocab: !Vocab
        vocab_file: $SRC_VOCAB
    trg_reader: !PlainTextReader
      vocab: !Vocab
        vocab_file: $TRG_VOCAB
    $ENCODER
    inference: !AutoRegressiveInference
      search_strategy: !BeamSearch
        beam_size: 5
        len_norm: !PolynomialNormalization
          apply_during_search: true
      $POST_PROCESS
""")

def evaluate():
  ret = []

  template = Template("""
    - !AccuracyEvalTask
      eval_metrics: bleu
      src_file: $SRC_FILE
      ref_file: $REF_FILE
      hyp_file: $OUTPUT_PREFIX/{EXP}/$HYP_FILE
    - !LossEvalTask
      src_file: $SRC_FILE
      ref_file: $TRG_FILE
  """)

  for test_file, ref_file, test_hyp in zip(args.test_prefix, args.test_ref_prefix, args.test_hyp):
    ret.append(template.substitute(SRC_FILE=test_file+"."+args.src_lang,
                                   TRG_FILE=test_file+"."+args.trg_lang,
                                   REF_FILE=ref_file+"."+args.trg_lang,
                                   HYP_FILE=test_hyp,
                                   OUTPUT_PREFIX=args.output_prefix).rstrip())
  return "".join(ret) 
  
def src_reader():
  if args.encoder == "bilstm":
    return "!PlainTextReader"
  else:
    if args.reader_trigram:
      return "!TrigramFromWordTextReader"
    else:
      return "!CharFromWordTextReader"

preseg_template = Template("""
    encoder: !SegmentingSeqTransducer
      $SEGMENT_COMPOSER
      final_transducer: !BiLSTMSeqTransducer {}
""")

def compose():
  src_vocab = args.vocab_prefix + "." + args.src_lang
  if args.encoder == "seg-avg":
    return """
      segment_composer: !AverageComposer {}
      """
  elif args.encoder == "seg-sum":
    return """
      segment_composer: !SumComposer {}
      """
  elif args.encoder == "seg-max":
    return """
      segment_composer: !MaxComposer {}
      """
  elif args.encoder == "seg-bilstm":
    return """
      segment_composer: !SeqTransducerComposer
        seq_transducer: !BiLSTMSeqTransducer {}
      """
  elif args.encoder == "seg-conv":
    return """
      segment_composer: !ConvolutionComposer
        ngram_size: 4
      """
  elif args.encoder == "seg-chargram":
    return Template("""
      segment_composer: !CharNGramComposer
        word_vocab: !Vocab
          vocab_file: $COUNT_NGRAM
        ngram_size: $NGRAM_SIZE
      """).substitute(COUNT_NGRAM=args.countngram, NGRAM_SIZE=args.chargram_ngram_size)
  elif args.encoder == "lookup":
    return """
      segment_composer: !LookupComposer
        word_vocab: !Vocab
          vocab_file: %s
    """ % (src_vocab)
  elif args.encoder == "join-avg":
    return """
      segment_composer: !SumMultipleComposer
        composers:
        - !AverageComposer {}
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: "%s"
    """ % (src_vocab)
  elif args.encoder == "join-sum":
    return """
      segment_composer: !SumMultipleComposer
        composers:
        - !SumComposer {}
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: %s
    """ % (src_vocab)
  elif args.encoder == "join-max":
    return """
      segment_composer: !SumMultipleComposer
        composers:
        - !MaxComposer {}
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: %s
    """ % (src_vocab)
  elif args.encoder == "join-conv":
    return Template("""
      segment_composer: !SumMultipleComposer
        composers:
        - !ConvolutionComposer
          ngram_size: 4
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: $SRC_VOCAB
    """).substitute(SRC_VOCAB=src_vocab)
  elif args.encoder == "join-chargram":
    return Template("""
      segment_composer: !SumMultipleComposer
        composers:
        - !CharNGramComposer
          word_vocab: !Vocab
            vocab_file: $COUNT_NGRAM
          ngram_size: $NGRAM_SIZE
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: $SRC_VOCAB
    """).substitute(COUNT_NGRAM=args.countngram,
                    SRC_VOCAB=src_vocab,
                    NGRAM_SIZE=args.chargram_ngram_size)
  elif args.encoder == "join-bilstm":
    return """
      segment_composer: !SumMultipleComposer
        composers:
        - !SeqTransducerComposer
          seq_transducer: !BiLSTMSeqTransducer {}
        - !LookupComposer
          word_vocab: !Vocab
            vocab_file: %s
    """ % (src_vocab)

def encoder():
  "bilstm, seg-sum, seg-avg, seg-max, seg-bilstm, seg-conv, seg-chargram"
  if args.encoder == "bilstm":
    return """
    encoder: !BiLSTMSeqTransducer {}
    """
  else:
    return preseg_template.substitute(SEGMENT_COMPOSER=compose().strip())

def src_vocab():
  if args.encoder == "bilstm":
    return args.vocab_prefix+"."+args.src_lang
  else:
    return args.charvocab_prefix+"."+args.src_lang

def post_process(value):
  if value and len(value) != 0:
    return "post_process: %s" % (value)
  return ""

print(template.substitute(
  NAME=args.name.strip(),
  OUTPUT_PREFIX=args.output_prefix,
  SRC_TRAIN=args.train_prefix+"."+args.src_lang,
  TRG_TRAIN=args.train_prefix+"."+args.trg_lang,
  SRC_DEV=args.dev_prefix+"."+args.src_lang,
  TRG_DEV=args.dev_prefix+"."+args.trg_lang,
  REF_DEV=args.dev_ref_prefix+"."+args.trg_lang,
  SRC_READER=src_reader(),
  SRC_VOCAB=src_vocab(),
  TRG_VOCAB=args.vocab_prefix+"."+args.trg_lang,
  EVALUATE=evaluate().strip(),
  ENCODER=encoder().strip(),
  POST_PROCESS=post_process(args.post_process),
).strip())

