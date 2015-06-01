#!/usr/bin/perl -w

BEGIN {
	use lib qw(/var/www/radio.magneticloft.com/backend/libs);
	use libs;
	use proc;

	proc::check_command('/var/www/radio.magneticloft.com/backend/confs/radio_logic.conf');
	my $cfg = libs::parseConfig('/var/www/radio.magneticloft.com/backend/confs/radio_logic.conf');
	
	$ENV{FCGI_SOCKET_PATH} = $cfg->{'fcgi_host'}.":".$cfg->{'fcgi_port'};
	$ENV{FCGI_LISTEN_QUEUE} = $cfg->{'fcgi_listen_queue'};


	sub _get_config {
		return $cfg;
	};
}

use strict;
use locale;
use utf8;
use CGI::Fast qw/:standard :debug/;
use POSIX;
use Sys::Syslog;
use FCGI::ProcManager::Dynamic2;
use JSON;
use js;
use LWP::UserAgent;

use vars qw($cfg);

$cfg = _get_config();


libs::demonize($cfg->{'log_file'}, $cfg->{'pid_file'});

Sys::Syslog::setlogsock('unix');
openlog($cfg->{productName},'ndelay,pid', 'LOG_LOCAL0');
to_syslog("Start.......");

my $prod_name = $cfg->{cmd_path} || $0;


my $pm = FCGI::ProcManager::Dynamic2->new({
	n_processes => $cfg->{fcgi_nprocs},
	min_nproc => $cfg->{fcgi_min_nprocs},
	max_nproc => $cfg->{fcgi_max_nprocs},
	delta_nproc => $cfg->{fcgi_delta_nprocs},
	delta_time => $cfg->{fcgi_delta_time},
	max_requests => $cfg->{fcgi_max_requests},
	fcgi_main_proc_name => $prod_name,
	fcgi_child_proc_name => $prod_name.'(child)',

	# ожидание завершения основного процесса
	 die_timeout => 30,
	# ожидание завершения дочернего процесса после получения сигнала TERM
	 exit_on_term_wait_timeout => 20,
	# ожидание завершения дочернего процесса после получения сигнала KILL
	 exit_on_kill_wait_timeout => 10,
	# ожидание обновления метки времени для свободного дочернего процесса
	 time_label_refresh_period_for_free => 180,
	# ожидание обновления метки времени для занятого дочернего процесса
	 time_label_refresh_period_for_busy => 120,
});

$pm->pm_manage();

while ($pm->pm_loop() && (my $query = new CGI::Fast)) {
	$pm->pm_pre_dispatch();

    my $ua = LWP::UserAgent->new;
    $ua->timeout(1);
    
    my $response = $ua->get('http://localhost:8000/status-json.xsl');

    if ($response->is_success) {
        $answer->{result} = 200;
        $answer->{status} = $response->content();
    }
    else {
        $answer->{result} = 404;
        $answer->{status} = $response->status_line;
    }

    my $answer;
	json_out($query,$answer);
	$pm->pm_post_dispatch();
};
closelog();

sub json_out {
	my ($query, $outhash) = @_;
	#to_syslog($cfg, js::from_hash($outhash));
	
	print $query->header(-type=>'application/json',-charset=>'UTF-8');
#print $outhash,"\n";
	print js::from_hash($outhash), "\n";
}


sub to_syslog {
	my $msg = shift;
	syslog("alert", $msg);
};
1;
