#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Text::Xatena;
use Encode;
use FindBin;
use Path::Class;
use File::HomeDir;
use Text::Xslate;

binmode STDIN, ':utf8';

my $dir          = dir(File::HomeDir->my_home, ".cmd_slideshow"); 
my $template     = 'template.html';
my $output_dir   = dir($FindBin::Bin,'slideshow');
my $thx          = Text::Xatena->new;
my $tx           = Text::Xslate->new( syntax => 'TTerse', path => [$dir]);

sub parse {
    my $text = shift;
    return $thx->format($text);
}

sub render {
    my ($html,$id,$total) = @_;

    open my $fh, '>:utf8', "$output_dir/$id.html";
    my $string = $tx->render(
        $template,
        { 
            total => $total, 
            page => $id,
            text => $html, 
        }
    );
    print $fh $string; 
    close $fh;
};

sub init {
    unless( -e $dir ){
        die "please mkdir $dir";
    }

    unless( -e $output_dir ) {
        mkdir $output_dir;
    }
}

sub main {

    init();

    my $text  = join('', <STDIN>);
    my $total = ($text =~ /^(__NEXT__)$/mg ) + 1;

    my $id = 1;
    for my $line ( split /^__NEXT__$/m, $text ) { 
        render( parse( $line ), $id++, $total );                
    }

}

main();
