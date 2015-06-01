#!/usr/bin/perl -w

use POSIX;
use strict;
use lib qw(/var/www/radio.magneticloft.com/backend/libs/);
use libs;


# На входе - конфиг для проверки FastCGI процесса (<name>_fcgi.cfg)
# В конфиге:
# 1. Путь для запуска fcgi процесса
# 2. Путь к pid файлу процесса

if (!defined($ARGV[0]) || ($ARGV[0] eq '')) {
	print "Need fcgi config file as parameter\n";
	exit;
};

my $cfg = libs::parseConfig($ARGV[0]);

my $inst = '';
if (defined($ARGV[1]) && ($ARGV[1] ne '')) {
	# Если это команда, значит следующим параметром может быть инстанс
	$inst = $ARGV[2] || '';
};

# Если инстанс пустой - проверяем список инстансов из конфига
my @instances;
if (($inst eq '') && defined($cfg->{instances}) && ($cfg->{instances} ne '')) {
	my @i = split(/\,/, $cfg->{instances});
	foreach $inst (@i) {
		push(@instances, $inst);
	};
} else {
	push(@instances, $inst);
};

undef($inst);
my $second = 0;
foreach $inst (@instances) {
	if (! -e $cfg->{$inst.'pid_file'}) {
		run_process($cfg->{cmd_path}.' '.$inst);
		next;
	};

	open(FL, '<'.$cfg->{$inst.'pid_file'});
	my $pid = <FL>;
	close(FL);

	#my $cmd = "/bin/ps -A|grep -E \"^[^0-9]*".$pid."\"|awk '{print \$1}'";
	
	my $cmd = "/bin/ps h -p ".$pid." -o pid";

	my $pidstr = `$cmd`;
	chomp($pidstr);
	if ($pidstr =~ /^\s*(\d+)\s*/) {
		$pidstr = $1;
	};
	#print $pidstr."\n";

	if (defined($ARGV[1]) && (($ARGV[1] eq 'restart') || ($ARGV[1] eq 'stop') || ($ARGV[1] eq 'force-restart') || ($ARGV[1] eq 'force-stop'))) {
		if (($ARGV[1] eq 'restart') && ($second)) {
			sleep(5);
			$second = 1;
		};
		if ($ARGV[1] !~ /^force/) {
			kill(SIGTERM, $pid);
		} else {
			kill(SIGKILL, $pid);
		};
		while ($pid eq $pidstr) {
			sleep(1);
			$pidstr = `$cmd`;
			chomp($pidstr);
			if ($pidstr =~ /^\s*(\d+)\s*/) {
				$pidstr = $1;
			};
		};
	};

	if ($pid ne $pidstr) {
		if (!defined($ARGV[1]) || (($ARGV[1] ne 'stop') && ($ARGV[1] ne 'force-stop'))) {
			$inst = '' if (!defined($inst));
			run_process($cfg->{cmd_path}.' '.$inst);
		};
	};
};

sub run_process {
	system(@_);
};
