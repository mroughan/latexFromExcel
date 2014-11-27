#!/usr/bin/perl -w
# latexFromExcel.pl -- Matthew Roughan, 2014, <matthew.roughan@adelaide.edu.au>
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
########################################################
use Spreadsheet::Read;  # https://metacpan.org/pod/Spreadsheet::Read
use Data::Printer;

$version = "latexFromExcel.pl v0.01 (Thu Nov 13 2014)";
chomp($today = `date`);
print STDERR "running $version on $today\n";

# get command line options
sub usage {
    "Usage: $0 [--help] [--Debug=i] [--dir=dir] [--Filter=file] --file file.tex\n";
}

use Getopt::Long;
Getopt::Long::Configure("bundling");
$result = GetOptions('help|h' => \$opt_help,
		     'Debug|D=i' => \$opt_debug,
		     'file|f=s' => \$latex_file,
		     'Filter|F=s' => \$filter_file,
		     ) || die usage();
$result = 0;

if (defined($opt_help)) {
  die usage();
}

if (defined($opt_debug)) {
  $debug = $opt_debug;
} else {
  $debug = 0;
}

if (!defined($latex_file)) {
  die usage();
}

if ($0 =~ /(.*)\/(.*)/) {
  $calling_path = $1;
  $calling_prog = $2;
} else {
  $calling_path = ".";
  $calling_prog = $0;
}

# take in any defined filters
if (defined($filter_file)) {
  open(FILE, "< $filter_file") or die "Error:could not open $filter_file: $!\n";
  $i = 0;
  while (<FILE>) {
    chomp();
    s/#.*//;
    if (/\S/) {
      ($in, $out, $flags) = split(/\|/, $_);
      $filter_in[$i] = qr/$in/;
      $filter_out[$i] = "$out";
      $i++;
    }
  }
  $n_filters = $i;
  close(FILE) or die "Error:could not open $filter_file: $!\n";
} else {
  $n_filters = 0;
}


# read the LaTeX file, and look for commands
open(FILE, "< $latex_file") or die "Error:could not open $latex_file: $!\n";
$i = 0;
while (<FILE>) {
  if (m"%\s+latexFromExcel{([^}]+)}{([^}]+)}{([^}]+)}{([^}]+)}{(.*)}") {
    $excel_file[$i] = $1;
    $table_file[$i] = $2;
    $sheet[$i] = $3;
    $rows[$i] = $4;
    $cols[$i] = $5;
    if ($rows[$i] =~ /(\d+)-(\d+)/) {
      $row_start[$i] = $1;
      $row_end[$i] = $2;
    } elsif ($rows[$i] =~ /[*]-(\d+)/) {
      $row_start[$i] = 1;
      $row_end[$i] = $1;
    } elsif ($rows[$i] =~ /(\d+)-[*]/) {
      $row_start[$i] = $1;
      $row_end[$i] = -1;
    } else {
      die("Error: bad row format\n")
    }
    $j[$i] = 0;
    while ($cols[$i] =~ s/{[!]([A-Z]+)}/{%s}/) {
      $columns[$i][$j[$i]] = $1;
      $j[$i]++;
    }
    $cols[$i] =~ s/!!/!/g;
    $cols[$i] =~ s/\\/\\\\/g;
    chomp($cols[$i]);
    print " $i: \$excel_file=$excel_file[$i],  \$sheet=$sheet[$i], \$rows=$rows[$i],  \$cols=$cols[$i] \n";
    print "            \$row_start=$row_start[$i], \$row_end=$row_end[$i]\n";
    p(@{$columns[$i]});
    $i++;
  }
}
close(FILE) or die "Error: could not close $latex_file: $!\n";

# my $sheet = $book->[1];             # first datasheet
# my $cell  = $book->[1]{A3};         # content of field A3 of sheet 1
# my $cell  = $book->[1]{cell}[1][3]; # same, unformatted
# construct the outputs
for ($k=0;$k<$i;$k++) {
  $outfile = $table_file[$k];
  $workbook = ReadData($excel_file[$k], attr => 1, strip => 1);
  if ($row_end[$k] < 0) {
    $row_end[$k] = $workbook->[$sheet[$k]]{maxrow} + 1 + $row_end[$k];
  }
  %cs = %{$workbook->[$sheet[$k]]};
  # print "$k: \$workbook->[1]{maxrow}= $workbook->[1]{maxrow}\n";
  # print "$k: \$workbook->[1]{maxrow}= $cs{maxrow}\n";
  # p($cs, colored => 1);
  open(FILE, "> $outfile") or die "Error:could not open $outfile: $!\n";
  $print_str = 'printf FILE "' . $cols[$k] . ' \\n", (' . join(',', map {"\$cs{${_}m}"} @{$columns[$k]}) . ')';
  print FILE "% $print_str\n";
  for ($m=$row_start[$k];$m<=$row_end[$k];$m++) {
    # contruct formatted output
    $print_str = 'sprintf("' . $cols[$k] . ' \\n", ' . join(',', map {"\$cs{$_$m}"} @{$columns[$k]}) . ')';
    print "$print_str \n";
    $tmp = eval($print_str);

    # apply filters
    for ($l=0;$l<$n_filters;$l++) {
      $tmp =~ s/($filter_in[$l])/$filter_out[$l]/g;
    }

    # output
    printf FILE $tmp;
  }
  close(FILE) or die "Error: could not close $outfile: $!\n";
}
