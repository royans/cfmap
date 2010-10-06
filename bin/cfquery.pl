#!/usr/bin/perl
use Getopt::Std;
use POSIX;
use LWP::Simple qw($ua get);
$cfqversion=1.2.1;


# Set crypt to some random key. This would be the key to your private data.
$crypt="public";

$defaulturl="http://webtrace.info/cfmap";
%options=();
getopts("u:c:p:k:t:h",\%options);

sub init(){
    $ua->timeout(4);
    if ( !defined $cfmapurl ){
        $cfmapurl=$defaulturl;
        #$cfmapurl="http://cfmap.ingenuity.com:8083/cfmap";
    }
}
    

sub getExec(){
	my ($e)=@_;
        my $o="unknown";
        open(D,"$e|")||die "error executing $e ";
        $o=<D>;$o=~s/\n//g;
        close(D);
        return $o;
}

sub getCfmapUrl(){ return &getExec("if [ -f ../deployment.spec ]; then cat ../deployment.spec | grep cfmap_monitor_host | cut -d'=' -f2 ; fi");}
$defaulturl_ =&getCfmapUrl();if (length($defaulturl_)>0){$defaulturl="http://$defaulturl_:8083/cfmap";if ($defaulturl=~/ingenuity.com/) {$crypt="";} }
init();

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
sub getStartDate(){$_d=&getExec('A=`cat /proc/uptime | cut -d\' \' -f1 | cut -d\'.\' -f1`;B=`date +\'%s\'`;C=$((B-A));echo $C'); $_dd=floor($_d/10)*10;  return $_dd;}
sub getESTCount(){ return &getExec('netstat -na | grep -i established | wc -l');}
sub getPSCount(){ return &getExec('ps -aef | wc -l');}

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
    $hash{stats_host_estconn}=floor(&getESTCount());
    $hash{stats_host_pscount}=floor(&getPSCount());
    $hash{deployed_date}=&getStartDate();
    $hash{version}=&getKernelVersion();
}

sub prepareUrl(){
    my $url="";
    foreach $k (keys %hash){
        $hash{$k}=~s/\&//g;
        $hash{$k}=~s/\'//g;
        $hash{$k}=~s/\"//g;
        $hash{$k}=~s/\;//g;
        if (length($hash{$k})>0){
                $url="$url&$k=$hash{$k}";
        }
    }
    return $url;
}


sub createAddUrl(){
    my $url=$cfmapurl."/browse/create.jsp?";

    if ((!exists $hash{type})&&(!exists $hash{appname})){
	&getSystemInfo();
	$hash{type}="host";
    }

    $hash{crypt}=$crypt unless defined $hash{$crypt};
    $hash{cfqversion}=$cfqversion;
    $hash{host}=&getHostName() unless defined $hash{host};
    $hash{port}="0" unless defined $hash{port};
    $hash{z}="unset" unless defined $hash{z};
    $hash{appname}="unknown" unless defined $hash{appname};
    $hash{type}="app" unless defined $hash{type};
    $hash{c}="submit" unless defined $hash{c};

    my $final_url=$url.&prepareUrl();
    return $final_url;
}

sub createViewUrl(){
    my $url=$cfmapurl."/browse/view.jsp?";
    $hash{z}="dev" unless defined $hash{z};
    my $final_url=$url.&prepareUrl();
    return $final_url;
}



#============================================================================
# initialize
#============================================================================
$command=$options{c} if defined $options{c};
$cfmapurl=$options{u} if defined $options{u};
$hash{key}=$options{k} if defined $options{k};
$hash{type}=$options{t} if defined $options{t};

#============================================================================
# process input
#============================================================================

if (defined $options{p}) {
        $parameters=$options{p};
        @parameters=split(/,/,$parameters);
        foreach my $param (@parameters){
                my @s=split(/=/,$param);
                my $found=0;
                if (($s[0] eq "z") || ( $s[0] eq "zone" )){ $hash{z}=$s[1];$found=1; }
                if (($s[0] eq "deployed")){ $hash{deployed_date}=$s[1];$found=1; }
                if (($s[0] eq "hostname")){ $hash{host}=$s[1];$found=1; }
                if ($found == 0){
                    $hash{$s[0]}=$s[1];
                }
        }
}

if ( !defined $command ){
     $command='add';
}

die "help\n" if defined $options{h};
die "Unprocessed by Getopt::Std:\n" if $ARGV[0];

#============================================================================
# create url
#============================================================================

if ( $command eq "add" ){
	my $url=&createAddUrl();
        #print "$url\n";
	$result=get($url); 
	#print $result; #exec("lynx -connect_timeout=5 --source '$url' > /dev/null 2> /dev/null");
}

if ( $command eq "view" ){
	$hash{f}="s";
	my $url=&createViewUrl();
        $result=get($url);
	print($result);
	#$result=get($url); #print $result; #exec("lynx -connect_timeout=5 --source '$url' > /dev/null 2> /dev/null");
}


