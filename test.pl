# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use mqs::spool;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

print "Initialisation of a new spool\n";
my %spool = initspooldirectory("try_spool");
print "Definition of the spool\n";
my $key;
my $value;
while(($key,$value) = each %spool)
{
	print "spool{$key} => $value\n";
}
print "File name generation =>".newfilename($spool{'directory'})."\n";

print "Generation of 1024 files in a spool (file has a random size between 1 to 4096 octets)\n";

my $i;
my $tmp;
my $content = "";
my $max;
for($i = 0; $i < 1024; $i++)
{
	$max = int(rand(4096));
	for($tmp = 0; $tmp < $max ; $tmp++)
	{
		$content = ".".$content;
	}
	if((putinspool(\%spool,$content."\n",1)) == 1)
	{
		print ".";
	}
	else
	{
		print "\n-1\n";
	}
	$content = "";
}

print "\nScan of a spool =>";
my @tab = listfiles(\%spool,0) ;
print @tab  ." Files found in the spool\n";
print "First one is => $tab[0]\n";
print "Last one is => $tab[$#tab]\n";

print "I'm deleting all files in the spool \n";
foreach $tmp(@tab)
{
	delfile($tmp);
	print ".";
}

print "\nActually ".listfiles(\%spool,0). " files in the spool\n\n";
print("put in spool a Multi lines message with a priority of 2\n");
putinspool(\%spool,"Multiline\nmessage\n",2);
print("Read the spool \n");
@tab = listfiles(\%spool,0);
my @result;
foreach $tmp(@tab)
{
	@result = readfile($tmp);
	print "File => $tmp\n";
	print "<= Content =>\n$result[0]<= End Content =>\n";
	print "Priority => $result[1]\n";
	if(delfile($tmp) == 1)
	{
		print "Delete the file\n";
	}
}

print "Create 24 files with randomize priority => ";

my $rnd;

for($i = 0; $i < 24; $i++)
{
	$rnd = (int(rand(5)) + 1);
	$max = int(rand(4096));
	for($tmp = 0; $tmp < $max ; $tmp++)
	{
		$content = ".".$content;
	}
	if((putinspool(\%spool,$content."\n",$rnd)) == 1)
	{
		print ".";
	}
	else
	{
		print "\n-1\n";
	}
	$content = "";
}

print "\n";

print "Scan of spool with priority =>";
@tab = listfiles(\%spool,1);
print @tab . "files in spool\n";
foreach $tmp(@tab)
{
	print $tmp . "\n";
	delfile($tmp);
}

print "Actually " . listfiles(\%spool,0) . " in the spool\n";
