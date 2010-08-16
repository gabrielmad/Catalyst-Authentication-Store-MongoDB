package Catalyst::Authentication::Store::MongoDB::User;

use Moose;
use namespace::autoclean;
extends 'Catalyst::Authentication::User';

use List::MoreUtils 'all';
use Try::Tiny;

has 'config' => (is => 'rw');
has 'coll'   => (is => 'rw');
has '_user'  => (is => 'rw');

sub new {
    my ( $class, $config, $c) = @_;

    $config->{user_model} = $config->{user_class} unless defined $config->{user_model};

    my $self = {
        coll   => $c->model( $config->{'user_model'} )->c,
        config => $config,
        _user  => undef
    };

    bless $self, $class;

    $self->config->{lazyload} = 0;
    return $self;
}

sub load {
    my ($self, $authinfo, $c) = @_;
   
    $self->_user( $self->coll->find_one( $authinfo ) );

    if ($self->get_object) {
        return $self;
    } else {
        return undef;
    }
}

sub get {
    my ($self, $field) = @_;
    return exists($self->_user->{$field}) ? $self->_user->{$field} : undef;
}

sub get_object {
    my ($self, $force) = @_;
    return $self->_user;
}

sub obj {
    shift->get_object(shift);
}

sub for_session {
    my $self = shift;
    $self->_user->{_id}->to_string;
}
sub from_session {
    my $self = shift;
    my $id   = shift;
    $self->load( _id => $id );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;