#!/usr/bin/perl -w

#use strict;
use XML::Simple;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;
use DateTime;

my $userAgent = LWP::UserAgent->new(agent => 'perl post');

my $data = '';
my $data1;
my $response;
my $msg;
my $library ;
my $term_line= "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
my $filename = "results.xml";
my $filename2 = "data-check.txt";
my $fh;
my $fh2;

readXML();
#getResult();
#formatResult();
#writeToFile();

sub readXML{
 print "----------------------------------------------------Request SPML Start----------------------------------------------------\n";
$sttime = DateTime->now();
print "Start time : $sttime\n";
$epocStart = time();
#sleep(5);
$count = 0;
$data = '';
open($fh, '>', $filename) or die "Could not open file '$filename' $!";
open($fh2, '>', $filename2) or die "Could not open file '$filename2' $!";

open (MYFILE, 'data.xml');
 while (<MYFILE>) {
 	chomp;
	my $sub_value = "$_\n";
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
							<alias name="msisdn" value="';
	my $data_last = '</base>
							<returnAttribute>hlr</returnAttribute>
							</spml:searchRequest>
							</soapenv:Body>
							</soapenv:Envelope>'; 
	my $data_mid = '"/>';
	#print "$sub_value \n";
	my $numberInput = $sub_value;
	$sub_value = $sub_value.$data_mid;
    $data = $data_first.$sub_value.$data_last;
	
	getResult();
	formatResult($numberInput);
	writeToFile();
	$count+=1;
	
 }
 close (MYFILE); 
 close $fh;
 #sleep 60;
 $entime = DateTime->now;
 $epocEnd = time();
 $elapse = $epocEnd - $epocStart;
 
 print "End time   : ".$entime."\n";
 #print "Elapsed time : ".$elapse->in_units('seconds')."s\n";
 print "Elapsed time : ".$elapse. "s\n";
 print "Search Count : ".$count."\n";
 if ($elapse == 0) {
	$elapse =1;
 }
 print "Search per second : ".$count/$elapse."\n";

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
	my $input_number= $_[0];
	##print $msg
	#my $xs = new XML::Simple();
	#my $ref = $xs->XMLin($msg);
	#my $xml = $xs->XMLout($ref,RootName => undef);
	
#	use XML::Simple qw(:strict);
#    #print Dumper $msg,"\n";
#	my $sb = 'soapenv:Body';
#	my $sp = 'spml:searchResponse';
#	$library  = XMLin($msg2,
#    ForceArray => 1,
#    KeyAttr    => {},
#  );
  
	my $sb = 'soapenv:Body';
	my $sp = 'spml:searchResponse';
	$xml = new XML::Simple;
	$data = $xml->XMLin($msg);

#  foreach my $book (@{$library->{$sb}}) {
#	my $val= Dumper $book->{$sp} ;
#	#print $val,"\n" ;
#	
#	my $ch_val = '\$VAR1';
#	my $msisdn_str = Dumper $book->{$sp}->[0]->{objects}->[0]->{hlr}->[0]->{ts11}->[0]->{msisdn};
#	my $msisdn = $msisdn_str =~ s/$ch_val/TS11/r; 
#    print $msisdn,"\n";
#	
#	my $ts21_str = Dumper $book->{$sp}->[0]->{objects}->[0]->{hlr}->[0]->{ts11}->[0]->{msisdn};
#	my $ts21 = $ts21_str =~ s/$ch_val/TS21/r;
#	print $ts21,"\n";
#	
#	my $ts22_str = Dumper $book->{$sp}->[0]->{objects}->[0]->{hlr}->[0]->{ts11}->[0]->{msisdn};
#	my $ts22 = $ts22_str =~ s/$ch_val/TS22/r;
#	print $ts22,"\n";
	
#	print Dumper $book->{$sp}->[0]->{objects}->[0]->{hlr}->[0];
	
	my $msisdn =0;
	my $imsi =0;
	$msisdn = $data->{$sb}->{$sp}->{objects}->{hlr}->{ts11}->{msisdn};
	$imsi = $data->{$sb}->{$sp}->{objects}->{auc}->{imsi};
	#print "ts11 - $msisdn , ts21 - $imsi\n";
	my $vlr_number=5;
	my $ms_number=5;
	my $apn_name ='NO';
	my $maxBandWidthUp = '00';

	## direct mapping of attribute
	#$vlr_number = $data->{$sb}->{$sp}->{objects}->{hlr}->{msgWaitData}->{mobileStationNotReachableFlag};
	#$maxBandWidthUp = $data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext}->{maxBandwidthUp};
	#$apn_name = $data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext}->{apn};
	#$ms_number = $data->{$sb}->{$sp}->{objects}->{hlr}->{vlrMobData}->{mscNumber};
	
	##traverse through array
	if(ref($data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext}) eq 'ARRAY') {
		for (@{ $data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext} }) {
			$apn_name = $_->{apn};
			$maxBandWidthUp = $_->{maxBandwidthUp};
			#print $_->{maxBandwidthUp}, ' ', $_->{apn},'',$msisdn, $imsi "\n";
		}
	}else{
		$maxBandWidthUp = $data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext}->{maxBandwidthUp};
		$apn_name = $data->{$sb}->{$sp}->{objects}->{hlr}->{epsPdnContext}->{apn};
	}
	
	
	if (defined $msisdn){
		if (defined $maxBandWidthUp){
			print $fh2 "$msisdn,$imsi,$apn_name,$maxBandWidthUp\n";
		}else{
			print $fh2 "search parameter not available\n";
		}		
	}else{
		print $fh2 "$input_number not available in One-NDS\n"
	}
	
	## print whole sub
	#print Dumper($data);
}

sub writeToFile{

print $fh $msg ,"\n";
print $fh $term_line,"\n";

}