#!/usr/bin/perl -w
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 1;
$ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS} = 'Net::SSL';
use strict;
use warnings;
use XML::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;
use IO::Socket::SSL;

use HTTP::Request;  

use Net::SSL ();
use WWW::Mechanize;
BEGIN {
    $ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS} = "Net::SSL";
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 1;
}
my $pfxfile = 'C:\Users\emkasun\Desktop\cert\KEYSTORE.p12';
my $pfxpass = 'provgw';
$ENV{HTTPS_PKCS12_FILE} = $pfxfile;
$ENV{HTTPS_PKCS12_PASSWORD} = $pfxpass;


#my $userAgent = LWP::UserAgent->new(agent => 'perl post');
 
## test code 
 #my $URL = 'https://nds1pgwt01/ProvisioningGateway/services/SPMLSubscriber10Service';  
 #  
 #my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });  
 #my $header = HTTP::Request->new(GET => $URL);  
 #my $request = HTTP::Request->new('GET', $URL, $header);  
 #my $res = $ua->request($request);  
 #  
 #if ($res->is_success){  
 #    print "URL:$URL\nHeaders:\n";  
 #    print $res->headers_as_string;  
 #}elsif ($res->is_error){  
 #    print "Error:$URL\n";  
 #    print $res->error_as_HTML;  
 #}  
## test code end here

# create object
#my $xml = new XML::Simple;

# read XML file
# my $data = $xml->XMLin("data.xml");

# hard coded spml
my $datas = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
   xmlns:urn="urn:siemens:names:prov:gw:SPML:2:0">
<soapenv:Header/>
   <soapenv:Body>
<urn:searchRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  	     xmlns:subscriber="urn:siemens:names:prov:gw:HLR_EPS_SUBSCRIBER:5:0" 
  	     xmlns:spml="urn:siemens:names:prov:gw:SPML:2:0">
         <version>HLR_EPS_SUBSCRIBER_v50</version>
         <base>
            <objectclass>Subscriber</objectclass>
            <!--  <alias name="imsi" value="525031111111111" /> -->
                 <alias name="msisdn" value="6596960142" />
         </base>
         <returnAttribute>hlr</returnAttribute>
      </urn:searchRequest>
   </soapenv:Body>
</soapenv:Envelope>';
my $data;
my $response;
my $msg;

readXML();
getResult();
formatResult();
writeToFile();

sub readXML{
 print "----------------------------------------------------Request SPML Start----------------------------------------------------\n";
$data = '';
open (MYFILE, 'data.xml');
 while (<MYFILE>) {
 	chomp;
	print "$_\n";
 	$data = $data."$_";
 }
 close (MYFILE); 
 print "----------------------------------------------------Request SPML End----------------------------------------------------\n";
 
 }
 
sub getResult{
#testbed url
# $response = $userAgent->request(POST 'http://172.30.50.134:8081/ProvisioningGateway/services/SPMLSubscriber10Service',
#
##eir url
# #$response = $userAgent->request(POST 'http://172.30.50.134:8081/ProvisioningGateway/services/SPMLEirNsr30Service',
# 
## live url
# #$response = $userAgent->request(POST 'http://172.17.220.102:8081/ProvisioningGateway/services/SPMLSubscriber10Service',
#Content_Type => 'text/xml',
#SOAPAction     => 'urn:siemens:names:prov:gw:SPML:2:0/searchRequest',
#Encoding => 'gzip,deflate',
#Content => $data);
#print $response->error_as_HTML unless $response->is_success;

 #my $URL = 'https://172.30.50.134/ProvisioningGateway/services/SPMLSubscriber10Service';  
 # verify_hostname => 0, SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE, -- verify nothing on SSL, possible for middle man attacks
my $URL = 'https://nds1pgwt01/ProvisioningGateway/services/SPMLSubscriber10Service';  
#my $URL = 'https://172.17.120.102/ProvisioningGateway/services/SPMLSubscriber10Service';
#my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0, SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE});  
#my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0, SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE});
#my $header = HTTP::Request->new(POST => $URL);  
#my $request = HTTP::Request->new(POST $URL, Content_Type => 'text/xml',SOAPAction     => 'urn:siemens:names:prov:gw:SPML:2:0/searchRequest',Encoding => 'gzip,deflate',Content => $data);  
 my $ua = WWW::Mechanize->new();
 $ua->cookie_jar({});

 $response = $ua->request(POST $URL, 
 Content_Type => 'text/xml',
 SOAPAction     => 'urn:siemens:names:prov:gw:SPML:2:0/searchRequest',
 Encoding => 'gzip,deflate',
 Content => $data);  
  
 #my $cl = IO::Socket::SSL->new('www.google.com:443');
 #print $cl "GET / HTTP/1.0\r\n\r\n";
 #print <$cl>; 
  
if ($response->is_success){  
    print "URL:$URL\nHeaders:\n";  
    print $response->headers_as_string;  
}elsif ($response->is_error){  
    print "Error:$URL\n";  
    print $response->error_as_HTML; 
	#exit 1;
   }
}

#print $response->decoded_content;
#print $response->as_string;

sub formatResult{
	$msg = $response->decoded_content;
	my $xs = new XML::Simple();
	my $ref = $xs->XMLin($msg);
	my $xml = $xs->XMLout($ref,RootName => undef);
	print $xml;
}

sub writeToFile{
my $ref2 = XMLin($msg);
my $path = "out.xml";
open my $fh, ">", $path or die "$0: open $path: $!";
print $fh XMLout($ref2,RootName => undef);
close $fh or warn "$0: close $path: $!";
}