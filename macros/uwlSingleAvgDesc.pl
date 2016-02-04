our @ybar_sa;
our @s_sa;
our @n_sa;
our @null_sa;
our @text_sa;
our @params_sa;
my $n;
my $ybar;
my $s;
my $null;

# find the t that we will be using
my $offset = non_zero_random(-4.99, 4.99, 0.02);

# entry 0
$s = random(0.035, 0.055, 0.005);
$n = random(145, 155, 1);
$null = Real(0.10);
$ybar = Real(sprintf("%0.3f", $null + $offset * $s / sqrt($n)));
push(@ybar_sa, $ybar);
push(@s_sa, $s);
push(@n_sa, $n);
push(@null_sa, $null);
push(@text_sa,
  "In 2004, a team of researchers published a study of contaminants in farmed ".
  "salmon. Fish from many sources were analyzed for 14 organic contaminants. The ".
  "study expressed concerns about the level of contaminants found. One of those ".
  "was the insecticide mirex, which has been shown to be carcinogenic and is ".
  "suspected to be toxic to the liver, kidneys, and endocrine system. One farm ".
  "in particular produced salmon with very high levels of mirex. After the outlier ".
  "was removed, researchers found that the for the remaining $n salmon farms, ".
  "the average mirex concentration (in parts per million) was $ybar with a ".
  "standard deviation of $s."
);
push(@params_sa,
  "average mirex concentration (in parts per million)"
);

# entry 1
$s = random(0.670, 0.690, 0.005);
$n = random(50, 60, 1);
$null = Real(98.6);
$ybar = Real(sprintf("%0.3f", $null + $offset * $s / sqrt($n)));
push(@ybar_sa, $ybar);
push(@s_sa, $s);
push(@n_sa, $n);
push(@null_sa, $null);
push(@text_sa,
  "A medical researcher measured the body temperatures (F) of a sample of $n ".
  "randomly selected adults. They found that the average temperature was $ybar, ".
  "with a standard deviation of $s."
);
push(@params_sa,
  "average body temperature"
);

our $num_sa = scalar(@n_sa);

1;