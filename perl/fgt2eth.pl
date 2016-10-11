#!/usr/bin/perl

# This work (and included software, documentation or other related items) is
# being provided by the copyright holders under the following license. By
# obtaining, using and/or copying this work, you (the licensee) agree that you
# have read, understood, and will comply with the following terms and conditions
#
# Permission to copy, modify, and distribute this software and its documentation
# with or without modification, for any purpose and without fee or royalty is
# hereby granted, provided that you include the following on ALL copies of the
# software and documentation or portions thereof, including modifications:
#
#   1. The full text of this NOTICE in a location viewable to users of the
#      redistributed or derivative work.
#   2. Notice of any changes or modifications to the files, including the date
#      changes were made.
#
#
# THIS SOFTWARE AND DOCUMENTATION IS PROVIDED "AS IS," AND COPYRIGHT HOLDERS
# MAKE NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO, WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR
# PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY
# THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
#
# COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR
# CONSEQUENTIAL DAMAGES ARISING OUT OF ANY USE OF THE SOFTWARE OR DOCUMENTATION.
#
# Title to copyright in this software and any associated documentation will at
# all times remain with copyright holders.
#
# Copyright: Fortinet Inc - 2005
#

# Fortinet EMEA Support
# This script converts a Fortigate verbose 3 sniffer output file to a file that
# can be opened by Ethereal. It uses the text2pcap binary included in the Ethereal package.
# It is supplied as is and no technical support will be provided for it.

  my $version 		      = "1.23 (Apr 06 2009)";

# ChangeLog
# 1.01 - lblossier - Fixed the timestamps (thanks to Claudio)
# 1.10 - lblossier - Added support for 'interface Any' traces
#                  - Added support for PPPoE traces (Claudio again)
# 1.11 - lblossier - Fixed the any/ppp adjuster when last line only has a word
# 1.12 - lblossier - Removed duplicate packets (truncated) when capturing ESP
# 1.13 - lblossier - Added 0x0A as allowed delimiter (along with \s and \t)
# 1.14 - mblomberg - Automatic OS detection
#                  - Change default output filename
# 1.15 - lblossier - Added decoder for HA ethertype 8890/8891
# 1.16 - lblossier - bug fix for 'any' interface packet shifting.
# 1.17 - lblossier - Add support for Wireshark text2pcap
# 1.18 - lblossier - Ignore packets captured on eth0
# 1.19 - lblossier - Rewrote adjustPacket. Added HA ethertype 8893
# 1.20 - lblossier - Fixed packet shifting values for any/HA intf
# 1.21 - lblossier - Fixed timestamp conversion (hour conversion was broken)
#	-- script added to SVN --
# 1.22 - lblossier - Extend timestamp conversion for trace above 1 day long (till 31 days)
# 1.23 - Quieten info messages and rely on PATH for text2pcap under linux

# v1.14: Detect OS
  my $prefered_system = ($ENV{'OS'} =~ m/windows/i) ? 'windows':'linux';

# Path to the windows text2pcap.exe
# You need to double character '\'
  my $text2pcapdirwin   = "c:\\Progra~1\\Ethereal";
  # Use wireshark text2pcap if installed
  $text2pcapdirwin   = "c:\\Progra~1\\Wireshark" if -e "c:\\Progra~1\\Wireshark\\text2pcap.exe";


# ------------------ don't edit after this line -------------------------------
  use strict;
  use Getopt::Long;
  use FileHandle;
  use File::Temp qw / tempfile /;
  use vars qw ($debug $help $vers $in $out $lines $system);

# Global variables

  my $line_count		        = 0;
  my ($fh_in, $fh_out)  	  	= new FileHandle;
  my $tmpfile;
  my @fields 			        = {};
  my @subhexa 			        = {};
  my ($offset,$hexa,$garbage) 		= "";
  my @list 				= {};

