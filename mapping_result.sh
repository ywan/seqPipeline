## specifying data directory
print_help () 
{
echo "This script automatically run the mapping and read counting steps"
echo "-h help"
echo "-i input file DIRECTORY"
echo "-f input file suffix, e.s filter.uniq.fq"
echo "-o output file DIRECTORY"
echo "-r reference genome file location"
echo "-a annotation file location"
echo "Example: sh mapping_result.sh -i FASTQ/ -o FASTQ/mapping/ -f filter.uniq.fq -r ~/reference/MGAS15252Ref.fasta -a ~/annotation/gene.bed"
}

if [ $# -lt 3 ]; then
print_help
exit 1
fi

while getopts "hi:f:o:r:a:" opt
do
case "$opt" in
h) print_help; exit 1
;;
i) inputdir=$OPTARG
;;
f) suffix=$OPTARG
;;
o) outputdir=$OPTARG
;;
r) ref=$OPTARG
;;
a) ann=$OPTARG
;;
\?) print_help; exit 1
;;
	esac
done


for data in `ls  $inputdir`
do
	if [[ "$data" =~ ${suffix}$ ]]; then
  infile=$data
  IFS='.'
  namearry=($data)
  strain=${namearry[0]}
  data=$infile
  IFS=$'\t'
  ## mapping
  bwa aln $ref ${inputdir}${infile} > ${outputdir}${data}.sai
  bwa samse $ref ${outputdir}${data}.sai ${inputdir}${infile} > ${outputdir}${data}.sam

  samtools view -Sb ${outputdir}${data}.sam > ${outputdir}${data}.bam
  samtools sort ${outputdir}${data}.bam ${outputdir}${data}_sorted 
  samtools index ${outputdir}${data}_sorted.bam 

  mapped=`samtools view -F 4 ${outputdir}${data}_sorted.bam|wc -l` ## mapped reads
  uniq_map=`samtools view -F 4 -q 1 ${outputdir}${data}_sorted.bam|wc -l`  ## uniquely mapped reads
  total_reads=`samtools view ${outputdir}${data}_sorted.bam|wc -l` ## total reads

  echo $strain "summary" > ${outputdir}$data".summary.txt"
  echo -e "total_reads\tmapped_reads" >> ${outputdir}$data".summary.txt"
  echo -e "$total_reads\t$mapped" >> ${outputdir}$data".summary.txt"
## count intersect size
  echo "Intersect Size" >> ${outputdir}$data".summary.txt"
  ../../../software/BEDTools-Version-2.16.2/bin/intersectBed -abam ${outputdir}${data}_sorted.bam -b $ann -bed -wo|cut -f 16|sort|uniq -c >> ${outputdir}$data".summary.txt"

  fi
done

## compile the gene matrix
perl compileTable.pl -i $outputdir -o $outputdir -f ${suffix}".summary.txt"
## remove the seperate summary file
##rm -f *${data}.summary.txt
## normalized the gene read couts
perl normalized.pl -i $outputdir -o ${outputdir}Normalized_gene.txt
## log2 transformation
Rscript log2Genes.R input.txt output.txt
