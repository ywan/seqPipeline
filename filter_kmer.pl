## This script helps filter out reads with specific motif

#! usr/bin/perl -w

use Getopt::Std;

sub print_help {
print "This script is used to summarize gene and read counts from seperate table\n";
print "-h help\n";
print "-i input file DIRECTORY, default is current directory\n";
print "-o output file DIRECTORYi, default is the current directory\n";
print "-f suffix of the input file, e.s uniq.fq; default is fq\n";
print "-s motif to be filtered\n\n";
print "Example: perl filter_kmer.pl -i test/ -o test/ -f uniq.fq -s AGCAAACCGTCCTC\n";
exit 1;
}

my %options = ();
getopts("hi:o:f:s:",\%options);
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
  else {
	$suffix="fq";
	}
  if ($options{s})
	{$motif=$options{s}}
  else {
	print "Missing sequence!!!\n";
	exit 1;
	}
}
}

opendir (DIR, $dirname) || die "Error: Cannot open $dirname!!!\n";

while($file=readdir(DIR)){
## Be careful about this regular expression, this recognize the suffix, but may cause some problems if the file name format is different
 if($file=~/$suffix$/){
  open FILE, $dirname.$file || die "Error: Cannot open $file!!!\n";
  print "Reading $file\n";
  my @tmp=split(/\./,$file);
  $Sname=$tmp[0];

  %filter_reads=();
  while (my $line=<FILE>){
          chomp($line);
        my %seq=();
	my $sequence=NA;
	my $quanlity=NA;
	my $name=NA;
  if($line =~ /^@/){
        $name=$line;
        $line=<FILE>;
        chomp($line);
        $sequence=$line;
        $line=<FILE>;$line=<FILE>;
        chomp($line);
        $quality=$line;

  if($sequence !~ /$motif/){
                $seq{'name'}=$name;
                $seq{'quality'}=$quality;
        $filter_reads{$sequence}={%seq};
                }
        }
	}

  close FILE;

## write filtered reads to file
  open UNIQ, ">".$outfile.$Sname.".filter.".$suffix;
  print "Creating ".$Sname.".filter.".$suffix."\n";
  for $seq (keys %filter_reads){
  print UNIQ "$filter_reads{$seq}{'name'}\n";
  print UNIQ "$seq\n";
  print UNIQ "+\n";
  print UNIQ "$filter_reads{$seq}{'quality'}\n";
}
  close UNIQ;
  }
}
close DIR;
