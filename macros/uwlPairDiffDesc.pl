our @ybar1_pd; our @ybar2_pd; our @ybard_pd;
our @s1_pd; our @s2_pd; our @sd_pd;
our @n_pd;
our @text_pd;
our @params_pd; our @params1_pd; our @params2_pd;
my $n;
my $ybar;
my $s;

# find the t that we will be using
my $offset = non_zero_random(-4.99, 4.99, 0.02);

# entry 0
$ybar1 = random(20, 20.2, 0.005);
$s1 = random(4.05, 4.15, 0.005);
$s2 = random(2.90, 3.05, 0.005);
$sd = random(1.80, 1.90, 0.005);
$n = 8;
$ybard = Real(sprintf("%0.3f", abs($offset) * $sd / sqrt($n)));
$ybar2 = Real(sprintf("%0.3f", $ybar1 - $ybard));

my $table;
$table = BCENTER();
$table .= main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
$table .= main::AlignedRow(["Name", "Mean", "Std. Dev", "n"], align=>"CENTER", valign=>"MIDDLE", separation=>0);
$table .= main::AlignedRow(["Highway", "$ybar1", "$s1", "$n"], align=>"CENTER", valign=>"MIDDLE", separation=>0);
$table .= main::AlignedRow(["City", "$ybar2", "$s2", "$n"], align=>"CENTER", valign=>"MIDDLE", separation=>0);
$table .= main::AlignedRow(["Difference", "$ybard", "$sd", "$n"], align=>"CENTER", valign=>"MIDDLE", separation=>0);
$table .= main::EndTable();
$table .= ECENTER();

push(@ybar1_pd, $ybar1);
push(@ybar2_pd, $ybar2);
push(@ybard_pd, $ybard);
push(@s1_pd, $s1);
push(@s2_pd, $s2);
push(@sd_pd, $sd);
push(@n_pd, $n);
push(@text_pd,
  "Researchers are interested in learning about the difference in highway vs " .
  "city mileage for car models. They took a random sample of $n models of " .
  "cars. The summaries of the mileage measurements are given in the following " .
  "table:" .
  $table
);

push(@params_pd,
  "difference in average highway mileage and city mileage"
);

push(@params1_pd,
  "average highway mileage"
);

push(@params2_pd,
  "average city mileage"
);

our $num_pd = scalar(@n_pd);

1;