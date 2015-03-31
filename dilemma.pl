use strict;
use warnings;
use DaZeus;

my $socket = shift;
if (!$socket) {
	warn "Usage: $0 socket\n";
	exit 1;
}

my $dazeus = DaZeus->connect($socket);

$dazeus->subscribe_command('dilemma' => \&geef_dilemma);
$dazeus->subscribe_command('nieuwdilemma' => \&schrijf_dilemma);

while($dazeus->handleEvents()) {}

sub geef_dilemma {
	my (undef, $network, $sender, $channel) = @_;

	my $filename = 'dilemmas.txt';
	open(my $fh, '<:encoding(UTF-8)', $filename)
	  or die "Could not open file '$filename' $!";
	my @line;
	while(<$fh>) {
		chomp;
		push (@line, $_);
	}
	my $part1 = getnum(@line);
	my $part2 = getnum(@line);

	until ($part1 ne $part2) {
		$part2 = getnum(@line);
	}

	$dazeus->message($network, $channel, "$part1" . " OF " . "$part2");
}

sub schrijf_dilemma {
	my (undef, $network, $sender, $channel, $command, $dilemma) = @_;
	my $filename = 'dilemmas.txt';
	open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
	print $fh "$dilemma\n";
	close $fh;
	$dazeus->message($network, $channel, "Nieuw lemma: $dilemma\n");
	
}

sub getnum {
	my $range = @_;
	my $random_number = int(rand($range));
	return $_[$random_number];
}