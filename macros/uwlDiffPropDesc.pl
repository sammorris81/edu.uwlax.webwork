our @x1_dp; our @x2_dp;
our @n1_dp; our @n2_dp;
our @text_dp;
our @params1_dp; our @params2_dp;
my $n1; my $n2; my $ntotal;
my $x1; my $x2;
my $p1; my $p2;
my $z; my $pbar;  # used to find x2

# find the z that we will be using
our $offset = non_zero_random(-3.99, 3.99, 0.02);

# entry 0
$n1 = random(240, 260, 1);
$n2 = random(250, 270, 1);
$ntotal = $n1 + $n2;
$p1 = random(0.54, 0.58, 0.001);
$x1 = floor($n1 * $p1);
$p2 = $p1 + sgn($offset) * 0.01;

$pbar = ($x1 + $p2 * $n2) / ($n1 + $n2);
$pbar = sqrt($pbar * (1 - $pbar) * ( 1 / $n1 + 1 / $n2));

# hack to find appropriate x2
if ($offset < 0) {
  do {
    $p2 += 0.01;
    $x2 = $p2 * $n2;
    $pbar = ($x1 + $x2) / ($n1 + $n2);
    $pbar = $pbar * (1 - $pbar);
    $z = ($p1 - $p2) / sqrt($pbar * (1 / $n1 + 1 / $n2));
  } until ($z <= $offset);
} else {
  do {
    $p2 -= 0.01;
    $x2 = $p2 * $n2;
    $pbar = ($x1 + $x2) / ($n1 + $n2);
    $z = ($p1 - $p2) / sqrt($pbar * (1 - $pbar) * (1 / $n1 + 1 / $n2));
  } until ($z >= $offset);
}
$x2 = floor($n2 * $p2);

push (@n1_dp, $n1);
push (@n2_dp, $n2);
push (@x1_dp, $x1);
push (@x2_dp, $x2);
push (@text_dp,
  "A recent survey of $ntotal randomly selected teenagers (aged 12 - 17) " .
  "found that more than half of them had online profiles. Some researchers and " .
  "privacy advocates are concerned about the possible access to personal " .
  "information about teens in public places on the Internet. There appear to be " .
  "differences between boys and girls in their online behavior. Among teens " .
  "aged 15 - 17, $x1 of the $n1 boys had posted profiles, compared to $x2 of the " .
  "$n2 girls."
);
push (@params1_dp,
  "proportion of boys who have posted profiles"
);
push (@params2_dp,
  "proportion of girls who have posted profiles"
);

our $num_dp = scalar(@n_dp);

1;