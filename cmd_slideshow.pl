use strict;
use warnings;
use utf8;
use Text::Hatena;
use Encode;

{
    no strict 'refs';
    no warnings 'redefine';
    *{"Text::Hatena\::super_pre"} = sub {
        my $class = shift;
        my $items = shift->{items};
        my $item = $items->[0] or return;
        $item =~ s/^.*?>|(\w+)|$/$1/;
        my $filter = $1 || $item;
        my $texts = $class->expand($items->[1]);
        return "<pre name=\"code\" class=\"$filter\">\n$texts</pre>\n";
    };
}

my $header = q{
<html>
    <title>sldideshow</title>
    <body>
};

my $footer = q{
    </body>
</html>
};

sub parse {
    my $text = shift;
    my $html = Text::Hatena->parse($text);
}

sub render {
    my $html = shift;
    my $id   = shift;

    $html = $header . $html . $footer;

    open my $fh, '>', $id . '.html';
    print $fh encode('utf8',$html);
    close $fh;
};

my @text;
my $id = 0;
while(my $line = decode('utf8',<>) ) {
    if( $line =~ /^__NEXT__$/ ) {
        render( parse( join("",@text),), ++$id );                
    }
    else {
        push @text,$line;
    }
}

if( @text ) {
    render( parse( join("",@text),), $id );                
}


