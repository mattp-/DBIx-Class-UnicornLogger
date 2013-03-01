package DBIx::Class::UnicornLogger::FromProfile;

# ABSTRACT: Define your UnicornLogger with a single string!

use Moo;

extends 'DBIx::Class::UnicornLogger';

sub get_profile {
   my ($self, $profile_name) = @_;

   my $ret = {};
   if ($profile_name) {
      if (my $profile = $self->profiles->{$profile_name}) {
         $ret = $profile
      } else {
         warn "no such profile: '$_[1]', using empty profile instead";
      }
   }
   return $ret
}

sub profiles {
   my @good_executing = (
      executing =>
      eval { require Term::ANSIColor } ? do {
          my $c = \&Term::ANSIColor::color;
          $c->('blink white on_black') . 'EXECUTING...' . $c->('reset');
      } : 'EXECUTING...'
   );
   return {
      console => {
         tree => { profile => 'console' },
         clear_line => "\r\x1b[J",
         show_progress => 1,
         @good_executing,
      },
      console_monochrome => {
         tree => { profile => 'console_monochrome' },
         clear_line => "\r\x1b[J",
         show_progress => 1,
         @good_executing,
      },
      plain => {
         tree => { profile => 'console_monochrome' },
         clear_line => "DONE\n",
         show_progress => 1,
         executing => 'EXECUTING...',
      },
      demo => {
         tree => { profile => 'console' },
         format => '[%d][%F:%L]%n%m',
         clear_line => "DONE\n",
         show_progress => 1,
         executing => 'EXECUTING...',
      },
   }
}

sub BUILDARGS {
   my ($self, @rest) = @_;

   my %args = (
      @rest == 1
         ? %{$rest[0]}
         : @rest
   );

   %args = (
      %{$self->get_profile(delete $args{unicorn_profile})},
      %args,
   );

   return $self->next::method(\%args)
}

1;

__END__

=pod

=head1 SYNOPSIS

 use DBIx::Class::UnicornLogger::FromProfile;
 my $debug_object = DBIx::Class::UnicornLogger::FromProfile->new(
    unicorn_profile => 'console'
 );

=head1 DESCRIPTION

This package is merely a collection of unicorn profiles.  Currently there are
only a few but I'm completely willing to incorporate everyone's settings into
this module.  So if you have a tweak you want to make to it, let me know!

=head1 PROFILES

=over 2

=item * console - ok default

=item * console_monochrome - use this if you hate color

=item * plain - use this if you're on windows

=item * demo - this merely shows a few of the capabilities of L<DBIx::Class::UnicornLogger>.

=back

=head1 SEE ALSO

L<DBIx::Class::UnicornLogger>, L<SQL::Abstract::Tree>

