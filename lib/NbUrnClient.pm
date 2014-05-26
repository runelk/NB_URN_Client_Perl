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
    $self->{config}->{username} = $args{username} || $self->{config}->{username};
    $self->{config}->{password} = $args{password} || $self->{config}->{password};

    $self->{client} = SOAP::Lite->new(proxy => $self->{config}->{proxy});
    $self->{client}->ns('http://nb.no/idservice/v1.0/', 'ns1');
    $self->{client}->autotype(0);

    bless $self, $class;
    return $self;
}

sub add_url {
    my ($self, $urn, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'addURL',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub create_urn {
    my ($self, $series_code, $urn) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'createURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('seriesCode')->value($series_code)),
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub delete_url {
    my ($self, $urn, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'deleteURL',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
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

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'getNextURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('seriesCode')->value($urn))
	    );

	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub login {
    my ($self, $username, $password) = @_;

    my $som = $self->{client}->call(
    	'login',
	SOAP::Data->value(SOAP::Data->name('username')->value($username || $self->{config}->{username})),
	SOAP::Data->value(SOAP::Data->name('password')->value($password || $self->{config}->{password}))
	);
    die $som->faultstring if ($som->fault);

    $self->{sso_token} = $som->result;
    return $som->result;
}

sub logout {
    my ($self) = @_;

    if (defined $self->{sso_token}) {
	$self->{client}->call(
	    'logout',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    );
	$self->{sso_token} = undef;
    }
}

sub register_urn {
    my ($self, $urn, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'registerURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub replace_url {
    my ($self, $urn, $oldURL, $newURL) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'replaceURL',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),
	    SOAP::Data->value(SOAP::Data->name('oldURL')->value($old_url)),	    
	    SOAP::Data->value(SOAP::Data->name('newURL')->value($new_url)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub reserve_next_urn {
    my ($self, $series_code) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'reserveNextURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('seriesCode')->value($series_code))
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub reserve_urn {
    my ($self, $urn) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'reserveURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn))
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

sub set_default_url {
    my ($self, $urn, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'setDefaultURL',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn))
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url))
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

1;
