#!/usr/bin/perl -w
#######################################
# written by Axel Fischer
# MPI for Molecular Plant Physiology
# Am Muehlenberg 1
# 14476 Potsdam
#######################################
# Last modified 28.01.2022
 
$| = 1;

use strict;
use Getopt::Long;

my ($bam_path,$fasta_path,$mq,$output_path,$cmd,$base);
my (@TMP,@BASES,@OUT);
my (%hashy);

if($#ARGV < 1) {
        print "usage:extract_BaseCovInformation -b=[input bam file] -f=[fasta file] -q=[MQ value for samtools mpileup] -o=[output file path]\n";
        exit;
}

GetOptions("-b=s" => \$bam_path, "-f=s" => \$fasta_path, "-q=i" => \$mq, "-o=s" => \$output_path);

$cmd="samtools mpileup -f " . $fasta_path . " -Q " . $mq . " -d 1000000 " . $bam_path ." 2>/dev/null | ";
open INPUT, $cmd or die "can't open datafile: $!";
open OUTPUT, ">".$output_path or die "can't open datafile: $!";

print "Parsing started.\n";
print OUTPUT "chromosome\tposition\trefBase\tcov_A\tcov_C\tcov_G\tcov_T\n";

while(<INPUT>){
    %hashy=("A",0,"C",0,"G",0,"T",0);
    @TMP=split("\t",$_);
    $TMP[4]=~s/[,\.]/$TMP[2]/g;
    @BASES=split("",uc($TMP[4]));
    foreach $base (@BASES){
	$hashy{$base}++;
    }
    @OUT=($TMP[0],$TMP[1],$TMP[2],$hashy{"A"},$hashy{"C"},$hashy{"G"},$hashy{"T"});
    print OUTPUT "".join("\t",@OUT)."\n";
}
print "Parsing finished.\n";
