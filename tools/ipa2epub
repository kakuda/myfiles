#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use File::Path;

sub clean{
    File::Path::rmtree('Payload');
}

my $src = shift;
die "usage:$0 src.ipa [dst.epub]" unless -f $src;
my $dst = shift;
if (!$dst){
    $dst = basename($src);
    $dst =~ s/\w+$/epub/;
}

system qw/unzip -q/, $src, qw/-x iTunes*/;
die $! if $!;
my $app = <Payload/*.app/book>;
clean and die "No book found in the archive" unless $app;
chdir $app;
my $updir = '../../..';
system qw/zip -q0X/, "$updir/$dst", 'mimetype';
system qw/zip -qXr9D/, "$updir/$dst", qw/ META-INF OEBPS/;
chdir $updir;
clean;
system qw{open -a /Applications/iTunes.app}, $dst;
