#!/usr/bin/env perl
# F166.3, run once (Louis's pick: the move as commands kept as the record, with no tests, as F167's rename was). Reads
# Puls's files from a commit of louis-agent and writes them here in the usual .NET layout under Puls's own names:
#
#   perl tools/moved-from-louis-agent/move.pl <louis-agent folder> <commit or tag> dry|write
#
# Every Puls project goes to src/ or tests/ under the name names.tsv gives it; the rest of demos/puls goes to the root
# (config, deploy, docker, docs, skills), its coming-soon page to coming-soon/, and the three packs' docs to
# docs/projects/. In every text file the old project names become the new ones, whole names only and the longest
# first, so a namespace below a name follows it and no framework name is touched. A reference to a framework project
# becomes a package reference at its published version; one to another Puls project points at its new place. It
# prints what it did, or in a dry run what it would do, and the words it left for a person.

use strict;
use warnings;
use File::Basename qw(dirname);
use File::Path qw(make_path);
use FindBin qw($Bin);

my ($from, $ref, $mode) = @ARGV;
die "usage: move.pl <louis-agent folder> <commit or tag> dry|write\n"
    unless defined $mode && $mode =~ /\A(?:dry|write)\z/;
my $here = "$Bin/../..";

# The framework's packages and their published versions (F166.2, F166.3 step 2).
my %published = map { ($_ => '0.1.0') } qw(
    LouisAgent.Choices LouisAgent.Composition LouisAgent.Core LouisAgent.Core.Anthropic LouisAgent.Core.Ollama
    LouisAgent.Core.OpenAi LouisAgent.Core.Telemetry LouisAgent.Core.Web LouisAgent.SessionStream LouisAgent.Evals
    LouisAgent.Evals.Checks LouisAgent.Evals.Protocol LouisAgent.Evals.Runner LouisAgent.Accounts
    LouisAgent.Accounts.Contracts LouisAgent.Api LouisAgent.Api.Contracts LouisAgent.Api.Evals LouisAgent.Web
    LouisAgent.Web.Accounts LouisAgent.Web.Evals LouisAgent.Diagrams LouisAgent.Diagrams.Engine
    LouisAgent.Packs.Calculator LouisAgent.Packs.DotNet LouisAgent.Packs.Files LouisAgent.Packs.Git
    LouisAgent.Packs.Shell LouisAgent.Packs.Web LouisAgent.Web.Testing);
$published{$_} = '0.2.0'
    for qw(LouisAgent.Testing LouisAgent.Web LouisAgent.Web.Evals LouisAgent.Evals.Runner LouisAgent.Composition);
$published{'LouisAgent.Web.Testing'} = '0.3.0';

# The name table.
my (%new, %side);
open my $table, '<', "$Bin/names.tsv" or die "can't read names.tsv: $!";
while (my $line = <$table>) {
    $line =~ s/\r?\n\z//;
    next if $line eq '' || $line =~ /^#/;
    my ($old, $renamed, $where) = split /\t/, $line;
    ($new{$old}, $side{$old}) = ($renamed, $where);
}
my $names = join '|', map { quotemeta } sort { length($b) <=> length($a) } keys %new;
# A name may also start right after a JSON label's \n escape, whose n would otherwise read as part of a word.
my $whole = qr/(?:(?<![A-Za-z0-9_])|(?<=\\n))($names)(?![A-Za-z0-9_])/;

# Git's own list of the files at that commit, asked with its arguments as a list.
sub git { open my $out, '-|', 'git', '-C', $from, @_ or die "git: $!"; local $/; my $text = <$out>; close $out; $text }
my @files = grep { m{^demos/puls/} || m{^packs/[^/]+/(?:LouisAgent\.Packs\.(?:Recipes|ShopPrices|WhereToBuy))}
                   || m{^packs/docs/projects/(?:diagrams/)?LouisAgent\.Packs\.(?:Recipes|ShopPrices|WhereToBuy)} }
    split /\n/, git('ls-tree', '-r', '--name-only', $ref);

# Where a file goes: a project's folder by the table, the rest of demos/puls to the root.
my %projectFolder;
for my $file (grep { /\.csproj\z/ } @files) {
    my ($dir, $name) = $file =~ m{^(.*)/([^/]+)\.csproj\z} or next;
    $projectFolder{$dir} = $name if exists $new{$name};
}
# The recipes pack's copies of three framework readers stay behind with their test: Puls reads with the framework's
# own from LouisAgent.Composition (Louis's pick A of F166.3's finding 10).
my %leftBehind = map { ($_ => 1) } qw(
    packs/tools/LouisAgent.Packs.Recipes/Reading/HtmlText.cs packs/tools/LouisAgent.Packs.Recipes/Reading/LeadImage.cs
    packs/tools/LouisAgent.Packs.Recipes/Reading/JsonLdBlocks.cs
    demos/puls/tests/LouisAgent.HostPacks.Tests/Copies/PageReaderCopyTests.cs);

