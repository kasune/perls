#!/usr/bin/perl -w

use strict;
use XML::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;

my $userAgent = LWP::UserAgent->new(agent => 'perl post');

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
open (MYFILE, 'inumdata.xml');
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
$response = $userAgent->request(POST 'http://172.17.124.50:8080/Inum6/Inum6',

Content_Type => 'text/xml',
SOAPAction     => 'urn:siemens:names:prov:gw:SPML:2:0/searchRequest',
Encoding => 'gzip,deflate',
Content => $data);
print $response->error_as_HTML unless $response->is_success;
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
my $path = "inumout.xml";
open my $fh, ">", $path or die "$0: open $path: $!";
print $fh XMLout($ref2,RootName => undef);
close $fh or warn "$0: close $path: $!";
}