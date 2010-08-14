package ImageSizeGenerator::CMS;

use strict;

use LWP::Simple;
use Image::Size;

sub pre_save {
    my ($cb, $app, $entry, $org) = @_;
    my $q = $app->param;
    my $id = $entry->id;

    my @result;
    my $text = $q->param('text');
    if ($text) {
        @result = _insert_width_height($text);
        $entry->text(join("\n", @result));
    }
    my $text_more = $q->param('text_more');
    if ($text_more) {
        @result = _insert_width_height($text_more);
        $entry->text_more(join("\n", @result));
    }
    return 1;
}

#
# Special Thanks to
# Taku Amano <taku@toi-planning.net>
#
sub _width_height {
    my $src = shift;

    my $content = get($src);
    if (! $content) {
        return '';
    }
    my ($x, $y) = imgsize(\$content);
    return ' width="' . $x . '" height="' . $y .'" ';
}
sub _insert_width_height {
    my $text = shift;

    my $padding = '(((?!width=)(?!height=)[^>])*)';
    my $src = '(src="([^"]*)")';

    $text =~ s/(<\s*img\s+)$padding$src$padding(\/?>)/
        $1 . $2 . $4 . _width_height($5) . $6 . $8
    /ige;

    $text;
}

1;