sub place {
    my ($file) = @_;
    return undef if $leftBehind{$file};
    for my $dir (sort { length($b) <=> length($a) } keys %projectFolder) {
        next unless index($file, "$dir/") == 0;
        my $name = $projectFolder{$dir};
        return "$side{$name}/$new{$name}/" . substr($file, length($dir) + 1);
    }
    return 'coming-soon/' . substr($file, length 'demos/puls/web/coming-soon/') if $file =~ m{^demos/puls/web/coming-soon/};
    return substr($file, length 'demos/puls/') if $file =~ m{^demos/puls/};
    return 'docs/projects/' . substr($file, length 'packs/docs/projects/') if $file =~ m{^packs/docs/projects/};
    return undef;
}

# A path in a text becomes the new one: each project's folder first, the longest first, then demos/puls itself.
my @paths = map { [ $_, "$side{$projectFolder{$_}}/$new{$projectFolder{$_}}" ] }
    sort { length($b) <=> length($a) } keys %projectFolder;

my (%counts, %left);
for my $file (@files) {
    my $to = place($file);
    unless (defined $to) { $counts{'left in louis-agent'}++; next; }
    $to =~ s/$whole/$new{$1}/g;    # a file or folder named for a project takes its new name
    my $text = git('show', "$ref:$file");

    if ($text !~ /\0/) {
        for my $path (@paths) {
            my ($old, $renamed) = @$path;
            (my $back = $old) =~ s{/}{\\}g;
            (my $newBack = $renamed) =~ s{/}{\\}g;
            $counts{'paths rewritten'} += $text =~ s/\Q$old\E/$renamed/g;
            $counts{'paths rewritten'} += $text =~ s/\Q$back\E/$newBack/g;
        }
        # An eval project copies its files under its path from the root, which it names by $(MSBuildProjectName).
        $counts{'paths rewritten'} += $text =~ s{EvalFiles\\demos\\puls\\evals\\}{EvalFiles\\src\\}g;
        # A path built from its parts, and the one test that found the root by louis-agent's own solution's name.
        $counts{'paths rewritten'} +=
            $text =~ s{"demos/puls/evals", "LouisAgent\.Identities\.Puls\.Evals"}{"src", "Puls.Evals"}g;
        $counts{'paths rewritten'} += $text =~ s{"louis-agent-solution\.sln"}{"Puls.sln"}g;
        $counts{'paths rewritten'} += $text =~ s{demos/puls/web/coming-soon}{coming-soon}g;
        $counts{'paths rewritten'} += $text =~ s{demos/puls/}{}g;
        $counts{'paths rewritten'} += $text =~ s{packs/docs/projects/}{docs/projects/}g;
        $counts{'names rewritten'} += $text =~ s/$whole/$new{$1}/g;
        # The framework's Sass comes from its packages now, unpacked into the site's obj/framework-sass (F166.3, 3b).
        $counts{'Sass include paths to the packages'} += $text =~
            s{"IncludePaths":\s*\[[^\]]*\]}{"IncludePaths": [ "obj/framework-sass" ]}
            if $to =~ m{/sasscompiler\.json\z};
        if ($to =~ /\.csproj\z/) {
            # A framework project becomes its package; another Puls project is found at its new place.
            $counts{'framework references to packages'} += $text =~
                s{<ProjectReference\s+Include="[^"]*?[\\/](LouisAgent\.[A-Za-z.]+)\.csproj"\s*/>}{
                    exists $published{$1} ? qq{<PackageReference Include="$1" Version="$published{$1}" />}
                                          : do { $counts{'framework references NOT published'}++;
                                                 qq{<ProjectReference Include="..\\..\\FRAMEWORK-NOT-PUBLISHED\\$1.csproj" />} }}ge;
            $counts{'Puls references moved'} += $text =~
                s{<ProjectReference\s+Include="[^"]*?[\\/](Puls\.[A-Za-z.]+)\.csproj"\s*/>}{
                    my $p = $1; my ($s) = grep { $new{$_} eq $p } keys %new;
                    qq{<ProjectReference Include="..\\..\\$side{$s}\\$p\\$p.csproj" />}}ge;
        }
        push @{ $left{$1} }, $to while $text =~ /(LouisAgent\.(?!(?:Choices|Composition|Core|SessionStream|Evals|Accounts|Api|Web|Diagrams|Packs\.(?:Calculator|DotNet|Files|Git|Shell|Web)|Testing)\b)[A-Za-z.]+)/g;
        push @{ $left{'demos/ path'} }, $to if $text =~ m{demos/};
    }
    $counts{"files to $1"}++ if $to =~ m{^([^/]+)/};
    next unless $mode eq 'write';
    make_path(dirname("$here/$to"));
    open my $out, '>:raw', "$here/$to" or die "can't write $to: $!";
    print {$out} $text;
    close $out;
}

print "F166.3 move ($mode) from $ref:\n";
printf "%6d  %s\n", $counts{$_}, $_ for sort keys %counts;
print "\nWords left for a person:\n";
printf "%6d  %s  %s\n", scalar @{ $left{$_} }, $_, $left{$_}[0] for sort keys %left;
