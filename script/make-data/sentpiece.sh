#!/bin/bash

source config.sh

# SP Input
mkdir -p $sp_kftt
mkdir -p $sp_iwslt
mkdir -p $sp_iwsltenar
cat corpus/iwslt2016/train.tok.en corpus/iwslt2016/train.tok.cs > $sp_iwslt/train.spinput
cat corpus/kftt/train.tok.en corpus/kftt/train.tok.ja > $sp_kftt/train.spinput
cat corpus/iwslt2016enar/train.tok.{en,ar} > $sp_iwsltenar/train.spinput

# Train SPM model
$sentpiece/src/spm_train --vocab_size $vocab_size --input $sp_iwslt/train.spinput --model_prefix $sp_iwslt/train.sp
$sentpiece/src/spm_train --vocab_size $vocab_size --input $sp_kftt/train.spinput --model_prefix $sp_kftt/train.sp
$sentpiece/src/spm_train --vocab_size $vocab_size --input $sp_iwsltenar/train.spinput --model_prefix $sp_iwsltenar/train.sp

