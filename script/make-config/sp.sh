#!/bin/bash
set -e

mkdir -p config/sp
iwslt=data/sp/iwslt2016
kftt=data/sp/kftt
iwsltenar=data/sp/iwslt2016enar

for experiment in bilstm lookup seg-sum seg-avg seg-max seg-conv seg-chargram seg-bilstm join-sum join-avg join-max join-conv join-chargram join-bilstm; do
  # IWSLT
  python3 script/make-config.py \
    --src_lang cs --trg_lang en \
    --train_prefix $iwslt/train.sp \
    --dev_prefix $iwslt/dev2010.sp \
    --test_prefix $iwslt/tst{2010,2011,2012,2013}.sp \
    --dev_ref_prefix corpus/iwslt2016/dev2010.tok \
    --test_ref_prefix corpus/iwslt2016/tst{2010,2011,2012,2013}.tok \
    --output_prefix output/sp/iwslt2016 \
    --countngram $iwslt/train.sp.countngram.cs \
    --test_hyp tst{2010,2011,2012,2013}_hyp \
    --encoder $experiment \
    --name iwslt2016-$experiment \
    --vocab_prefix $iwslt/train.sp.vocab \
    --charvocab_prefix $iwslt/train.sp.charvocab \
    > config/sp/iwslt-$experiment.yaml
  # KFTT
  python3 script/make-config.py \
    --src_lang ja --trg_lang en \
    --train_prefix $kftt/train.sp \
    --dev_prefix $kftt/dev.sp \
    --test_prefix $kftt/test.sp \
    --dev_ref_prefix corpus/kftt/dev.tok \
    --test_ref_prefix corpus/kftt/test.tok \
    --output_prefix output/sp/kftt \
    --countngram $kftt/train.sp.countngram.ja \
    --test_hyp test_hyp \
    --encoder $experiment \
    --name kftt2016-$experiment \
    --vocab_prefix $kftt/train.sp.vocab \
    --charvocab_prefix $kftt/train.sp.charvocab \
    > config/sp/kftt-$experiment.yaml
  python3 script/make-config.py \
    --src_lang ar --trg_lang en \
    --train_prefix $iwsltenar/train.sp \
    --dev_prefix $iwsltenar/dev2010.sp \
    --test_prefix $iwsltenar/tst{2010,2011,2012,2013}.sp \
    --dev_ref_prefix corpus/iwslt2016enar/dev2010.tok \
    --test_ref_prefix corpus/iwslt2016enar/tst{2010,2011,2012,2013}.tok \
    --output_prefix output/sp/iwslt2016enar \
    --countngram $iwsltenar/train.sp.countngram.ar \
    --test_hyp tst{2010,2011,2012,2013}_hyp \
    --encoder $experiment \
    --name iwslt2016enar-$experiment \
    --vocab_prefix $iwsltenar/train.sp.vocab \
    --charvocab_prefix $iwsltenar/train.sp.charvocab \
    > config/sp/iwsltenar-$experiment.yaml

done