# Control command line options

   GetOptions(
	"debug"	  	=> \$debug,			# use -debug to turn on debug
  	"version"   => \$vers,    		# use -version to display version
	"help" 	  	=> \$help,			# use -help to display help page
	"in=s"    	=> \$in,			# use -in  <filename> to specify an input file
	"out=s"   	=> \$out,			# use -out <filename> to specify an output file
    "lines=i"  	=> \$lines,			# use -lines <number> to stop after <number> lines written
	"system=s" 	=> \$system,		# use - system to specify 'linux' or 'windows' system
	);

  if ($help) {
    Print_help();
    exit;
    }

  if ($vers) {
    Print_version();
    exit;
    }

# Sanity checks

  if (not(defined($in))) {
    Print_usage();
    exit;
    }

  if (defined($system)) {
    die "non authorized system specified"
      if (not($system =~ /linux|windows/));
    }

# Open input file for reading, open output file for writing
# v1.14 : Automatic creation of output filename
  printf "Called with input filename ".$in."\n" if $debug;
  $out = $in."\.pcap" unless defined $out;

  print "Output file is ".$out."\n" if $debug ;

  open(fh_in,  '<', $in)  or die "Cannot open file ".$in." for reading\n";
  (undef, $tmpfile)   = tempfile( UNLINK => 1);
  open(fh_out,  '>', $tmpfile)  or die "Cannot open file $tmpfile writing\n";
  print "create temp file $tmpfile\n" if $debug;

# Convert
  if( $debug ) {
    printf "Conversion of file ".$in." phase 1 (FGT verbose 3 conversion)\n";
    print "Output written to ".$out.".\n";
  }

  my @packetArray = ();

  #Parse the entire source file
  my $DuplicateESP = 0;
  my $eth0 = 0;
  my $skipPacket = 0;

  while (<fh_in>) {
    #and build an array from the current packet
	if( isTimeStamp() ) {
		$skipPacket = /eth0/;
		$eth0++ 		if $skipPacket;

		$skipPacket |= convertTimeStamp();
   } elsif	( isHexData() and not $skipPacket )
	  {
        buildPacketArray();
	     adjustPacket();
	     _startConvert();
		}
  }
  print "** Skipped $eth0 packets captured on eth0\n" if $eth0;

# Close files
  close (fh_in)  or die "Cannot close file ".$in."\n";
  close (fh_out) or die "Cannot close file $tmpfile\n";


# Calling textpcap (see www.ethereal.com)
  $system = $prefered_system unless defined $system;

  # System is windows :-(
  if ($system eq "windows") {
	my @args = ($text2pcapdirwin."\\text2pcap.exe", "-t", '"%d/%m/%Y %H:%M:%S."', "-q", "$tmpfile", $out);
    print "Conversion of file ".$in." phase 2 (windows text2pcap)\n" if $debug;
    system(@args) == 0 or die "call to text2pcap failed @args failed: $?\n
    The '-system linux' option may be needed ?\n\n"
    }

  # System is linux :-)
  elsif ($system eq "linux") {
   print "Conversion of file ".$in." phase 2 (linux text2pcap)\n" if $debug;
     system ( "text2pcap -q -t \"%d/%m/%Y %H:%M:%S.\" $tmpfile ".$out)  == 0 or die "call to text2pcap failed : $?\n
	The '-system windows' option may be needed ?\n\n"
    }
  if( $debug ) {
    print "Output file to load in Ethereal is \'".$out."\'\n";
	print "End of script\n";
  }


sub isHexData {
  return $_ =~ /^(0x[0-9a-f]+[ \t\xa0]+)/;
};

sub isTimeStamp {
  return $_ =~ /^[0-9]+[\.\-][0-9]+/;
}

sub buildPacketArray {
my $line = 0;
@packetArray = ();

  do {
	/^(0x[0-9a-f]+[ \t\xa0]+)/i;
	$packetArray[$line][0] = substr( $_, 0, 6);
	my $offset = length($1);
	for( my $col=0; $col<8 ;$col++) {
	  $packetArray[$line][$col+1] = substr( $_, $col*5+$offset, 4);
	  #print " $packetArray[$line][$col + 1]";
	}
	$line++;
	$_ = <fh_in>;
  } until ( /^\s*$/ );
}

