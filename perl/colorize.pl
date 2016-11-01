use strict;
use warnings;
#use HexChat qw(:all);

# script registration
my $name = "colorize";
my $version = "0.1";
HexChat::register($name, $version, "colorize nicks");
HexChat::printf("Loading \002%s\017 version %s", &rainbow($name), $version);

# channel hooks
my @cevents = (
	"Channel Message", "Channel Action", "Channel Msg Hilight", "Channel Action Hilight",
	"Your Message", "Your Action"
);
for my $event (@cevents) { 
	HexChat::hook_print($event, \&colorize, { data => $event }); 
}
# server hooks
my @sevents = ("PRIVMSG");
for my $event (@sevents) {
	HexChat::hook_server($event, \&privmsg);
}
# command hooks
HexChat::hook_command("colorz", \&colorz, { help_text => "Usage: /colorz to show a list of available colors."});

# variables
my $exit;
my $color;
my @rcolors = ( 19, 20, 22, 24, 25, 26, 27, 28, 29 );

# text codes
# 002:bold
# 003:color
# 010:hidden
# 037:underline
# 017:original
# 026:reverse color
# 007:beep
# 035:italics

# commands
sub colorz {
	for my $color (@rcolors) { 
		HexChat::printf("\003%d%s", $color, $color); 
	}
	return HexChat::EAT_ALL;
}
# server events
sub privmsg {
	my @msg = @{$_[1]};
	#for (my $i = 3; $i < $#raw; $i++) {
	#	$msg = $msg.join(" ", $raw[$i]);
	#}
	#HexChat::printf("\0030%s", $msg[1]);
	return HexChat::EAT_NONE;
}
# channel events
sub text_color_of {
	my $sum = 0;
	for my $byte (split //, $_[0]) { 
		$sum += ord($byte); 
	}
	$sum %= $#rcolors / 2;
	return $rcolors[$sum];
}
sub colorize {
	$exit = 0;
	my @msg = @{$_[0]};
	my $nick = HexChat::strip_code($msg[0]);
	my $num = &text_color_of($nick);
	my $custom = $msg[2] 
		? sprintf("\0030%s\003%d%s", $msg[2], $num, $nick)
		: sprintf("\003%d%s", $num, $nick);
	#HexChat::printf("\003%d%d", $num, $num);
	HexChat::emit_print($_[1], $custom, $msg[1]) unless $exit;
	return HexChat::EAT_ALL;
}
#misc
sub rainbow {
	my $text = $_[0];
	$text =~ s/(.)/"\cC" . (int(rand(14))+2) . "$1"/eg;
	return $text;
}
__END__
