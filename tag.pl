#!/usr/bin/perl
use DBI;
use File::Basename;
use Time::HiRes;
use Digest::MD5 qw(md5_hex);
chdir('/');
$tmpfile = "/vagina/Scripts/NEW-TEMPFILE.txt";
$dbfile = "/vagina/tag.db";
$db = DBI->connect("dbi:SQLite:/vagina/tag.db", "", "",
{RaiseError => 1, AutoCommit => 1});

$argCount = @ARGV;
if(!defined(@ARGV))
{
	print "Usage ./tag.pl PATH tags\nExample ./tag.pl /home home fileserver personal\n";
}else{
	$searchPath = $ARGV[0];
	if($argCount > 0)
	{
		shift(@ARGV);
		$tags = join(",",@ARGV);
		if($tags eq "") 
		{
			$tags = "Random";
		}
	
		print "TAGS -> $tags\n";
	}
	&GetValues();
}

sub GetValues()
{
	chomp(@files = `find $searchPath -type f`);
	open TMPFILE, ">$tmpfile" or die $!;
	$start = Time::HiRes::gettimeofday();
	print TMPFILE "BEGIN;\n";
	foreach(@files)
	{
		$filename = basename($_);
		$path = dirname($_);
		$md5 = md5_hex($_);
		&CheckRows($md5);
	}
	print TMPFILE "END;\n";
}


sub CheckRows($md5)
{
        $check = $db->prepare("select id from items where md5 = ?");
        $check->bind_param(1, $md5);
        $check->execute();
        @sqlMD5  = $check->fetchrow_array;
	$sqlTemp = @sqlMD5;
	if($sqlTemp eq '0')
	{
		print TMPFILE "insert into items ( filename, path, tags, unixUser, md5 ) VALUES ( \"$filename\", \"$path\",  \"$tags\", '$user', '$md5' );\n";		
	}
}

if(defined(@ARGV))
{
	$end = Time::HiRes::gettimeofday();
	printf("%.2f\n", $end - $start);
#	$db->disconnect;
	@insert = `sqlite3 $dbfile < $tmpfile`;
	close(TMPFILE);
}	
