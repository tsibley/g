#!/usr/bin/env perl
# A DWIM wrapper for GNU grep and git grep that can open up matches for
# editing/reviewing in vim.
#
#     usage: g [opts] <pattern> [<paths>]
#            g [opts] <pattern> [<paths>] /v[i[mg]]
#            vig [opts] <pattern> [<paths>]
#
# Use `g` like grep, but with PCRE patterns and nicer default formatting for
# readability.
#
# Use `vig` the same way, but when you want to edit the matches in vim.
#
# For maximum Getting Out Of The Way, vim is invoked with a variety of options
# for stepping through results.
#
# 1. All matching files are loaded in the file list.  You can use `:n` to go the
#    next file.
#
# 2. The search pattern is preloaded into the current search as a vim-compatibile
#    regular expression (translated from PCRE).  You can use `n` to skip around
#    in a file between matches.  If you enable persistent search highlighting in
#    vim, you'll see matches highlighted.
#
# 3. The quickfix list is populated with the hits so that `:cn` will jump to the
#    line of the next result, moving to the next file as necessary.
#
# If you find yourself using the `:grep` command to search files and load up the
# quickfix list from within vim, you can tell vim to use `g` by putting the
# following in your `.vimrc`:
#
#     set grepprg=g
#
# For convenience, you can also invoke `vig` by appending `/vig` or `/vim` (or
# a shortened prefix) to a `g` command line.  This is handy when combined with
# Bash's history recall (e.g. Ctrl-P or the up arrow).
#
use strict;
use warnings;
use open qw/ :std :encoding(UTF-8) /;

use File::Basename qw(basename);
use File::Temp qw(tempfile);

sub main {
    my $prog = basename($0);

    unless (@ARGV) {
        print_usage();
        return 1;
    }

    if ($prog eq "vig") {
        exec_vim(@ARGV);
    } else {
        if (@ARGV > 1 and $ARGV[-1] =~ m{^/v(i[mg]?)?$}) {
            pop @ARGV;
            exec_vim(@ARGV);
        } else {
            exec_grep(@ARGV);
        }
    }

    die "Dispatch error in main()‽  This is a bug!";
}

sub print_usage {
    seek DATA, 0, 0;
    while (<DATA>) {
        if (s/^# ?//) {
            print;
        } else {
            last;
        }
    }
}

sub exec_vim {
    my @args = @_;

    # Capture output without dealing with shell escaping
    my @hits;
    my $pid = open my $kid, "-|";
    die "Can't fork: $!" unless defined $pid;

    if (not $pid) {
        exec_grep(@args);
    } else {
        @hits = <$kid>;
        chomp for @hits;
        close $kid;
    }

    if (@hits) {
        my ($tmpfh, $tmpfn) = tempfile( "g-XXXXX", TMPDIR => 1 );
        binmode $tmpfh, ":encoding(UTF-8)";
        print { $tmpfh } "$_\n" for @hits;
        close $tmpfh;

        my %seen;
        my @files = grep { not $seen{$_}++ } map { /^(.+?):\d/; $1 } @hits;

        my @vim = (
            "vim",
            "+1",
            '+/\v' . translate_pattern(extract_pattern(@args)),
            "+set errorformat=%f:%l:%c:%m,%f:%l:%m",
            "+cfile $tmpfn",
            "--",
            @files
        );

        exec @vim
            or die "Can't exec «@vim»: $!";
    } else {
        die "No matches to open.\n";
    }
}

sub exec_grep {
    my @args = @_;
    my $pattern = extract_pattern(@args);
    my $for_humans = -t STDOUT;
    my $search_stdin = not -t STDIN;
    my $in_git_repo = `git rev-parse --git-dir 2>/dev/null`;
    my $use_git_grep = (not $search_stdin and $in_git_repo);

    my @grep = (
        ($use_git_grep
            ? "git"
            : ()),

        "grep",
        "-HI",

        ((not $search_stdin and not $use_git_grep)
            ? "--dereference-recursive"
            : ()),

        ($use_git_grep
            ? "--recurse-submodules"
            : ()),

        "--perl-regexp",
        "--line-number",

        ($for_humans
            ? "--color=always"
            : "--color=never"),

        ($use_git_grep
            ? $for_humans
                ? ("--heading",
                   "--break")
                : ("--column")
            : ()),

        # Emulate smartcase (poorly)
        ($pattern eq lc $pattern
            ? "-i"
            : ()),

        @args,
    );

    exec @grep
        or die "Can't exec «@grep»: $!";
}

sub extract_pattern {
    my $grabnext;

    for (@_) {
        if ($grabnext or not /^-/) {
            return $_;
        }
        elsif (/^--$/) {
            $grabnext = 1;
        }
    }
    return undef;
}

sub translate_pattern {
    my $pattern = shift;

    # Try to make vim's magic mode more like Perl's standard regexes
    # Magic chars gleaned from :help magic, and the most common problem
    # characters are < and >
    my $vimpat = $pattern;
       $vimpat =~ s{([<>=@!%/&])}{\\$1}g;
       $vimpat =~ s{(^|(?<=[^\\]))\\b}{\\W\\@=}g; # translate Perl's \b to \W\@= for vim

       # Translate Perl's lookaheads and lookbehinds for vim:
       #    (?=...) and (?!...) to (...)@= and (...)@!
       #
       # It's a little uglier because this is after escaping metachars
       # above.  The matching of the actual pattern part will fail if it
       # contains a ) in the middle as .+? is non-greedy and we're not
       # doing balanced matching.  It's better to fail this way than to
       # fail by gobbling up too much.
       $vimpat =~ s{\(\?(?:\\(<?))?(?:\\([=!]))(.+?)\)}{($3)\@$1$2}g;

       # Translate the two most common non-greedy modifiers in Perl to Vim.
       $vimpat =~ s/\Q*?/{-}/g;
       $vimpat =~ s/\Q+?/{-1,}/g;

       # see https://github.com/google/re2/wiki/Syntax

    return $vimpat;
}

exit main();

__DATA__