sub convertTimeStamp {
 # Keep timestamps.
  return 1 if /truncated\-ip \- [0-9]+ bytes missing!/ ;
  if ( /^([0-9]+)\.([0-9]+) / )
    {
        my $packet = 1;
        my $time = $1;

		# Extract days
		my $nbDays	= int($time / 86400);
		my $day 	= sprintf("%0.2d", 1+$nbDays);
		$time 		= $time % 86400;

        # Extract hours
        my $hour = int($time / 3600 );
        $time = $time % 3600;

        # Extract minutes
        my $minute = int( $time / 60);
        $time = $time % 60;


        # and remaining seconds
        my $sec = $time;

        print fh_out "01/$day/2005 " . $hour . ":" . $minute . ":" . $sec . ".$2\n";
    } elsif ( /^(\d+-\d+-\d+ \d+:\d+:\d+\.\d+) / ) {
        # absolute timestamp
        my $timestamp   = $1;
        $timestamp      =~ s/(\d+)-(\d+)-(\d+)/$3\/$2\/$1/;
        print fh_out "$timestamp\n";
    }
	 # Check if line is a duplicate ESP packet (FGT display bug)
	 return 0;

}

#------------------------------------------------------------------------------
 sub Print_usage {
  print "Version : $version\n\n";
  print "Assuming OS: $prefered_system\n\n";
  print "Usage : fgt2eth.pl -in <input_file_name>\n\n";
  print "Mandatory argument are :\n\n";
  print "   -in  <input_file>     Specify the file to convert (FGT verbose 3 text file)\n\n";
  print "Optional arguments are :\n\n";
  print "   -help                 Display help only\n";
  print "   -version              Display script version and date\n";
  print "   -out <output_file>    Specify the output file (Ethereal readable)\n";
  print "                         By default '<input_file>.eth' is used\n";
  print "   -lines <lines>        Only convert the first <lines> lines\n";
  print "   -system <system>      Can be either linux or windows\n";
  print "   -debug                Turns on debug mode\n";
  }
#------------------------------------------------------------------------------
 sub Print_help {
  print "Help:\n\n";
  print "* What is this script for ?\n\n";
  print "   It permits to sniff packets on the fortigate with built-in sniffer\n\n";
  print "      diag sniff interface <interface> verbose 3 filters \'....\'\n\n";
  print "   and to be able to open the captured packets with Ethereal free sniffer.\n\n\n";
  print "* What do I need to know about this script ?\n\n";
  print "   - It can be sent to customers, but it is given as is.\n";
  print "   - No support is available for it as it is not an 'offical' fortinet product.\n";
  print "   - It should run on windows and linux as long as perl is installed.\n";
  print "     To install perl on windows system,\n";
  print "         go to http://www.activestate.com/Products/ActivePerl/\n";
  print "   - All lines from the source file that do not begin with \'0x\' will be ignored.\n";
  print "   - Be carefull not to add \'garbage\' characters to the file during the sniff.\n";
  print "     If possible do not hit the keyboard during capture.\n\n\n";
  print "* Installation :\n\n";
  print "    You need to edit the script first lines and to specify:\n\n";
  print "       - for windows:  the path to text2pcap.exe in \$text2pcapdirwin\n";
  print "                       Current settings : $text2pcapdirwin\n\n";
  print "    You can also specify the \$prefered_system variable (linux or windows)\n";
  print "    For now \'$prefered_system\' is set.\n\n\n";
  print "Remarks concerning this script can be sent to eu_support\@fortinet.com\n";
  print "Thanks to Claudio for this great idea,\nThanks to Ellery from Vancouver Team for the timestamps\n\nCedric\n\n";
  print "____________________________________________________________________________\n\n";
  Print_usage();
 }
#------------------------------------------------------------------------------

sub Print_version {
  print "\nVersion : ".$version."\n\n";
  }

#----------
# name : adjustPacket
# description:
#  Applies changes to the current packetArray to make it convertible into
#  ethereal format.
#     - Removes internal Fortigate tag when capture interface is any.
#
sub adjustPacket {

  next unless $packetArray[0][0] =~ /0x0000/;
  stripBytes( 7, 1 ) if $packetArray[0][8] =~ /0800/;
  stripBytes( 7, 1 ) if $packetArray[0][7] =~ /8893/;
  addHdrMAC()        if $packetArray[0][1] =~ /4500/;
  $packetArray[0][7] =~ s/8890|8891/0800/ if $packetArray[0][0] =~ /0x0000/;
}

