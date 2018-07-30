#!/bin/bash
# This script is to prepare sentencepiece data from the tok data

set -e
set -o xtrace

# Settings
source config.sh
# Corpus
iwslt=data/charword/iwslt2016
iwsltenar=data/charword/iwslt2016enar
kftt=data/charword/kftt
# Prepare Dirs
if [ -d $iwslt ]; then
  rm -r $iwslt
fi
if [ -d $kftt ]; then
  rm -r $kftt
fi
if [ -d $iwsltenar ]; then
  rm -r $iwsltenar
fi
mkdir -p $iwslt
mkdir -p $kftt
mkdir -p $iwsltenar
# SP Input
# IWSLT encoding (Just copy, no sent piece involved
for data in train dev2010 tst2010 tst2011 tst2012 tst2013; do
  cp corpus/iwslt2016/$data.tok.en $iwslt/$data.sp$vocab_size.en
  cp corpus/iwslt2016/$data.tok.cs $iwslt/$data.sp$vocab_size.cs
done
for data in train dev2010 tst2010 tst2011 tst2012 tst2013; do
  cp corpus/iwslt2016enar/$data.tok.en $iwsltenar/$data.sp$vocab_size.en
  cp corpus/iwslt2016enar/$data.tok.ar $iwsltenar/$data.sp$vocab_size.ar
done

python3 script/clean.py $iwslt/train.sp$vocab_size.{en,cs} $iwslt/train.sp$vocab_size.clean.{en,cs} --max_len $max_len
python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.vocab.en
python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.vocab.cs
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.charvocab.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp$vocab_size.clean.cs > $iwslt/train.sp$vocab_size.countngram.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp$vocab_size.clean.en > $iwslt/train.sp$vocab_size.countngram.en
# KFTT encoding
for data in train dev test; do
  cp corpus/kftt/$data.tok.ja $kftt/$data.sp$vocab_size.ja
  cp corpus/kftt/$data.tok.en $kftt/$data.sp$vocab_size.en
done
python3 script/clean.py $kftt/train.sp$vocab_size.{en,ja} $kftt/train.sp$vocab_size.clean.{en,ja} --max_len $max_len
python3 script/make-vocab.py --min_count 2 < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.vocab.en
python3 script/make-vocab.py --min_count 2 < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.vocab.ja
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.charvocab.ja
python3 script/count-charngram.py 4 < $kftt/train.sp$vocab_size.clean.ja > $kftt/train.sp$vocab_size.countngram.ja
python3 script/count-charngram.py 4 < $kftt/train.sp$vocab_size.clean.en > $kftt/train.sp$vocab_size.countngram.en

python3 script/clean.py $iwsltenar/train.sp$vocab_size.{en,ar} $iwsltenar/train.sp$vocab_size.clean.{en,ar} --max_len $max_len
python3 script/make-vocab.py --min_count 2 < $iwsltenar/train.sp$vocab_size.clean.en > $iwsltenar/train.sp$vocab_size.vocab.en
python3 script/make-vocab.py --min_count 2 < $iwsltenar/train.sp$vocab_size.clean.ar > $iwsltenar/train.sp$vocab_size.vocab.ar
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwsltenar/train.sp$vocab_size.clean.en > $iwsltenar/train.sp$vocab_size.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwsltenar/train.sp$vocab_size.clean.ar > $iwsltenar/train.sp$vocab_size.charvocab.ar
python3 script/count-charngram.py 4 < $iwsltenar/train.sp$vocab_size.clean.ar > $iwsltenar/train.sp$vocab_size.countngram.ar
python3 script/count-charngram.py 4 < $iwsltenar/train.sp$vocab_size.clean.en > $iwsltenar/train.sp$vocab_size.countngram.en


