#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Text::Xatena;
use Encode;
use Cwd;
use Path::Class;
use File::HomeDir;
use Text::Xslate;
use File::Copy::Recursive qw(dircopy);
use Text::Xatena::Util;

binmode STDIN, ':utf8';

my $dir          = dir(File::HomeDir->my_home, ".cmd_slideshow"); 
my $js_dir       = dir($dir, "js"); 
my $title_template = 'title_template.html';
my $template     = 'template.html';
my $output_dir   = dir(cwd(),'slideshow');
my $thx          = Text::Xatena->new( hatena_compatible => 1 );
my $tx           = Text::Xslate->new( syntax => 'TTerse', path => [$dir]);

no strict 'refs';
no warnings 'redefine';
local *{"Text::Xatena::Node::SuperPre\::as_html"} = sub {
    my ($self, %opts) = @_;
    sprintf('<pre class="prettyprint">%s</pre>',
        escape_html(join "", @{ $self->children })
    );
};

sub parse {
    my $text = shift;
    return $thx->format($text);
}


sub render {
    my ($html,$id,$total,$title,$author) = @_;

    open my $fh, '>:utf8', "$output_dir/$id.html";
    my $string = $tx->render(
        ( $id == 1 ) ? $title_template : $template,
        { 
            total  => $total, 
            page   => $id,
            text   => $html, 
            title  => $title,
            author => $author,
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
        local $File::Copy::Recursive::CopyLink = 0;
        dircopy($js_dir,dir($output_dir,"js"));
    }
}

sub main {

    init();

    my $text           = join('', <STDIN>);
    my ($header,$body) = split /^__HEADER__$/m, $text;  
    my ($title)        = ($header =~ /^title:\s?(.+?)$/m); 
    my ($author)       = ($header =~ /^author:\s?(.+?)$/m); 
    my @count          = ($body =~ /^(__NEXT__)$/mg );
    my $total          = @count + 2;

    render( '', 1, $total ,$title, $author);                
    my $id = 2;
    for my $line ( split /^__NEXT__$/m, $body ) { 
        render( parse( $line ), $id++, $total ,$title, $author);                
    }

}

main();
