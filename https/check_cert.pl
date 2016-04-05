#!/usr/bin/perl

checkCert('nds1pgwt01/ProvisioningGateway/services/SPMLSubscriber10Service','');

## Verify the SSL certificate of the given path
sub checkCert {
    my ($host, $port) = @_;
	print "$host \n";
	#$host = 'nds1pgwt01/ProvisioningGateway/services/SPMLSubscriber10Service';
	#$port = 443;

    ## Get the host domain and port from the path
    $port = $port ? $port : '443';
    $ENV{HTTPS_CA_FILE} = 'cacert.pem';
    my $cert_error_message = '';

    ## Create the connection to the server.
    require Net::SSL;
    my $sock;
    eval {
        $sock = Net::SSL->new(PeerAddr => $host, PeerPort => $port, Timeout => 5);
    };

    ## If we are unable to connect, give an error. This also may
    ## mean the certificate authority is invalid.
    ## Check #1: Valid CA
    if($@) {
        $cert_error_message = "SSL certificate invalid or is not from a trusted source: $@";
        $cert_error_message =~ s/ at .+$//s;
    }
    else {
        ## Check #2: Domain matches CN
        ## Check that the domain name matched the certificate common name
        my $cert = $sock->get_peer_certificate;
        my $subject = $cert->subject_name;
        $subject =~ s/\*//g; # Remove wildcard astricks
        my ($CN) = $subject =~ /CN=(.*)\W/;
        if(!$CN) {
            $cert_error_message = "Unable to read SSL certificate";
        }
        elsif($host !~ /$CN/i) {
            $cert_error_message = "SSL Certificate Common Name mismatch. Retrieved common name '$CN' does not match hostname '$h
ost'";
        }

        ## Check #3: Check for expired
        my $startsOn = getSSLTime($cert->not_before);
        my $expiresOn = getSSLTime($cert->not_after);
        my $currTime = time;

        ## Check that the certificate start time is not after the current time
        if($currTime < $startsOn) {
            $cert_error_message = "SSL Certificate is not valid before ". $cert->not_before;
        }
        if($currTime > $expiresOn) {
            $cert_error_message = "SSL Certificate has expired, not valid after ". $cert->not_after;
        }
    }
	
    ## If we found an error, set the global error message string and signal there was an error
    if($cert_error_message) { print "$cert_error_message at $host:$port\n"; }
    else { print "SUCCESS: SSL Cerificate verified\n"; }

    delete $ENV{HTTPS_CA_FILE};
    return 1;
}

## Given a string in the format '$year-$month-$day $hour:$minute:$second', return
## the epoch time in GMT time.
## Used by checkCert.
sub getSSLTime {
    my ($string) = @_;

    require Time::Local;
    my ($year, $month, $day, $hour, $minute,$second,$GMT) = $string =~ /^(.+)-(.+)-(.+) (.+):(.+):(\S+)( GMT)?$/;
    $year -= 1900;
    $month--;
    return Time::Local::timegm($second,$minute,$hour,$day,$month,$year);
}