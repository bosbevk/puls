#!/usr/bin/env perl
# F166.3 step 7, run once after the move, and kept as the record with it: a doc link that climbed to louis-agent's
# root and named a path from there leads nowhere here. Each such link becomes a link that works:
#
#   perl tools/moved-from-louis-agent/fix-links.pl <louis-agent folder> <tag> dry|write
#
# When the path, under Puls's own names, is in this repository, the link becomes the right relative link to it; when
# it is in louis-agent at the tag, a GitHub link to it there, at that tag, so it shows what Puls was built against.
# A link that matches neither is printed for a person. Links that already work are left as they are.

use strict;
use warnings;
use Cwd ();
use File::Basename qw(dirname);
use File::Find;
use File::Spec;
use FindBin qw($Bin);

my ($from, $ref, $mode) = @ARGV;
die "usage: fix-links.pl <louis-agent folder> <tag> dry|write\n" unless defined $mode && $mode =~ /\A(?:dry|write)\z/;
my $root = Cwd::abs_path("$Bin/../..");
my $web = "https://github.com/bosbevk/louis-agent/blob/$ref/";

# What louis-agent held at the tag, asked of git with its arguments as a list.
open my $list, '-|', 'git', '-C', $from, 'ls-tree', '-r', '--name-only', $ref or die "git: $!";
my %there = map { chomp; ($_ => 1) } <$list>;
close $list;
my %folderThere = map { my $d = $_; my %d; $d{$d}++ while ($d =~ s{/[^/]+\z}{}); %d } keys %there;

my (%counts, @left);
find({ no_chdir => 1, wanted => sub {
    return unless /\.md\z/ && !m{/(?:bin|obj|tools)/};
    my $file = $_;
    open my $in, '<:raw', $file or die "can't read $file: $!";
    my $text = do { local $/; <$in> };
    close $in;
    my $dir = dirname($file);
    my $changed = $text =~ s{\]\(((?:\.\./)+)([^)#\s]+)(#[^)\s]*)?\)}{
        my ($climb, $path, $anchor) = ($1, $2, $3 // '');
        if (-e "$dir/$climb$path") { "]($climb$path$anchor)" }
        elsif (-e "$root/$path") {
            $counts{'to this repository'}++;
            "](" . File::Spec->abs2rel("$root/$path", File::Spec->rel2abs($dir)) =~ s{\\}{/}gr . "$anchor)" }
        elsif ($there{$path} || $folderThere{$path =~ s{/\z}{}r}) { $counts{'to louis-agent at the tag'}++; "]($web$path$anchor)" }
        elsif (my $old = FromOldPlace($file, $climb . $path)) {
            $counts{'to louis-agent at the tag, from where the doc was'}++; "]($web$old$anchor)" }
        else { push @left, "$file: $climb$path"; "]($climb$path$anchor)" }
    }ge;
    return unless $mode eq 'write' && $changed;
    open my $out, '>:raw', $file or die "can't write $file: $!";
    print {$out} $text;
    close $out;
} }, map { "$root/$_" } qw(docs config deploy skills coming-soon));

# A link that climbed from where its doc sat in louis-agent: the three packs' docs were under packs/docs/, the rest of
# Puls's under demos/puls/. The path it named there, when louis-agent had it at the tag.
sub FromOldPlace {
    my ($file, $link) = @_;
    my $here = File::Spec->abs2rel(dirname($file), $root) =~ s{\\}{/}gr;
    my $was = $here =~ m{^docs/projects} && $file =~ m{/Puls\.Packs\.} ? "packs/$here" : "demos/puls/$here";
    my @parts = split m{/}, $was;
    for my $step (split m{/}, $link) {
        if ($step eq '..') { return undef unless @parts; pop @parts } else { push @parts, $step }
    }
    my $path = join '/', @parts;
    return $there{$path} ? $path : undef;
}

print "F166.3 links ($mode), against louis-agent at $ref:\n";
printf "%6d  %s\n", $counts{$_}, $_ for sort keys %counts;
print "\nLeft for a person:\n", map { "  $_\n" } @left;
