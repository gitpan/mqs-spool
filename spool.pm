package mqs::spool;

require 5.005_62;
use strict;
use warnings;

require Exporter;
require DynaLoader;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use mqs::spool ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
		initspooldirectory
		newfilename
		putinspool
		listfiles
		delfile
		readfile
);
our $VERSION = '0.02';

bootstrap mqs::spool $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

use Cwd;
use POSIX;

my $size_spool = 32;
my $spool_chmod = 0750;
my $max_priority = 5;
my $min_priority = 1;
my $rnd_coeff = 64000; # value from 0 to $rnd_coeff to generate
			# randomized file names

sub initspooldirectory
{
	my %spool;
	my $dir = $_[0];
	if($dir eq "")
	{
		return -1;
	}
	unless(-d $dir)
	{
		mkdir ($dir,$spool_chmod) or return $!;
	}
	my $currentdir = getcwd();
	chdir($dir);
	my $it;
	for($it = 0; $it < $size_spool; $it++)
	{
		unless(-d $it)
		{
			mkdir ($it,$spool_chmod) or return $!;
		}
	}
	$spool{"type"} = "dir";
	$spool{"directory"} = getcwd();
	chdir $currentdir;
	return %spool;
}

sub newfilename
{
	my $dir = $_[0];
	$dir = $dir."/".int(rand($size_spool));
	my $entire_name = gen_name($dir);
	$entire_name = $entire_name.int(rand($rnd_coeff));
	return $entire_name;
}

sub putinspool
{
	my $spool_ref = $_[0];
	my %spool = %$spool_ref;
	my $content = $_[1];
	my $priority = $_[2];
	my $filename;
	if($spool{'directory'} eq "" or $spool{'type'} ne "dir")
	{
		return -1;
	}
	if(-d $spool{'directory'})
	{
		$filename = newfilename($spool{'directory'});
	}
	else
	{
		return -1;
	}
	$filename = $filename.".".$priority;
#	if((write_file("$filename.tmp",$content)) == -1)
#	{
#		return -1;
#	}
# C code has a bug with some caracthers, ... did not find why, I come
# back in Perl code for this part
        open(OUT,">$filename.tmp") or return $!;
        print OUT"$content";
        close(OUT);
	rename("$filename.tmp","$filename.mqs");
	return 1;
}

sub listfiles
{
	my $spool_ref = $_[0];
	my %spool = %$spool_ref;
	my $priority = $_[1];		# not yet used
	if($spool{'directory'} eq "" or $spool{'type'} ne "dir")
	{
		return -1;
	}
	my $dir;
	my $it = 0;
	my @files;
	for($dir = 0; $dir < $size_spool; $dir++)
	{
		opendir(DIR,$spool{'directory'}."/".$dir) or return $!;
		while($files[$it] = readdir(DIR))
		{
			if($files[$it] =~ /.*\.mqs$/)
			{
				$files[$it] = $spool{'directory'}."/".$dir."/".$files[$it];
				$it++;
			}
		}
		closedir(DIR);
	}
	$#files = $#files - 1;
	if($priority == 1)
	{
		return &priority_spool(@files);
	}
	else
	{
		return @files;
	}
}

sub priority_spool
{
	my @files = @_;
	my $tmp;
	my @tab;
	my @return;
	my $pos = 0;
	my $i;
	for($i = $max_priority; $i != $min_priority - 1; $i--)
	{
		foreach $tmp (@files)
		{
			@tab = split(/\./,$tmp);
			if($tab[$#tab-1] == $i)
			{
				$return[$pos] = $tmp;
				$pos++;
			}
		}
	}
	return @return;
}

sub delfile
{
	my $file = $_[0];
	unlink($file) or return $!;
	return 1;
}
	
sub readfile
{
	my $file = $_[0];
	my @tab = split(/\./,$file);
	my $priority = $tab[$#tab - 1];
	my @line;
	open(IN,"<$file") or return -1;
	@line = <IN>;
	close(IN);
	my $content = join("",@line);
	my @return = ($content,$priority);
	return @return;
}



1;

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

mqs::spool - Perl extension for management of spools

=head1 SYNOPSIS

  use mqs::spool;

%spool = initspooldirectory($dir)

$entire_file_name = newfilename($dir)

$int = putinspool(\%spool,$content,$priority)

$int = delfile($file)

($content,$priority) = readfile($file)

@list_of_files = listfiles(\%spool,$priority)

$int = putinspoot(\%spool,$content,$priority)

=head1 DESCRIPTION

mqs::spool is a module for Perl to manage big or very big spool. 

@list_of_files = listfiles(\%spool,$priority)

If $priority == 1, then the tabular returned is done with the priority,
in all other cases, the tabular returned is the list of files as the 
function found them in the spool.

$int = putinspool(\%spool,$content,$priority)

$priority is an int between 1 to 5, other priorities will be accepted
by the functions, but the files will not be read by the listfiles 
function whent the priority function is activated (dangerous)

More you have files in a directory, more the read or the write in this
directory become slow. mqs::spool manage a spool of 32 directories (you
can increase this number in the sources of the module by increase the
value of $size_spool). 

A spool is defined by a very simple hash table. It contains informations
about the seat and the type of spool (tcp type of spool will soon come),
it is returned by the fonction initspooldirectory.

It's better to run initspooldirectory each time you want to use a spool,
this one will check if the spool exists and create or modify it (if you
modified the size by default of a spool) if not.

You can see the sources of test.pl to see how to use others functions in
your source code.

=head2 EXPORT

		initspooldirectory
		newfilename
		putinspool
		listfiles
		delfile
		readfile


=head1 AUTHOR

Stephane TOUGARD elair@darea.fr

=head1 SEE ALSO

perl(1).

=cut
