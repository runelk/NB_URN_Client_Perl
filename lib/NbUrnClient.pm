#!/usr/bin/env perl

package NbUrnClient;

use strict;
use SOAP::Lite;
use YAML::Tiny;
use Data::Dumper;

sub new {
    my $class = shift;
    my %args = @_;
    my $self = {};
    $self->{config_file} = $args{config_file};
    $self->{sso_token} = undef;
    $self->{config} = YAML::Tiny->read($args{config_file})->[0]->{config}{urn};

    $self->{client} = SOAP::Lite->new(proxy => $self->{config}->{proxy});
    $self->{client}->ns('http://nb.no/idservice/v1.0/', 'ns1');
    $self->{client}->autotype(0);

    bless $self, $class;
    return $self;
}

sub add_url {
    my ($self, $urn, $url) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub create_urn {
    my ($self, $seriesCode, $url) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub delete_url {
    my ($self, $urn, $url) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub find_urn {
    my ($self, $urn) = @_;

    my $som = $self->{client}->call(
    	'findURN', SOAP::Data->value(SOAP::Data->name('URN')->value($urn))
	);
    die $som->faultstring if ($som->fault);

    return $som->result;
}

sub find_urns_for_url {
    my ($self, $url) = @_;

    my $som = $self->{client}->call(
    	'findURNsForURL', SOAP::Data->value(SOAP::Data->name('URL')->value($url))
	);
    die $som->faultstring if ($som->fault);

    return $som->result;
}

sub get_next_urn {
    my ($self, $seriesCode) = @_;

#     if (defined $self->{sso_tdie "Not implemented yet.";
# oken}) {
#     }
#     else {
# 	die "No SSO token acquired, you must log in first.";
#     }
# }
}

sub login {
    my ($self, $username, $password) = @_;

}

sub logout {
    my ($self) = @_;

    die "Not implemented yet.";
#     if (defined $self->{sso_token}) {
# 	$self->{client}->{service}->logout($self->{sso_token});
# 	$self->{sso_token} = undef;
#     }
# }
}

sub register_urn {
    my ($self, $urn, $url) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub replace_url {
    my ($self, $urn, $oldURL, $newURL) = @_;

#     if (defined $self->{sso_tdie "Not implemented yet.";
# oken}) {
#     }
#     else {
# 	die "No SSO token acquired, you must log in first.";
#     }
# }
}

sub reserve_next_urn {
    my ($self, $seriesCode) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub reserve_urn {
    my ($self, $urn) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

sub set_default_url {
    my ($self, $urn, $url) = @_;

    die "Not implemented yet.";
    # if (defined $self->{sso_token}) {
    # }
    # else {
    # 	die "No SSO token acquired, you must log in first.";
    # }
}

1;
