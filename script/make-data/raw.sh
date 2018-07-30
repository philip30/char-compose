#!/bin/bash
# This script is to prepare sentencepiece data from the raw data

set -e
set -o xtrace

# Settings
source config.sh
# Corpus
iwslt=data/raw/iwslt2016
kftt=data/raw/kftt
# Prepare Dirs
if [ -d $iwslt ]; then
  rm -r $iwslt
fi
if [ -d $kftt ]; then
  rm -r $kftt
fi
mkdir -p $iwslt
mkdir -p $kftt
# SP Input
cat corpus/iwslt2016/train.raw.{en,cs} > $iwslt/train.spinput
cat corpus/kftt/train.raw.{en,ja} > $kftt/train.spinput
# Train SPM model
$sentpiece/src/spm_train --vocab_size $vocab_size --input $iwslt/train.spinput --model_prefix $iwslt/train.sp$vocab_size
$sentpiece/src/spm_train --vocab_size $vocab_size --input $kftt/train.spinput --model_prefix $kftt/train.sp$vocab_size
# IWSLT encoding
for lang in en cs; do
  for data in train dev2010 tst2010 tst2011 tst2012 tst2013; do
    $sentpiece/src/spm_encode --model $iwslt/train.sp$vocab_size.model --output $iwslt/$data.sp$vocab_size.$lang < corpus/iwslt2016/$data.raw.$lang
  done
done
python3 script/clean.py $iwslt/train.sp$vocab_size.{en,cs} $iwslt/train.sp$vocab_size.clean.{en,cs} --max_len $max_len
python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.vocab.en
python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.vocab.cs
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.charvocab.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.countngram.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.countngram.en
# KFTT encoding
for lang in en ja; do
  for data in train dev test; do
    $sentpiece/src/spm_encode --model $kftt/train.sp$vocab_size.model --output $kftt/$data.sp$vocab_size.$lang < corpus/kftt/$data.raw.$lang
  done
done
python3 script/clean.py $kftt/train.sp$vocab_size.{en,ja} $kftt/train.sp$vocab_size.clean.{en,ja} --max_len $max_len
python3 script/make-vocab.py --min_count 2 < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.vocab.en
python3 script/make-vocab.py --min_count 2 < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.vocab.ja
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.charvocab.ja
python3 script/count-charngram.py 4 < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.countngram.ja
python3 script/count-charngram.py 4 < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.countngram.en
