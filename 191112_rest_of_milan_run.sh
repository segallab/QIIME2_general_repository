#!/bin/bash
#SBATCH --job-name=Milan.Elastase.Experiment                                            # Job name
#SBATCH --mail-type=BEGIN,END,FAIL                                                      # Mail events (NONE, BEGIN, END,$
#SBATCH --mail-user=benjamin.wu@nyumc.org,martina.oriano@unimi.it,stefano.aliberti@unimi.it        # Where to send mail
#SBATCH --ntasks=16                                                                     # Run on a single CPU
#SBATCH --mem=64gb                                                                      # Job memory request
#SBATCH --output=serial_test_%j.log                                                     # Standard output and error log
#SBATCH --time=10:00:00                                                                 #time


module add miniconda3/4.6.14
source activate qiime2-2019.10

qiime feature-table summarize \
  --i-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/table.qza \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/table.qzv \
  --m-sample-metadata-file /gpfs/scratch/wub02/projects/milan.elastase.run/map/BX_Sputum_convert.txt

qiime feature-table tabulate-seqs \
  --i-data /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/rep-seqs.qza \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/rep-seqs.qzv

qiime metadata tabulate \
  --m-input-file /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/denoising-stats.qza \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/denoising-stats.qzv

### Quality filter

qiime quality-control exclude-seqs \
  --i-query-sequences  /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/rep-seqs.qza \
  --i-reference-sequences /gpfs/scratch/wub02/projects/milan.elastase.run/greengenes/99_otus.qza \
  --p-method vsearch \
  --p-perc-identity 0.99 \
  --p-perc-query-aligned 0.99 \
  --p-threads 16 \
  --o-sequence-hits /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/hits_quality.qza \
  --o-sequence-misses /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/misses_quality.qza \
  --verbose

qiime feature-table filter-features \
  --i-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/table.qza \
  --m-metadata-file /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/misses_quality.qza \
  --o-filtered-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/no-miss-table-dada2.qza \
  --p-exclude-ids

qiime feature-table summarize \
  --i-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/no-miss-table-dada2_norev.qza \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/no-miss-table-dada2_norev.qzv \
  --m-sample-metadata-file /gpfs/scratch/wub02/projects/milan.elastase.run/map/BX_Sputum_convert.txt

qiime feature-table tabulate-seqs \
  --i-data /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/hits_quality.qza \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/hits_quality.qzv

##### Tree

qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/hits_quality.qza \
  --o-alignment /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_6_Tree/aligned-rep-seqs_quality.qza \
  --o-masked-alignment /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_6_Tree/masked-aligned-rep-seqs_quality.qz$
  --o-tree /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_6_Tree/unrooted-tree_quality.qza \
  --o-rooted-tree /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_6_Tree/rooted-tree_quality.qza

##### Metrics

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_6_Tree/rooted-tree_quality.qza \
  --i-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/no-miss-table-dada2_norev.qza \
  --p-sampling-depth 1000 \
  --m-metadata-file /gpfs/scratch/wub02/projects/milan.elastase.run/map/BX_Sputum_convert.txt  \
  --output-dir /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_7_core_metrics_norev_quality

##### Taxonomy 99%

# 99% Taxanomoy from straight DADA2

qiime feature-classifier classify-sklearn \
  --i-classifier /gpfs/scratch/wub02/projects/milan.elastase.run/greengenes/99_classifier.qza \
  --i-reads /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/hits_quality.qza \
  --o-classification /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_8_taxonomy/taxonomy.qza

qiime taxa barplot \
  --i-table /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_4_DADA2/no-miss-table-dada2.qza \
  --i-taxonomy /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_8_taxonomy/taxonomy.qza \
  --m-metadata-file /gpfs/scratch/wub02/projects/milan.elastase.run/map/BX_Sputum_convert.txt \
  --o-visualization /gpfs/scratch/wub02/projects/milan.elastase.run/QIIME2_8_taxonomy/taxa-bar-plots_norev_quality.qzv
