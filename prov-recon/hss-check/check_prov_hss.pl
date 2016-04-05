#!/usr/bin/perl -w

#use strict;
use XML::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;

my $userAgent = LWP::UserAgent->new(agent => 'perl post');

my $data = '';
my $data1;
my $response;
my $msg;
my $library ;
my $term_line= "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
my $filename = "results.xml";
my $filename2 = "simple.out";
my $fh;
my $fh2;
my $sub_value;
my $check_number;

my $check_imsi = 'msisdn';
#check for MSISDN - msisdn
#check for IMSI - imsi
readXML();
#getResult();
#formatResult();
#writeToFile();

sub readXML{
 print "----------------------------------------------------Request SPML Start----------------------------------------------------\n";
 print "detail output to $filename\n";
 print "status output to $filename2\n";
 
$data = '';
open($fh, '>', $filename) or die "Could not open file '$filename' $!";
open($fh2, '>', $filename2) or die "Could not open file '$filename2' $!";
open (MYFILE, 'data.xml');
my $count=0;
 while (<MYFILE>) {
 	chomp;
	$count+=1;
	$sub_value = "$_\n";
	$sub_value =~ s/^\s+|\s+$//g;
    my $data_first = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:siemens:names:prov:gw:SPML:2:0">
						<soapenv:Header/>
						<soapenv:Body>
							<spml:searchRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
							xmlns:subscriber="urn:siemens:names:prov:gw:SUBSCRIBER:1:0" 
							xmlns:spml="urn:siemens:names:prov:gw:SPML:2:0">
							<version>SUBSCRIBER_v10</version>
							<base>
							<objectclass>Subscriber</objectclass>
							<alias name="';
	my $data_sec = '" value="';
	my $data_last = '</base>
							<returnAttribute>hss</returnAttribute>
							</spml:searchRequest>
							</soapenv:Body>
							</soapenv:Envelope>'; 
	my $data_mid = '"/>';
	#print $fh2 "$sub_value \n";
	$check_number = $sub_value;
	$sub_value = $sub_value.$data_mid;
    $data = $data_first.$check_imsi.$data_sec.$sub_value.$data_last;
	
	getResult();
	formatResult();
	writeToFile();
	print "check done - $count\n";
 }
 close (MYFILE); 
 close $fh;
 print "search for imsi/msisdn - $count \n";
 print "----------------------------------------------------Request SPML End----------------------------------------------------\n";
 
 }
 
sub getResult{
#testbed url
 #$response = $userAgent->request(POST 'http://172.30.50.134:8081/ProvisioningGateway/services/SPMLSubscriber10Service',

#eir url
 #$response = $userAgent->request(POST 'http://172.30.50.134:8081/ProvisioningGateway/services/SPMLEirNsr30Service',
 
# live url
 $response = $userAgent->request(POST 'http://172.17.120.102:8081/ProvisioningGateway/services/SPMLSubscriber10Service',
Content_Type => 'text/xml',
SOAPAction     => 'urn:siemens:names:prov:gw:SPML:2:0/searchRequest',
Encoding => 'gzip,deflate',
Content => $data);
#print $response->error_as_HTML unless $response->is_success;
}

#print $response->decoded_content;
#print $response->as_string;

sub formatResult{
	$msg = $response->decoded_content;
	my $msg2 = $msg;
	##print $msg
	#my $xs = new XML::Simple();
	#my $ref = $xs->XMLin($msg);
	#my $xml = $xs->XMLout($ref,RootName => undef);
	
#	use XML::Simple qw(:strict);
    #print Dumper $msg,"\n";
	my $sb = 'soapenv:Body';
	my $sp = 'spml:searchResponse';
	$xml = new XML::Simple;
	$data = $xml->XMLin($msg);
#	$library  = XMLin($msg2,
#   ForceArray => 1,
#    KeyAttr    => {},
#  );

#  foreach my $book (@{$library->{$sb}}) {
#	my $val= Dumper $book->{$sp} ;
#	print $val,"\n" ;
#	my $ch_val = '\$VAR1';
#    
#	if ($book->{$sp}->[0]->{objects}->[0]->{hss}->[0]->{privateUserId}->[0]->{msisdn} == 6596166103) {
#	my $msisdn_str = Dumper $book->{$sp}->[0]->{objects}->[0]->{hss}->[0]->{privateUserId}->[0]->{msisdn};
#	my $msisdn = $msisdn_str =~ s/$ch_val/MSISDN/r; 
#	print $fh2 $msisdn,"\n";
#	}
#	
#	my $imsi_str = Dumper $book->{$sp}->[0]->{objects}->[0]->{hss}->[0]->{privateUserId}->[0]->{provisionedImsi}->[0]->{provisionedImsi};
#	my $imsi = $imsi_str =~ s/$ch_val/IMSI/r;
#	#print $fh2 $imsi;
#	#print Dumper $book->{$sp}->[0]->{objects}->[0]->{hss}->[0];
#	print $fh2 "--------------------------------------------\n";
#  }
	
	my $msisdn =0;
	my $imsi =0;
	$msisdn = $data->{$sb}->{$sp}->{objects}->{hss}->{privateUserId}->{msisdn};
	$imsi = $data->{$sb}->{$sp}->{objects}->{hss}->{privateUserId}->{provisionedImsi}->{provisionedImsi};
	#print Dumper $data->{$sb}->{$sp};
	
	if (defined $msisdn && defined $imsi){
		if($check_imsi eq 'msisdn'){
		
			if( $msisdn eq $check_number){
				print $fh2 "MSISDN Match, List-$check_number, Found-$msisdn, imsi-$imsi\n";
			}else{
				print $fh2 "MSISDN Mis-Match, List-$check_number, Found-$msisdn, imsi-$imsi\n";
			}
		}	
		if($check_imsi eq 'imsi'){
			if( $imsi eq $check_number){
				print $fh2 "IMSI Match, List-$check_number, Found-$imsi, MSISDN-$msisdn\n";
			}else{
				print $fh2 "IMSI Mis-Match, List-$check_number, Found-$imsi, MSISDN-$msisdn\n";
			}
		}
	}else{
			print $fh2 "Error - $check_number\n";
	}
}

sub writeToFile{

print $fh $msg ,"\n";
print $fh $term_line,"\n";

}