#!/usr/bin/perl
require LWP::UserAgent;
use IO::File;
use Text::Iconv;
use LWP::Simple;
use POSIX;

$conv = Text::Iconv->new('windows-1251','utf-8');

$destination_dir = "../cache/avatarsVK/";
$start_id = 99;
$end_id = 10000;
$max_id = 900_000_000;

$ua = LWP::UserAgent->new;
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");

for($user_id = $start_id; $user_id <= $end_id; $user_id++)
{
	$url = "http://vkontakte.ru/id${user_id}";
	$response = $ua->get($url);

    print "Loading user ${user_id}\n";
	if ($response->is_success) 
	{
		print "OK\n";    	
		$html = $conv->convert($response->content);
		$html =~ m/id="leftColumn".*?img.*?src=(.*?) \/>/igs;
		my $imgUrl = $1;
		my $res = LWP::UserAgent->new->request(new HTTP::Request GET => $imgUrl);

		print "Loading avatar ${imgUrl}\n";
		if ($res->is_success) 
		{	
			$size = floor(log($user_id)/log(10))+1;
			$max_size = floor(log($max_id)/log(10))+1;
			$img =  0 x ($max_size - $size) . $user_id . ".jpg";
			open (ABC, ">${destination_dir}${img}") or die "\n\n\nERROR: $!\n\n\n";
			binmode(ABC);
			print ABC $res->content; close ABC or die "\n\n\nERROR: $!\n\n\n";

		} else {
		  print $res->status_line;
		}
	} else {
	    print "error: ". $response->status_line . "\n";
 	}
}
