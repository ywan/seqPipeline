#! usr/bin/perl -w

use Getopt::Std;

sub print_help {
print "This script is used to extract non-duplicated reads from a fastq file\n";
  print "-h help\n";
  print "-i input file directory (gene_summary.txt and read_summary.txt should be in the same directory);\n";
  print "-o output file path;\n\n";
  print "Example: perl normalized.pl -i ~/test/ -o ~/test/Normalized_gene.txt\n\n";
  exit 1;

}


## define the directory which contains the fastq file
my %options = ();
getopts("hi:o:", \%options);
my $size = keys %options;
if($size==0) {
print_help();
} else {
if($options{h})
{
print_help();
} else {
  if ($options{i})
  { $dirname=$options{i};}
   else {
        $dirname="gene_summary.txt";
        }
  if ($options{o})
        {$outfile=$options{o};}
  else {
        $outfile="Normalized_gene.txt";}
}
}



## reading the gene coverage

open GENE, $dirname."gene_summary.txt"||die "Cannot open gene_summary.txt!!!\n";

%gene_summary=();
while(my $line=<GENE>){

chomp($line);
if($line =~ /^gene/)
{ @strain=split(/\t/,$line);
  $strainNum=@strain;
} else {
	my @gene_num=split(/\t/,$line);
	my %summary=();
	for(my $i=1;$i<$strainNum; $i++){
	$summary{$strain[$i]}=$gene_num[$i];
	}
	$gene_summary{$gene_num[0]}={%summary};
   }

}

close GENE;

## reading the overall counts

open READ, $dirname."reads_summary.txt"||die "Cannot open read_summary.txt!!!\n";

%reads_summary=();
while(my $line=<READ>){

chomp($line);
if($line =~ /^strain/){
@title=split(/\t/,$line);
$titleNum=@title;
} else{
	my @reads_num=split(/\t/,$line);
	my %summary=();
	for (my $i=1; $i<$titleNum; $i++){
	$summary{$title[$i]}=$reads_num[$i];
	}
	$reads_summary{$reads_num[0]}={%summary};
  }
}

close READ;

## normalized the data
## get a specific number for nomalization
my @genes=sort keys %gene_summary;
my @strain=sort keys %reads_summary;
#my $norm_gene=$genes[0];
my $norm_strain=$strain[0];
for my $gene(@genes)
{
if($gene_summary{$gene}{$norm_strain}!=0)
{$norm_gene=$gene;
 last;}
}

##print "$norm_gene\t$norm_strain\n";
$norm_NUM=100/($gene_summary{$norm_gene}{$norm_strain}/$reads_summary{$norm_strain}{'total'});
$norm_NUM=int($norm_NUM);

open TABLE, ">$outfile";
print TABLE "gene";

%normalized_gene = ();
@strain=sort keys %reads_summary;
for my $strain (@strain){
  print TABLE "\t$strain"};
print TABLE "\n";

for my $gene (sort keys %gene_summary){
  my %gene_num=();
  print TABLE $gene;
	for my $strain (@strain){
	$gene_num{$strain}=$gene_summary{$gene}{$strain}*$norm_NUM/$reads_summary{$strain}{'total'};
	$gene_num{$strain}=int($gene_num{$strain});
	print TABLE "\t$gene_num{$strain}";
 }
	print TABLE "\n";
 $normalized_gene{$gene}={%gene_num};
}

close TABLE;
















