#!/usr/bin/perl
#Week 2 INFO 3050.060 Perl Assignment
#Zachary Wozich
#The progrm is a web scraper type of Perl program.
#It downloads all text based weather
#alerts for the east coast and only gives the "hazardous weather outlook" for
#the weather station in Gray Maine since I live in Southern Maine and I only
#care about winter weather alerts.
#This program then prints the output to a text file.
#The program is called by typing perl Ice_Scraper.pl

use strict;
use warnings;
use URI;
use LWP::Protocol::https;
use LWP;
use HTML::TreeBuilder 5 -weak;
use Cwd qw(cwd);

# Using the URI package, prepare the URL for download
my $url = URI->new('https://www.weather.gov/wwamap/wwatxtget.php?cwa=gyx&wwa=all');

# Using the LWP package, it allows for web interfacing with Perl 

my $ua = LWP::UserAgent->new;

#Get URL and wait for response or Die

my $resp = $ua->get($url);

die $resp->status_line unless $resp->is_success;

#Build tree using the HTML Treebuilder package

my $tree = HTML::TreeBuilder->new_from_content($resp->decoded_content);

#Print the headline from the National Weather service using HTML Tree Builder

print $_->as_text () . "\n" for $tree->find ('title');

#This loop took a lot of research and does most of the heavy lifting for
#the ice scraper tool. It essentially uses the "look_down" function from
#html builder to find the HTML tag "pre" and filtering through the
#text as a scalar on the headlines pertaining to Hazardous Weather in
#the Gray Maine district 


  foreach my $pre (
    $tree->look_down(
      '_tag', 'pre',
      sub {
        
          $_[0]->as_text =~ m{National Weather Service Gray ME} and
          $_[0]->as_text =~ m{Hazardous Weather Outlook} 
         # $_[0]->as_text =~ m{Cumberland} 
      }
    )
  ) {
   print  $pre->as_text,"\n"; 
   #Grab CWD from the Cwd package
   my $dir = cwd;
   my $filename = $dir."/Ice_Scraper_Output.txt";
   open(my $file, '>>', $filename) or die "Could not open file";
   print $file $pre->as_text,"\n";
   close $file;
   print "print to file done\n".$filename;
  }  




