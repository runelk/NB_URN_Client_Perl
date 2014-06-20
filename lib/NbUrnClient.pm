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

# Add a new URL that is to be associated with the specified URN.
#         Keyword arguments:
#         urn -- the URN to associate the new target to 
#         url -- the URL pointing to the target
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

# Create a new URN under the specified series/prefix.
#         Keyword arguments:
#         series_code -- the series code / prefix under which to create a new URN
#         url -- the URL pointing to the target of the URN
#         NB: This will only work if:
#         - the ID service supports assignment of serial numbers for the specified series, and
#         - if the user has access to this series.
#         The created URN is stored in the ID service.
sub create_urn {
    my ($self, $series_code, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'createURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('seriesCode')->value($series_code)),
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url)),	    
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

# Delete a URL pointing to a target associated with the given URN.

#         Keyword arguments:
#         urn -- the URN associated with the URL to delete
#         url -- The URL to delete

#         This operation is only allowed as long as there is more than one registered target for the specified URN.
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

# Find a registered URN with all corresponding locations, along with
#         other registered information regarding the URN.
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

# Request the next available URN from a series/prefix.

#         Keyword arguments:
#         series_code -- a string containing the series code / prefix

#         NB: This will only work if:
#         - the ID service supports assignment of serial numbers for the specified series, and
#         - if the user has access to this series.

#         The returned URN is not stored in the ID service.
sub get_next_urn {
    my ($self, $series_code) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'getNextURN',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('seriesCode')->value($series_code))
	    );

	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

# Used to log in to the ID-service.

#         Keyword arguments:
#         username -- a username string
#         password -- a password string

#         If no username and/or password is supplied to the method, the
#         client tries to find the missing information from the YAML
#         config file.
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

        # Used to log out of the ID-service.
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

# Register a new URN and attach it to a target pointed to by the URL.

#         Keyword arguments:
#         urn -- the URN to register
#         url -- the URL pointing to the target of the URN
        
#         The URN is stored in the ID service.
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

# Replace the location of an existing target identified with the specified URN.

#         Keyword arguments:
#         urn -- The URN whose target to replace
#         old_url -- The old URL to be replaced
#         new_url -- The new URL to replace the old URL with 
sub replace_url {
    my ($self, $urn, $old_url, $new_url) = @_;

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

# Create a new URN under the specified series/prefix and reserve it for future use.
#         Keyword arguments:
#         series_code -- the series code / prefix under which to reserve a new URN
#         NB: This will only work if:
#         - the ID service supports assignment of serial numbers for the specified series, and
#         - if the user has access to this series.
# The created URN is stored in the ID service, but is not attached to any locations.
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

# Reserve a URN for future use, without assigning any targets.
#         Keyword arguments:
#         urn -- the URN to reserve
#         The URN is stored in the ID service without any associated targets.
#         This is only allowed for URNs belonging to a series without serial numbers.
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

# Set a default URL for a URN.
#         Keyword arguments:
#         urn -- the URN to set a default URL for
#         url -- the default URL to set for the URN
#         The specified URL must be one that is already registered for the URN.
sub set_default_url {
    my ($self, $urn, $url) = @_;

    if (defined $self->{sso_token}) {
	my $som = $self->{client}->call(
	    'setDefaultURL',
	    SOAP::Data->value(SOAP::Data->name('SSOToken')->value($self->{sso_token})),	    
	    SOAP::Data->value(SOAP::Data->name('URN')->value($urn)),
	    SOAP::Data->value(SOAP::Data->name('URL')->value($url))
	    );
	die $som->faultstring if ($som->fault);
	return $som->result;
    } else {
    	die "No SSO token acquired, you must log in first.";
    }
}

# Retrieve all series available for the current session. 
#         The retrieved objecs contain all known information about the series.
#         This call is currently unimplemented on the server side.
sub get_all_urn_series {
    my ($self) = @_;
    
}

# Returns the current API version.
#         This call is currently unimplemented on the server side.
sub get_version {
    my ($self) = @_;
}

1;
