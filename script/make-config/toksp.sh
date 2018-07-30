#!/bin/bash
set -e

mkdir -p config/toksp
iwslt=data/toksp/iwslt2016
kftt=data/toksp/kftt
iwsltenar=data/toksp/iwslt2016enar
for experiment in bilstm lookup seg-sum seg-avg seg-max seg-conv seg-chargram seg-bilstm join-sum join-avg join-max join-conv join-chargram join-bilstm; do
  # IWSLT
  python3 script/make-config.py \
    --src_lang cs --trg_lang en \
    --train_prefix $iwslt/train.sp \
    --dev_prefix $iwslt/dev2010.sp \
    --test_prefix $iwslt/tst{2010,2011,2012,2013}.sp \
    --dev_ref_prefix corpus/iwslt2016/dev2010.tok \
    --test_ref_prefix corpus/iwslt2016/tst{2010,2011,2012,2013}.tok \
    --output_prefix output/toksp/iwslt2016 \
    --test_hyp tst{2010,2011,2012,2013}_hyp \
    --countngram $iwslt/train.sp.countngram.cs \
    --encoder $experiment \
    --name iwslt2016-$experiment \
    --vocab_prefix $iwslt/train.sp.vocab \
    --charvocab_prefix $iwslt/train.sp.charvocab \
    > config/toksp/iwslt-$experiment.yaml
  # KFTT
  python3 script/make-config.py \
    --src_lang ja --trg_lang en \
    --train_prefix $kftt/train.sp \
    --dev_prefix $kftt/dev.sp \
    --test_prefix $kftt/test.sp \
    --dev_ref_prefix corpus/kftt/dev.tok \
    --test_ref_prefix corpus/kftt/test.tok \
    --output_prefix output/toksp/kftt \
    --test_hyp test_hyp \
    --countngram $kftt/train.sp.countngram.ja \
    --encoder $experiment \
    --name kftt2016-$experiment \
    --vocab_prefix $kftt/train.sp.vocab \
    --charvocab_prefix $kftt/train.sp.charvocab \
    > config/toksp/kftt-$experiment.yaml
  # IWSLT
  python3 script/make-config.py \
    --src_lang ar --trg_lang en \
    --train_prefix $iwsltenar/train.sp \
    --dev_prefix $iwsltenar/dev2010.sp \
    --test_prefix $iwsltenar/tst{2010,2011,2012,2013,2014}.sp \
    --dev_ref_prefix corpus/iwslt2016enar/dev2010.tok \
    --test_ref_prefix corpus/iwslt2016enar/tst{2010,2011,2012,2013}.tok \
    --output_prefix output/toksp/iwslt2016enar \
    --test_hyp tst{2010,2011,2012,2013}_hyp \
    --countngram $iwsltenar/train.sp.countngram.ar \
    --encoder $experiment \
    --name iwslt2016enar-$experiment \
    --vocab_prefix $iwsltenar/train.sp.vocab \
    --charvocab_prefix $iwsltenar/train.sp.charvocab \
    > config/toksp/iwsltenar-$experiment.yaml
done

