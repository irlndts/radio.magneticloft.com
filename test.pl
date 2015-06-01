#!/usr/bin/perl -w


use strict;

use MP3::Icecast;
use MP3::Info;
use IO::Socket;
use Data::Dumper;

my $listen_socket = IO::Socket::INET->new(
    LocalPort => 8000, #standard Icecast port
    Listen    => 20,
    Proto     => 'tcp',
    Reuse     => 1,
    Timeout   => 3600);

print Dumper($listen_socket);

my $finder = MP3::Icecast->new();
$finder->recursive(1);
$finder->add_directory('/home/piskun/Radio/');
my @files = $finder->files;

my $icy;
#accept TCP 8000 connections
while(1){
    next unless my $connection = $listen_socket->accept;

    defined(my $child = fork()) or die "Can't fork: $!";
    if($child == 0){
        $listen_socket->close;

        $icy = MP3::Icecast->new;

        #stream files that have an ID3 genre tag of "jazz"
        while(@files){
            my $file = shift @files;
            #my $info = new MP3::Info $file;
            #next unless $info;
            #next unless $info->genre =~ /jazz/i;
            $icy->stream($file,0,$connection);
        }
        exit 0;
    }

    #a contrived example to demonstrate that MP3::Icecast
    #can generate M3U and PLSv2 media playlists.
    #print STDERR $icy->pls, "\n";

    $connection->close;
}
