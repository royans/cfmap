#!/usr/bin/perl
use Getopt::Std;
%options=();
getopts("u:c:p:k:t:h",\%options);



sub getExec(){
	my ($e)=@_;
        my $o="unknown";
        open(D,"$e|")||die "error executing $e ";
        $o=<D>;$o=~s/\n//g;
        close(D);
        return $o;
}

sub getHostName(){
	return &getExec("/bin/hostname");
}

sub getKernelVersion(){
	return &getExec("/bin/uname --kernel-release");
}



#============================================================================
# initialize
#============================================================================
$command=$options{c} if defined $options{c};
$cfmapurl=$options{u} if defined $options{u};
$hash{key}=$options{k} if defined $options{k};
$hash{type}=$options{t} if defined $options{t};
$hash{host}=&getHostName();
$hash{port}="0";
$hash{zonename}="unset";

#============================================================================
# process input
#============================================================================

if (defined $options{p}) {
        $parameters=$options{p};
        @parameters=split(/,/,$parameters);
        foreach my $param (@parameters){
                my @s=split(/=/,$param);
                my $found=0;
                if (($s[0] eq "z") || ( $s[0] eq "zone" )){ $hash{zonename}=$s[1];$found=1; }
                if (($s[0] eq "deployed")){ $hash{deployed_date}=$s[1];$found=1; }
                if (($s[0] eq "hostname")){ $hash{host}=$s[1];$found=1; }
                if ($found == 0){
                    $hash{$s[0]}=$s[1];
                }
        }
}

#if ( !exists $hash{key} ){
#        $hash{key}=$hash{host}."__".$hash{port}."__".$hash{appname};
#}

if ( !exists $hash{type} ){
	if (!exists $hash{appname}){
	    $hash{type}="host";
	    if (!exists $hash{version}){
		    $hash{version}=&getKernelVersion();
	    }
	    $hash{appname}="os";
	}else{
	    $hash{type}="app";
	}
}
if ( !defined $cfmapurl ){
        $cfmapurl="http://webtrace.info/cfmap";
        #$cfmapurl="http://cfmap.ingenuity.com:8083/cfmap";
}

die "help\n" if defined $options{h};
die "Unprocessed by Getopt::Std:\n" if $ARGV[0];

#============================================================================
# create url
#============================================================================

my $url=$cfmapurl."/browse/create.jsp?";
foreach $k (keys %hash){
        $hash{$k}=~s/\&//g;
        $hash{$k}=~s/\'//g;
        $hash{$k}=~s/\"//g;
        $hash{$k}=~s/\;//g;
        if (length($hash{$k})>0){
                $url="$url&$k=$hash{$k}";
        }
}

if ( $command eq "add" ){
        $hash{c}="submit";
        print "$url";
        exec("lynx -connect_timeout=5 --source '$url' > /dev/null 2> /dev/null");
}

