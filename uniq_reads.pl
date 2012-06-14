#! usr/bin/perl -w

use Getopt::Std;

sub print_help {
print "This script is used to extract non-duplicated reads from a fastq file\n";
  print "-h help\n";
  print "-i input DIRECTORY; default will be the current directory\n";
  print "-o output DIRECTORY; default will be the current directory\n";
  print "-f suffix of the input file, e.s filter.fq, default is fq\n\n";
  print "Example: perl uniq_reads.pl -i ~/FASTQ/ -o ~/FASTQ/uniq/ -f filter.fq\n\n";
  exit 1;

}


## define the directory which contains the fastq file
my %options = ();
getopts("hi:o:f:", \%options);
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
	{$outdir=$options{o};}
  else {
	$outdir="./";}
  if($options{f})
	{$suffix=$options{f};}
  else {
	$suffix="fq";}
}
}

## reading and processing the fastq file; put all the non-duplicated reads into one hash, using the name/quality of the first read
opendir (DIR, $dirname) || die "Error: Cannot open the directory!!!\n";

while($file=readdir(DIR)){
<<<<<<< HEAD
if($file =~ /$suffix$/){
=======
if($file =~ /^\d{2}.+\.$suffix$/){
>>>>>>> faa52edfdba666c6d10076dedd0298a32dc9d8f8
  $fullfile=$dirname.$file;
  print "reading $file...\n";
  open FILE, $fullfile || die "Cannot open $file\n";
  my @tmp=split(/\./,$file);
  $Sname=$tmp[0];
  
  %uniq_reads=(); 
  while (my $line=<FILE>){
	chomp($line);
	my %seq=();
	my $sequence=NA;
	my $name=NA;
	my $quality=NA;
  if($line =~ /^@/){
	$name=$line;
	$line=<FILE>;
	chomp($line);
	$sequence=$line;
	$line=<FILE>;$line=<FILE>;
	chomp($line);
	$quality=$line;

  if(!$uniq_reads{$sequence}){
		$seq{'name'}=$name;
		$seq{'quality'}=$quality;
	$uniq_reads{$sequence}={%seq};
		}
	}
	}
  close FILE;

## creating new fastq file with non-duplicated reads
  $outfile=$outdir.$Sname.".uniq.".$suffix;
  print "Creating $outfile...\n";
  open UNIQ, ">$outfile";
  for $seq (keys %uniq_reads){
  print UNIQ "$uniq_reads{$seq}{'name'}\n";
  print UNIQ "$seq\n";
  print UNIQ "+\n";
  print UNIQ "$uniq_reads{$seq}{'quality'}\n";

}
close UNIQ;

  }
}

close DIR;

