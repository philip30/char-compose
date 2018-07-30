#!/bin/bash
# This script is to prepare sentencepiece data from the tok data

set -e
set -o xtrace

# Settings
source config.sh
# Corpus
iwslt=data/sp/iwslt2016
kftt=data/sp/kftt
iwsltenar=data/sp/iwslt2016enar
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

# IWSLT encoding
python3 script/clean.py corpus/iwslt2016/train.tok.{en,cs} corpus/iwslt2016/train-clean.tok.{en,cs} --max_len $max_len --min_len $min_len
python3 script/clean.py corpus/iwslt2016enar/train.tok.{en,ar} corpus/iwslt2016enar/train-clean.tok.{en,ar} --max_len $max_len --min_len $min_len
python3 script/clean.py corpus/kftt/train.tok.{en,ja} corpus/kftt/train-clean.tok.{en,ja} --max_len $max_len --min_len $min_len


for data in train-clean dev2010 tst2010 tst2011 tst2012 tst2013; do
  $sentpiece/src/spm_encode --model $sp_iwslt/train.sp.model --output $iwslt/$data.sp.en < corpus/iwslt2016/$data.tok.en
  $sentpiece/src/spm_encode --model $sp_iwslt/train.sp.model --output $iwslt/$data.sp.cs < corpus/iwslt2016/$data.tok.cs
  $sentpiece/src/spm_encode --model $sp_iwsltenar/train.sp.model --output $iwsltenar/$data.sp.en < corpus/iwslt2016enar/$data.tok.en
  $sentpiece/src/spm_encode --model $sp_iwsltenar/train.sp.model --output $iwsltenar/$data.sp.ar < corpus/iwslt2016enar/$data.tok.ar
done

for data in train-clean dev test; do
  $sentpiece/src/spm_encode --model $sp_kftt/train.sp.model --output $kftt/$data.sp.en < corpus/kftt/$data.tok.en
  $sentpiece/src/spm_encode --model $sp_kftt/train.sp.model --output $kftt/$data.sp.ja < corpus/kftt/$data.tok.ja
done

mv $iwslt/train-clean.sp.en $iwslt/train.sp.en
mv $iwslt/train-clean.sp.cs $iwslt/train.sp.cs
mv $iwsltenar/train-clean.sp.en $iwsltenar/train.sp.en
mv $iwsltenar/train-clean.sp.ar $iwsltenar/train.sp.ar
mv $kftt/train-clean.sp.en $kftt/train.sp.en
mv $kftt/train-clean.sp.ja $kftt/train.sp.ja

python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp.en > $iwslt/train.sp.vocab.en
python3 script/make-vocab.py --min_count 2 < $iwslt/train.sp.cs > $iwslt/train.sp.vocab.cs
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp.en > $iwslt/train.sp.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwslt/train.sp.cs > $iwslt/train.sp.charvocab.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp.cs > $iwslt/train.sp.countngram.cs
python3 script/count-charngram.py 4 < $iwslt/train.sp.en > $iwslt/train.sp.countngram.en

python3 script/make-vocab.py --min_count 2 < $kftt/train.sp.en > $kftt/train.sp.vocab.en
python3 script/make-vocab.py --min_count 2 < $kftt/train.sp.ja > $kftt/train.sp.vocab.ja
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp.en > $kftt/train.sp.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $kftt/train.sp.ja > $kftt/train.sp.charvocab.ja
python3 script/count-charngram.py 4 < $kftt/train.sp.ja > $kftt/train.sp.countngram.ja
python3 script/count-charngram.py 4 < $kftt/train.sp.en > $kftt/train.sp.countngram.en

python3 script/make-vocab.py --min_count 2 < $iwsltenar/train.sp.en > $iwsltenar/train.sp.vocab.en
python3 script/make-vocab.py --min_count 2 < $iwsltenar/train.sp.ar > $iwsltenar/train.sp.vocab.ar
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwsltenar/train.sp.en > $iwsltenar/train.sp.charvocab.en
python3 script/make-vocab.py --min_count 2 --char_vocab < $iwsltenar/train.sp.ar > $iwsltenar/train.sp.charvocab.ar
python3 script/count-charngram.py 4 < $iwsltenar/train.sp.ar > $iwsltenar/train.sp.countngram.ar
python3 script/count-charngram.py 4 < $iwsltenar/train.sp.en > $iwsltenar/train.sp.countngram.en
