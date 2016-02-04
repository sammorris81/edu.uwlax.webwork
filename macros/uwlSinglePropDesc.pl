our @x_sp;
our @n_sp;
our @null_sp;
our @text_sp;
our @params_sp;
our @params_special_sp;  # used in the case of special nulls (0.5, 0.25, 0.33)
my $n;
my $x;
my $null;

# find the z that we will be using
my $offset = non_zero_random(-3.99, 3.99, 0.02);

# entry 0 - DeVeaux, Stats: Data and Models, Ed. 3, p. 457
$n = random(100, 110, 1);
$null = 0.50;
$x = floor(($null + $offset * sqrt($null * (1 - $null) / $n)) * $n);
push (@n_sp, $n);
push (@null_sp, $null);
push (@x_sp, $x);
push (@text_sp,
  "Dr. Drew Harvell’s lab studies corals and the diseases that affect them. ".
  "They sampled sea fans at 19 randomly selected reefs along the Yucatan peninsula ".
  "and diagnosed whether the animals were affected by the disease aspergilosis. ".
  "In specimens collected at a depth of 40 feet at the Las Redes Reef in Akumal, ".
  "Mexico, these scientists found that $x of $n sea fans sample were ".
  "infected with that disease."
);
push (@params_sp,
  "proportion of sea fans infected with aspergilosis"
);
push (@params_special_sp,
  "sea fans are infected with aspergilosis"
);

# entry 1
$n = random(330, 340, 1);
$null = 0.15;
$x = floor(($null + $offset * sqrt($null * (1 - $null) / $n)) * $n);
push (@n_sp, $n);
push (@null_sp, $null);
push (@x_sp, $x);
push (@text_sp,
  "A Pew Research study regarding cell phones asked questions about cell phone ".
  "experience. One growing concern is unsolicited advertising in the form of text ".
  "messages. Pew asked cell phone owners, \"Have you ever received unsolicited ".
  "text messages on your cell phone from advertisers?\" and $x of $n ".
  "reported that they had."
);
push (@params_sp,
  "proportion of cell phone owners who have received unsolicited text messages ".
  "on their cell phone from advertisers"
);
push (@params_special_sp,
  "cell phone owners have received unsolicited text messages on their cell ".
  "phones from advertisers"
);

# entry 2
$n = random(890, 910, 1);
$null = 0.80;
$x = floor(($null + $offset * sqrt($null * (1 - $null) / $n)) * $n);
push (@n_sp, $n);
push (@null_sp, $null);
push (@x_sp, $x);
push (@text_sp,
  "On January 30 - 31, 2007, Fox News / Opinion Dynamics polled $n registered ".
  "voters nationwide. When asked, \"Do you believe global warming exists?\" $x ".
  " said \"Yes.\""
);
push (@params_sp,
  "proportion of voters who believe global warming exists"
);
push (@params_special_sp,
  "voters believe global warming exists"
);

our $num_sp = scalar(@n_sp);

1;