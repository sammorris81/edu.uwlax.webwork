# usefulstatUWL.pl
# Rename this file (with .pl extension) and place it in your course macros directory,

# define any custom subroutines you want and then use them in
# problems by including the file in loadMacros() calls.


sub _uwlUsefulStats_init {};

package usefulstatUWL;

@ISA = qw(Exporter);
@EXPORT_OK = qw(sum sumsquare mean med q1 q3 ss sd var cor rnorm rt standardize sortarray sw);

sub sortarray { #num_sort gives recursion errors for proportion bootstrap distributions
	my @data = @_;
	my $swaps; my $n = scalar(@data);

	do {
		$swaps = 0;
		for my $i (0..($n-2)){
			if( $data[$i] > $data[$i + 1] ){
				@data[$i, ($i+1)] = @data[($i+1), $i];
				$swaps ++;
			}
		}

	} until ($swaps == 0);

	return @data;
}

# sum a vector of numbers
sub sum{
	my $xsum = 0;
	foreach( @_ ){
		$xsum += $_;
	}

	return($xsum);
}

# sum the square of a vector of numbers
sub sumsquare{
	my $x2sum = 0;
	foreach( @_ ){
		$x2sum += ($_)**2;
	}

	return($x2sum);
}

# return average of a vector of numbers
sub mean{
	my $xsum = sum(@_);
	my $n = scalar(@_);
	my $xmean = $xsum / $n;

	return($xmean);
}

# return the median of a vector of nunmbers
sub med{
	my $n = scalar(@_);
	my @x = sortarray(@_);
	my $idx; my $med;
	if( $n % 2 == 0){
		$idx = $n / 2 - 1;
		$med = ($x[$idx] + $x[($idx + 1)])/2;
	} else {
		$idx = ($n + 1)/2 - 1;
		$med = $x[$idx];
	}

	return($med);
}

# return a specific sample quantile
sub q1 {
	my $n = scalar(@_);
	my @x = sortarray(@_);
	my $idx; my $q1;
	if( $n % 4 == 0){
		$idx = $n / 4 - 1;
		$q1 = ($x[$idx] + $x[($idx + 1)])/2;
	} elsif (($n + 1) % 4 == 0) {
		$idx = ($n + 1) / 4 - 1;
		$q1 = $x[$idx];
	} elsif (($n + 2) % 4 == 0){
		$idx = ($n + 2) / 4 - 1;
		$q1 = $x[$idx];
	} elsif (($n + 3) % 4 == 0){
		$idx = ($n - 1) / 4 - 1;
		$q1 = ($x[$idx] + $x[($idx + 1)])/2;
	}

	return($q1);
}

sub q3 {
	my $n = scalar(@_);
	my @x = sortarray(@_);
	my $idx; my $q3;
	if( $n % 4 == 0){
		$idx = $n - $n / 4;
		$q3 = ($x[$idx] + $x[($idx - 1)])/2;
	} elsif (($n + 1) % 4 == 0) {
		$idx = $n - ($n + 1) / 4;
		$q3 = $x[$idx];
	} elsif (($n + 2) % 4 == 0){
		$idx = $n - ($n + 2) / 4;
		$q3 = $x[$idx];
	} elsif (($n + 3) % 4 == 0){
		$idx = $n - ($n - 1) / 4;
		$q3 = ($x[$idx] + $x[($idx - 1)])/2;
	}

	return($q3);
}

# return sum(x - xbar)^2
sub ss{
	my $xsum = sum(@_);
	my $x2sum = sumsquare(@_);
	my $n = scalar(@_);

	my $ss = $x2sum - $xsum**2 / $n;

	return($ss);
}

# return standard deviation of a vector
sub sd{
	my $ssx = ss(@_);
	my $n = scalar(@_);
	my $sd = sqrt($ssx / ($n - 1));

	return($sd);
}

sub var{
	my $ssx = ss(@_);
	my $n = scalar(@_);
	my $var = $ssx / ($n - 1);

	return($var);
}

sub cor {  # [@x], [@y]
	my($x_ref, $y_ref) = @_;
	my @x = @{$x_ref};
	my $xbar = mean(@x);
	my $sx = sd(@x);
	my @y = @{$y_ref};
	my $ybar = mean(@y);
	my $sy = sd(@y);

	my $n = scalar(@x);
	my @zxy; my $value;

	for( my $i=0; $i < $n; $i++ ){
		$value = ($x[$i] - $xbar) * ($y[$i] - $ybar) / ($sx * $sy);
		push(@zxy, $value);
	}

	my $cor = sum(@zxy)/($n - 1);
	return($cor);
}

sub rnorm { #single value
	my $ex = shift;
	my $sd = shift;
	my @rnorm;
	my $p = main::random(0.0001,0.9999,0.0001);
	my $z = main::udistr($p);
	my $gen = $ex + $z * $sd;

	return($gen);
}

sub rt { #single value
	my $df = shift;
	my $p = main::random(0.0001, 0.9999, 0.0001);
	my $t = main::tdistr($df, $p);

	return($t);
}

sub standardize { # @x,
	my @x = @_;

	my $xbar = mean( @x );
	my $sx = sd( @x );

	my @std_res;
	foreach( @x ){
		push(@std_res, ($_ - $xbar)/$sx);
	}

	return @std_res;
}

sub sw { # $s1, $n1, $s2, $n2
	my $s1 = shift;	my $n1 = shift;
	my $s2 = shift; my $n2 = shift;

	my $lognum = 2 * log($s1**2 / $n1 + $s2**2 / $n2);
	my $logden = log(1 / ($n1 - 1) * ($s1**2 / $n1)**2 + 1 / ($n2 - 1) * ($s2**2 / $n2)**2);

	my $df = exp($lognum - $logden);

	return $df;
}

1; #required at end of file - a perl thing