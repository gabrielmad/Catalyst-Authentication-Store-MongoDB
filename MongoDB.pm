package Catalyst::Authentication::Store::MongoDB;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

our $VERSION= "0.01";


BEGIN {
    __PACKAGE__->mk_accessors(qw/config/);
}


sub new {
    my ( $class, $config, $app ) = @_;

    ## figure out if we are overriding the default store user class
    $config->{'store_user_class'} = (exists($config->{'store_user_class'}))
                                    ? $config->{'store_user_class'}
                                    : "Catalyst::Authentication::Store::MongoDB::User";

    ## make sure the store class is loaded.
    Catalyst::Utils::ensure_class_loaded( $config->{'store_user_class'} );

    my $self = {
        config => $config
    };

    bless $self, $class;
}

sub from_session{
    my ($self, $c, $id) = @_;
    my $user = $self->config->{'store_user_class'}->new( $self->config, $c );
    return $user->from_session( $id, $c );
}

sub for_session{
    my ($self, $c, $user) = @_;
    return $user->for_session($c);
}

sub find_user {
    my ( $self, $authinfo, $c ) = @_;
    my $user = $self->config->{'store_user_class'}->new( $self->config, $c );
    return $user->load($authinfo, $c);
}

1;