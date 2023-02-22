#!/bin/bash

# lets start with mapping and base position analysis
REF=../ref.fa

for FQZ1 in *_R1.fastq.gz ; do
  BASE=$(echo $FQZ1 | sed 's/_L001_R1.fastq.gz//')
  echo
  echo starting dataset $BASE
  FQZ2=$(echo $FQZ1 | sed 's/_R1/_R2/')
  echo
  echo "Starting Skewer trimmer"
  skewer -f sanger -q 30 -t 8 $FQZ1 $FQZ2
  FQT1=$(echo $FQZ1 | sed 's/.gz/-trimmed-pair1.fastq/')
  FQT2=$(echo $FQZ1 | sed 's/.gz/-trimmed-pair2.fastq/')
  FQM=$(echo $FQZ1 | sed 's/_R1.fastq.gz//')
  echo
  echo "Starting PEAR read merger"
  pear -j16 -f $FQT1 -r $FQT2 -o $FQM
  FQM=${FQM}.assembled.fastq
  BAM=${FQM}.bam
  echo
  echo "BWA aligner"
  bwa mem -t 8 $REF $FQM | samtools sort -@8 -o $BAM -
  rm ${BASE}*fastq
  echo
  echo "Running samtools pileup"
  OUT=$BASE.out
  samtools mpileup -f ../ref.fa -d 99999999999999999 $BAM \
  | tr ',.' '@' \
  | awk -F ' ' '{OFS="\t"}{print $0, "\t" gsub(/@/,"", $5)}' \
  | awk '{OFS="\t"}{print $1,$2,$3,$4,$7}' > $OUT
  echo
  echo dataset $BASE complete
done

# now filter the results
for OUT in *out ; do
  echo $OUT
  awk '$4>200' $OUT \
  | awk '{OFS="\t"} {print $0, $5/$4}' \
  | awk '$6<0.95'
  echo
done > results.txt

