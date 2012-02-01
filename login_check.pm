#!/usr/bin/perl

use strict;
use warnings;
use Time::Piece;
use Time::Piece::MySQL;
use Time::Piece::Over24;

=pod
#0 reset , 1 no change, already access ,2 bonus up ,9 illegular ,undef illegular
my $rtn = &login_check(
  last_login=>$last_login_time,
  time_shift=>$time_shift, #optional,default 0
  login_span=>$span, #optional,default 86400 = one day
  now=>$t, #optional,default localtime() 
);
=cut

sub login_check {
  my $atr = {@_};

  my $now = $atr->{now} || localtime();
  my $login_span = $atr->{login_span} || 86400;
  my $time_shift = $atr->{time_shift} || 0;

  my $continu_ok_start = $atr->{last_login} + 86400 - $time_shift;
  $continu_ok_start = $now->from_mysql_datetime(
    $continu_ok_start->strftime('%Y-%m-%d 00:00:00')
  );
  my $continu_ok_end = $continu_ok_start + $login_span - 1;

  $now -= $time_shift;

  my $rtn = undef;
  if ($now > $continu_ok_end) {#�A�����Ă������Ԃ��߂��Ă���
    $rtn = 0;
  } elsif ($now < $continu_ok_start) {#�A�N�Z�X�ς�
    $rtn = 1;
  } elsif ($now->is_during($continu_ok_start,$continu_ok_end)) { #���O�C��ok
    $rtn = 2;
  } else {
    $rtn = 9;
  }
  return $rtn;
};

1;
