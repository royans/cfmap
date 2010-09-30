#!/usr/bin/perl
use Getopt::Std;
use POSIX;
use LWP::Simple qw($ua get);
$cfqversion=1;

$ua->timeout(4);


$defaulturl="http://webtrace.info/cfmap";
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

sub getCfmapUrl(){ return &getExec("if [ -f ../deployment.spec ]; then cat ../deployment.spec | grep cfmap_monitor_host | cut -d'=' -f2 ; fi");}
$defaulturl_ =&getCfmapUrl();if (length($defaulturl_)>0){$defaulturl="http://$defaulturl_:8083/cfmap";}

sub getHostName(){ return &getExec("/bin/hostname"); }
sub getKernelVersion(){ return &getExec("/bin/uname --kernel-release"); }
sub getTotalMem(){ return &getExec('cat /proc/meminfo | grep ^MemTotal | awk \'{print $2 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getFreeMem(){ return &getExec('cat /proc/meminfo | grep ^MemFree | awk \'{print $2 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getTotalSwap(){ return &getExec('cat /proc/meminfo | grep ^SwapTotal | awk \'{print $2 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getFreeSwap(){ return &getExec('cat /proc/meminfo | grep ^SwapFree | awk \'{print $2 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getLoadAvg1m(){ return &getExec('cat /proc/loadavg | awk \'{print $1 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getLoadAvg5m(){ return &getExec('cat /proc/loadavg | awk \'{print $2 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getLoadAvg15m(){ return &getExec('cat /proc/loadavg | awk \'{print $3 }\' | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getLoadAvgEntities(){ return &getExec('cat /proc/loadavg | awk \'{print $4 }\' | cut -d\'/\' -f2 | perl -e \'$a=<STDIN>;$a=~s/\n//g;$a=$a/1024;print ($a);\''); }
sub getStartDate(){ return &getExec('A=`cat /proc/uptime | cut -d\' \' -f1 | cut -d\'.\' -f1`;B=`date +\'%s\'`;C=$((B-A));echo $C');}

$hash{cfqversion}=$cfqversion;
sub getSystemInfo(){
    $hash{version}=&getKernelVersion();
    $hash{appname}="os";
    $hash{type}="host";
    $hash{stats_host_totalmem}=floor(&getTotalMem());
    $hash{stats_host_freemem}=floor(&getFreeMem());
    $hash{stats_host_totalswap}=floor(&getTotalSwap());
    $hash{stats_host_freeswap}=floor(&getFreeSwap());
    $hash{stats_host_loadavg1m}=floor(&getLoadAvg1m());
    $hash{stats_host_loadavg5m}=floor(&getLoadAvg5m());
    $hash{stats_host_loadavg15m}=floor(&getLoadAvg15m());
    $hash{stats_host_loadavgentities}=floor(&getLoadAvgEntities());
    $hash{deployed_date}=&getStartDate();
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

if ( !exists $hash{type} ){
	if (!exists $hash{appname}){
	    &getSystemInfo();
	    $hash{type}="host";
	    if (!exists $hash{version}){
		    $hash{version}=&getKernelVersion();
	    }
	}else{
	    $hash{type}="app";
	}
}
if ( !defined $cfmapurl ){
        $cfmapurl=$defaulturl;
        #$cfmapurl="http://cfmap.ingenuity.com:8083/cfmap";
}

if ( !defined $command ){
	$command='add';
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
        #print "$url";
	$result=get($url);
	#print $result;
        #exec("lynx -connect_timeout=5 --source '$url' > /dev/null 2> /dev/null");
}

