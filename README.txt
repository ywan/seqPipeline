This is a pipeline for analyzing the RNAseq data for the emm59 project.  The whole process include de-duplicate the reads -> filter out reads contain certain kmer -> mapping and getting expression level for each gene -> normalized the expression level -> transform to log2 ratio

1. uniq_reads.pl: This script helps remove duplicated reads in dataset, type perl uniq_reads.pl -h for more help:
Example: perl uniq_reads.pl -i ~/FASTQ/ -o ~/FASTQ/uniq/ -f filter.fq

2. filter_kmer.pl: This script helps remove reads contain specific kmer. Type perl filter_kmer.pl -h for more help:
Example: perl filter_kmer.pl -i test/ -o test/ -f uniq.fq -s AGCAAACCGTCCTC

3. mapping_result.sh: This script does the mapping and annotating, generating a gene_summary.txt containing read counts, and a read_summary.txt containing the total reads/mapped reads for each strain, type sh mapping_result.sh -h for more help:
Example: sh mapping_result.sh -i FASTQ/ -o FASTQ/mapping/ -f filter.uniq.fq -r ~/reference/MGAS15252Ref.fasta -a ~/annotation/gene.bed

4. (optional) compileTable.pl: This script generate gene_summary.txt and reads_summary.txt from seperate summary file.  Excuting this script is contained in the mapping_result.sh, but can be used seperately.  Type perl compileTable.pl -h for more help
Example: perl compileTable.pl -i test/ -o test/ -f filter.uniq.fq.summary.txt

5. (optional) normalized.pl: This script Normalized the read counts in gene_summary by divide gene counts by the total reads in each strain, and muliple a constant.  Excuting this script is contained in the mapping_result.sh, but can be used seperately.  Type perl normalized.pl -h for more help.
Example: perl normalized.pl -i ~/test/ -o ~/test/Normalized_gene.txt

6. (optional) log2Genes.R This is an R script used to transform the normalized read counts to a log2 ratio relative to the first strain, contained in mapping_result.sh, but can be used seperately.Example: Rscript log2Genes.R input.txt output.txt 
