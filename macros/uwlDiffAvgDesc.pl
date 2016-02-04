our @ybar1_da; our @ybar2_da;
our @s1_da; our @s2_da;
our @n1_da; our @n2_da;
our @text_da;
our @params1_da; our @params2_da;
my $n1; my $n2;
my $ybar1; my $ybar2;
my $s1; my $s2;

# find the t that we will be using
my $offset = non_zero_random(-4.99, 4.99, 0.02);

# entry 0
$ybar1 = random(6, 6.1, 0.01);
$s1 = random(1.570, 1.588, 0.003);
$s2 = random(1.100, 1.118, 0.003);
$n1 = Real(10);
$n2 = Real(10);
$ybar2 = $ybar1 + $offset * sqrt($s1**2 / $n1 + $s2**2 / $n2);
$ybar2 = Real(sprintf("%0.2f", $ybar2));

push(@ybar1_da, $ybar1);
push(@ybar2_da, $ybar2);
push(@s1_da, $s1);
push(@s2_da, $s2);
push(@n1_da, $n1);
push(@n2_da, $n2);
push(@text_da,
  "The Wolf River in Tennessee flows past an abandoned site once used by the " .
  "pesticide industry for dumping wastes, including chlordane, aldrin, and " .
  "dieldrin. These highly toxic organic compounds can cause various cancers and " .
  "birth defects. The standard method to test whether these poisons are present " .
  "in a river is to take samples at mid-depth in the water. Recently, scientists " .
  "have begun to believe that the concentration of these molecules may be " .
  "different at different depths of the river. Researchers took $n1 samples " .
  "at mid-depth and found an average aldrin concentration of $ybar1 with a " .
  "standard deviation of $s1. They also took $n2 samples from the bottom of the " .
  "river and found an average aldrin concentration of $ybar2 with a standard " .
  "deviation of $s2. offset is $offset."
);

push(@params1_da,
  "average aldrin concentration at mid-depth"
);

push(@params2_da,
  "average aldrin concentration at the bottom of the river"
);

our $num_da = scalar(@n_da);

1;