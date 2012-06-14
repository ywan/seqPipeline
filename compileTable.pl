#! usr/bin/perl -w

use Getopt::Std;

sub uniq {
  return keys %{{ map { $_ => 1 } @_ }};
	}

sub print_help {
print "This script is used to summarize gene and read counts from seperate table\n";
print "-h help\n";
print "-i input file DIRECTORY\n";
print "-o output file DIRECTORY\n";
print "-f suffix of the input file, default is summary.txt\n";
print "Example: perl compileTable.pl -i test/ -o test/ -f filter.uniq.fq.summary.txt\n";
exit 1;
}

my %options = ();
getopts("hi:o:f:",\%options);
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
        $dirname="./";
        }
  if ($options{o})
        {$outfile=$options{o};}
  else {
        $outfile="./";}
  if($options{f})
	{$suffix=$options{f};}
  else{
  $suffix="summary.txt";
	}
}
}


opendir (DIR, $dirname) || die "Error: Cannot open the directory!!\n";

open TABLE, ">".$outfile."gene_summary.txt";
%genes=();
@gene_names=();
%sum=();
while($file=readdir(DIR)){
 if ($file =~ /$suffix$/)
 {
	open FILE, $outfile.$file || die " Cannot open $file!!!\n";
	my @tmp=split(/\./,$file);
	$name=$tmp[0];
	my %strain=();
	my %tmp_sum=();
	while($line=<FILE>){
	chomp($line);
	if($line =~ /^\s+\d+\s+\w+$/){
	my @tmp=split(/\s+/,$line );
	$strain{$tmp[2]}=$tmp[1];
	push (@gene_names,$tmp[2]);
		}

	elsif ($line =~ /^total_reads/){
	chomp($line);
	my @tmp1=split(/\s+/,$line);
	$line=<FILE>;
	chomp($line);
	my @tmp2=split(/\s+/,$line);
	$tmp_sum{$tmp1[0]}=$tmp2[0];
	$tmp_sum{$tmp1[1]}=$tmp2[1];
	}
	}  
  	$genes{$name}={%strain};
	@gene_names=uniq(@gene_names);

	$sum{$name}={%tmp_sum};
	close FILE;
	}
}
closedir DIR;

print TABLE "gene";
for my $strain (sort keys %genes){
print TABLE "\t$strain";}
print TABLE "\n";

for my $names(sort @gene_names){
print TABLE "$names";

for my $strain (sort keys %genes){
if($genes{$strain}{$names})
	{print TABLE "\t$genes{$strain}{$names}"; 
} else
	{print TABLE "\t0";}
}
	print TABLE "\n";
}
close TABLE;

open SUM, ">".$outfile."reads_summary.txt";
print SUM "strain\ttotal\tmapped\tduplicated\n";
for my $strain (sort keys %sum){
my @names=sort keys %{$sum{$strain}};
my $duplicated=$sum{$strain}{$names[0]}-$sum{$strain}{$names[1]};
if($duplicated>0){
print SUM "$strain\t$sum{$strain}{$names[0]}\t$sum{$strain}{$names[1]}\t$duplicated\n";}
else{
$duplicated=abs($duplicated);
print SUM "$strain\t$sum{$strain}{$names[1]}\t$sum{$strain}{$names[0]}\t$duplicated\n";}
}
close SUM;

