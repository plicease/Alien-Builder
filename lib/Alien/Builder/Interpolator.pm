package Alien::Builder::Interpolator;

use strict;
use warnings;
use Carp qw( croak );

# ABSTRACT: Interpolate variables and helpers
# VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new

 my $itr = Alien::Builder::Interpolator->new(%args);

=over 4 

=item vars

=item helpers

=back

=cut

sub new
{
  my($class, %args) = @_;
  
  # copy
  my %vars = %{ $args{vars} || {} };
  my %helpers = %{ $args{helpers} || {} };
  $vars{'%'} = '%';  
  bless {
    vars => \%vars,
    helpers => \%helpers,
  }, $class;
}

sub _sub
{
  my($self, $key) = @_;
  $key =~ /^\{(.*)\}$/
    ? $self->_execute_helper($1)
    : $self->{vars}->{$key};
}

sub _execute_helper
{
  my($self, $name) = @_;
  my $code = $self->{helpers}->{$name};
  croak "no such helper: $name" unless defined $code;
  
  if(ref($code) ne 'CODE')
  {
    my $perl = $code;
    $code = sub {
      my $value = eval $perl;
      die $@ if $@;
      $value;
    };
  }
  
  $code->();
}

=head1 METHODS

=head2 interpolate

 my $string = $itr->interpolate($template);

=cut

sub interpolate
{
  my($self, $string) = @_;
  $string =~ s/\%(\{[a-zA-Z_][a-zA-Z_0-9]+\}|.)/$self->_sub($1)/eg;
  $string;
}

1;
