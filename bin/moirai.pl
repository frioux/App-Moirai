#!/usr/bin/env perl

use 5.20.1;
use warnings;

use experimental 'signatures', 'postderef';

use IO::All;
use JSON;
use Getopt::Long::Descriptive;
use List::Util 'sum';

my ($opt, $usage) = describe_options(
   'moirai.pl %o',
   [ "mode" => hidden => { one_of => [
      [ 'report|R', 'show report with oldest days first' ],
      [ 'store|S',  'store new data' ],
      [ 'pretend|P', 'show report of what would have been stored' ],
      [ 'current|C', 'show the current day that would have been stored' ],
   ] } ],
   [],
   ['help|h', 'print usage message and exit' ],
);

print($usage->text), exit if $opt->help;

if ($opt->mode eq 'current') {
   my $mail = _count_mail();
   my $tabs = _count_tabs();

   print "mail: $mail, tabs: $tabs\n";
}


sub _count_mail {
   my $count = () = (
      io->dir("$ENV{HOME}/var/mail/INBOX/cur")->all,
      io->dir("$ENV{HOME}/var/mail/INBOX/new")->all
   );

   $count
}

sub _count_tabs {
   my $data = decode_json(
      io->file(
         "$ENV{HOME}/.mozilla/firefox/" .
            'kbwu05qn.default/' .
               'sessionstore-backups/recovery.js'
      )->all
   );

   scalar map $_->{tabs}->@*, $data->{windows}->@*
}
