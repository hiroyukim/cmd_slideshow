#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Text::Xatena;
use Encode;

my $thx    = Text::Xatena->new;
my $header = q{<html><title>sldideshow</title><body>}; 
my $footer = q{</body></html>}; 

sub parse {
    my $text = shift;
    return $thx->format($text);
}

sub render {
    my $html = shift;
    my $id   = shift;

    $html = $header . $html . $footer;

    open my $fh, '>', $id . '.html';
    print $fh encode('utf8',$html);
    close $fh;
};

sub main {
    my @text;
    my $id = 1;
    while(my $line = decode('utf8',<>) ) {
        if( $line =~ /^__NEXT__$/ ) {
            render( parse( join("",@text),), $id++ );                
        }
        else {
            push @text,$line;
        }
    }

    if( @text ) {
        render( parse( join("",@text),), $id );                
    }
}

&main();
