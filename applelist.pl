#!/usr/bin/perl
#
# applelist.pl
#
# By Andrew Pontious, http://helpfultiger.com
# Assistance from Dan Shiovitz and Gunther Schmidl.
#
# This script is released into the public domain 11/2003.
# Change to enclose paths in quotes on (now) line 155 made 12/13/2003.
# 

use Cwd;


$dir = getcwd;

%months_to_indexes = 
(
	"Jan" => 0, "Feb" => 1, "Mar" => 2, "Apr" => 3, "May" => 4, "Jun" => 5,
	"Jul" => 6, "Aug" => 7, "Sep" => 8, "Oct" => 9, "Nov" => 10, "Dec" => 11
);
@indexes_to_months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");


# Parameters

if($#ARGV == -1 || ($ARGV[0] eq "--help") || ($ARGV[0] eq "-h"))
{
    print  "Usage: $0 <list name 1> <list name 2> etc.\n";
    exit;
}


$basepage = "http://archives:archives\@lists.apple.com/archives/";


foreach $listname (@ARGV)
{
	# Get years
	
	$listpage = "${basepage}${listname}/";
	
	$years_output = `./getlinks.pl -d $listpage ./ ".*\/[0-9]{4}\/\$"`;
	@years_output = split /\n/, $years_output;
	
	foreach (@years_output)
	{
		if(/([0-9]{4})\/$/)
		{
			push(@years, $1);
		}
	}
	
	
	# Loop through years
	
	foreach $year (@years)
	{
		$year_plus_one = $year+1;
		
		if(-e "$dir/$listname/$year" && -e "$dir/$listname/$year_plus_one")
		{
			next;
		}
	
		$yearpage = "${listpage}${year}/";
		
		# Get months
		
		$months_output = `./getlinks.pl -d $yearpage ./ ".*\/[A-Z][a-z][a-z]\/\$"`;
		@months_output = split /\n/, $months_output;
		
		@months = ();
		
		foreach (@months_output)
		{
			if(/\/([A-Z][a-z][a-z])\/$/)
			{
				push(@months, $1);
			}
		}
		
		# Loop through months
		
		foreach $month (@months)
		{
			if(!($month eq "Dec") &&
			   -e "$dir/$listname/$year/$month" &&
			   -e "$dir/$listname/$year/$indexes_to_months[$months_to_indexes{$month} + 1]")
			{
				next;
			}

			$monthpage = "${yearpage}${month}/";
	
			# Get days
	
			$days_output = `./getlinks.pl -d $monthpage ./ ".*\/[0-9][0-9]\/\$"`;
			@days_output = split /\n/, $days_output;
			
			@days = ();
		
			foreach (@days_output)
			{
				if(/\/([0-9][0-9])\/$/)
				{
					push(@days, $1);
				}
			}
			
			# Loop through days
			
			foreach $day (@days)
			{
				$day_plus_one = sprintf "%02d", ($day+1);
				
				if(-e "$dir/$listname/$year/$month/$day" && 
				   -e "$dir/$listname/$year/$month/$day_plus_one")
				{
					next;
				}
			
				$daypage = "${monthpage}${day}/";
			
				# Get articles
				
				$articles_output = `./getlinks.pl -d $daypage ./ ".*\.txt\$"`;
				@articles_output = split /\n/, $articles_output;
				
				@articles = ();
				
				foreach $_ (@articles_output)
				{
					if(/\/([a-zA-Z0-9._]+\.txt$)/)
					{
						push(@articles, $1);
					}
				}
				
				# Loop through articles
	
				if(@articles > 0)
				{
					$dayDir = "$dir/$listname/$year/$month/$day/";
				
					if(!(-e "$dir/$listname"))
					{ mkdir "$dir/$listname"; }
					if(!(-e "$dir/$listname/$year"))
					{ mkdir "$dir/$listname/$year"; }
					if(!(-e "$dir/$listname/$year/$month"))
					{ mkdir "$dir/$listname/$year/$month"; }
					if(!(-e "$dir/$listname/$year/$month/$day"))
					{ mkdir "$dir/$listname/$year/$month/$day"; }
	
					# Changed 12/13/2003 to enclose paths in quotes.
					system "\"./getlinks.pl\" \"$daypage\" \"$dayDir\" \".*\.txt\$\"";
				}
			}
		}
	}
}