sub addHdrMAC
{
  my $nbRows = scalar @packetArray;

  # shift all 0x counters by 16
  for( my $row = $nbRows; $row > 0; $row-- ) {
        my $rowIdx = sprintf( "0x%0.4x", $row*16 );
        for( my $col=1; $col<9; $col++) {
            $packetArray[$row][$col] = $packetArray[$row - 1][$col];
        }
        $packetArray[$row][0] = $rowIdx;
  }

  # And populate 0x0000 line
  $packetArray[0][0] = "0x0000";
  $packetArray[0][1] = "0000";
  $packetArray[0][2] = "0000";
  $packetArray[0][3] = "0000";
  $packetArray[0][4] = "0000";
  $packetArray[0][5] = "0000";
  $packetArray[0][6] = "0000";
  $packetArray[0][7] = "0800";
  $packetArray[0][8] = "4500";

  # finally left shift the IP ver+IHL (4500)
  stripBytes(8,1);
}

sub stripBytes
{
  my $start         = shift;
  my $nbBytes       = shift;
  my ($fromCol, $fromRow, $toRow, $toCol);

  # shift bytes starting from $start with offset -$nbBytes
  my $startRow = int $start/9;
  my $startCol = $start % 9 - 1;

  # Do not stripByte if startpoint is the address column.
  return unless $startCol >= 0;
  my $nbRows = scalar @packetArray;

  for( my $row = $startRow; $row < $nbRows; $row++ ) {
    for( my $col = $startCol; $col <8; $col++ ) {
      $fromCol =  1 + ($col + $nbBytes) % 8;
      $fromRow = $row + int (($col + $nbBytes) / 8);
      $toCol = 1 + $col;
      $toRow = $row;
      $packetArray[$row][ 1 + $col] = $packetArray[$fromRow][$fromCol];
    }
    $startCol = 0;
  }

  # Remove lines with no data on it
  my $lastCell = $packetArray[@packetArray-1][1];

  while( $lastCell !~ /[0-f]/ ) {
    pop @packetArray;
    $lastCell = $packetArray[@packetArray-1][1];
  }


}

sub dumpPacket
{
  foreach my $line( @packetArray ) {
    print join("  ", @{$line}) . "\n";
  }
  print "\n";
}

sub _startConvert {
  LINE:
    #Initialisation
    my $offset = "";
    my $hexa = "";
    my $garbage = "";
    my @list = {};
    chomp;

# Rebuild a line from packetArray to perform line by line conv.
	for( my $row=0; $row<scalar @packetArray; $row++) {
	  $_ = $packetArray[$row][0];
	  for(my $col=1; $col<9; $col++ ) {
		$_ = "$_ $packetArray[$row][$col]";
	  }
	  $_ = "$_\n";

    if ($debug) {
      printf "------------------------------------------------------------\n" if ($offset eq "0000");
      printf "-->".$_."\n";
      }

	s/^0x//;                    		# delete Ox in the beginning of each lines
    # extract each hexa code from hexacode part
    @fields = {};
    @fields  = $_ =~ /
      ^(\w{4})                    # offset of 4 digits
        \s+(\w{0,2})(\w{0,2})     # 1st group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 2st group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 3rd group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 4th group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 5th group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 6th group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 7th group of 4 chars if any
        \s+(\w{0,2})(\w{0,2})     # 8th group of 4 chars if any
        \s                        # space
        */x;                      # Crap

    printf fh_out "00".$fields[0]." ";    			# Write Offset to output file
    printf $line_count." : 00".$fields[0]." " if $debug;

    for (my $i=1;$i<17;$i++) {
      if (defined($fields[$i])){
        if ($fields[$i] ne '') {
            printf fh_out $fields[$i]." ";
            printf $fields[$i]." " if $debug;
            }
        }
      else {print "** " if $debug};
      }
    print fh_out "\n";          				# Write end of the line
    print "\n\n" if $debug;

    $line_count++;
    if (defined($lines)) {
      if ($line_count >= $lines) {
        print "Reached max number of lines to write in output file\n";
        last LINE;
        }
      }
  }
}
