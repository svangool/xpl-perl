package xPL::Dock::Plug;

=head1 NAME

xPL::Dock::Plug - xPL::Dock plugin for a Plug Device

=head1 SYNOPSIS

  use xPL::Dock::Plug;

  sub process_buffer {
    my ($xpl, $buffer, $last_sent) = @_;
    ...
    return $buffer; # any unprocessed bytes
  }
  my $xpl = xPL::Dock::Plug->new(reader_callback => \&process_buffer);
  $xpl->main_loop();

=head1 DESCRIPTION

This module creates an xPL client for a serial port-based device.  There
are several usage examples provided by the xPL Perl distribution.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;
use xPL::Base;
use Pod::Usage;
our @ISA = qw(xPL::Base);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

__PACKAGE__->make_readonly_accessor($_) foreach (qw/xpl verbose/);

=head2 C<getopts()>

=cut

sub getopts {
  return
}

=head2 C<new(%params)>

The constructor creates a new xPL::Dock::Plug object.  It returns a
blessed reference when successful or undef otherwise.

=cut

sub new {
  my $pkg = shift;
  bless {}, $pkg;
}

=head2 C<init(%params)>

=cut

sub init {
  my ($self, $xpl) = @_;
  $self->{_xpl} = $xpl;
  return 1;
}

=head2 C<required_field( $name, $message, $use_argv )>

This method handles the checking of a require parameter for a plugin.

=cut

sub required_field {
  my ($self, $xpl, $name, $message, $use_argv) = @_;
  my $field = '_'.$name;
  my $val = $self->{$field};
  my $ref = ref $val;
  if ($use_argv && scalar $xpl->plugins) {
    if ($ref) {
      unless (scalar @$ref) {
        if (scalar @ARGV) {
          $self->{$field} = \@ARGV;
        } else {
          pod2usage(-message => $message.
                    "or the values can be given as command line arguments",
                    -exitstatus => 1);
        }
      }
    } else {
      unless (defined $val) {
        if (scalar @ARGV) {
          $self->{$field} = shift @ARGV;
        } else {
          pod2usage(-message => $message.
                    "\nor the value can be given as a command line argument",
                    -exitstatus => 1);
        }
      }
    }
  } else {
    if ($ref) {
      unless (scalar @$ref) {
        pod2usage(-message => $message,
                  -exitstatus => 1);
      }
    } else {
      unless (defined $val) {
        pod2usage(-message => $message,
                  -exitstatus => 1);
      }
    }
  }
  return 1;
}

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

Project website: http://www.xpl-perl.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>soft-xpl-perl@temporalanomaly.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2009 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
