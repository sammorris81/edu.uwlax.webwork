our $cat = $cat_gof[$this_q];
our @obs = @{$cat->{freqs}};
our @nulls = @{$null_gof[$this_q]};
our @labels = @{$cat->{labels}};
our $n = $cat->{n};
our @exp;
our $ts = Real(0);
our $param_desc = $params_gof[$this_q];
our $question = "the sample is significantly different from " .
                $param_desc;

my $idx = 0;
foreach $null (@nulls) {
  push (@exp, $null * $n);
  $ts += ($obs[$idx] - $exp[$idx])**2 / $exp[$idx];
  $idx++;
}

# for hypothesis test block
our $randomgroup = random(0, (scalar(@exp) - 1), 1);
our $this_null = Real($nulls[$randomgroup]);
our $this_exp = Real($exp[$randomgroup]);
our $this_label = lc($labels[$randomgroup]);

# test statistic and p-value
our $df = Real(scalar(@exp) - 1);
our $pval = Real(chisqrprob($df, $ts));
our $pvalans = Real(sprintf("%0.4f", $pval));

# conclusion and interpretation
our $rejinterp = "We have statistically significant evidence that " . $question .
                 ".";
our $f2rinterp = "We do not have statistically significant evidence that " .
                 $question . ".";
our $accinterp = "We have statistically significant evidence that our sample " .
                 "matches the " . $param_desc . ".";

our @interps = ($rejinterp, $f2rinterp, $accinterp);

our @dec_options = (
  " i. Reject " . $disp_null,
  " ii. Fail to reject " . $disp_null,
  " iii. Accept " . $disp_null,
);

our @interps = ($rejinterp, $accinterp, $f2rinterp);

my $order_a = random(0, 2, 1); my $order_b; my $order_c;
if ($order_a == 0) {
  $order_b = random(1, 2, 1);
  if ($order_b == 1) {
    $order_c = 2;
  } else {
    $order_c = 1;
  }
} elsif ($order_a == 1) {
  $order_b = random(0, 2, 2);
  if ($order_b == 0) {
    $order_c = 2;
  } else {
    $order_c = 0;
  }
} else {
  $order_b = random(0, 1, 1);
  if ($order_b == 0) {
    $order_c = 1;
  } else {
    $order_c = 2;
  }
}

my @order = ($order_a, $order_b, $order_c);
my @order = NchooseK(3, 3);
our @interp_options;
my $interp_idx = 0; our $this_interp; our $this_order;
foreach $interp (@interps) {
  $this_order = $order[$interp_idx];
  $this_interp = " $possible_labels[$interp_idx] $interps[$this_order]";
  if ($pvalans < $alpha && $order[$interp_idx] == 0) {
    $correct_interp = $this_interp;
  } elsif ($pvalans >= $alpha && $order[$interp_idx] == 2) {
    $correct_interp = $this_interp;
  }
  push(@interp_options, $this_interp);
  $interp_idx++;
}

if ($pvalans < $alpha) {
  $correct_dec = " i. Reject " . $disp_null;
  $correct_err = " i. Type I error";
} else {
  $correct_dec = " ii. Fail to reject " . $disp_null;
  $correct_err = " ii. Type II error";
}

our $mcdec = RadioButtons(
    [@dec_options],
    $correct_dec,
    order => [@dec_options],
    labels => [@possible_labels[0..(scalar(@dec_options) - 1)]],
    separator => $tab
);

our $mcinterp = RadioButtons(
  [@interp_options],
  $correct_interp,
  order => [@interp_options],
  labels => [@possible_labels[0..(scalar(@interp_options) - 1)]],
);

our @error_options = (" i. Type I error", " ii. Type II error");
our $mcerror = RadioButtons(
  [@error_options],
  $correct_err,
  order => [@error_options],
  labels => [@possible_labels[0..(scalar(@error_options) - 1)]],
  separator => $tab
);

# Hypothesis test block:
# Identify the null amount for one of the groups
# Find the expected count for the group

# Test statistic and p-value
# Find the test statistic and the p-value and give df

# conclusion and interpretation


# TEXT(EV3(<<'END_TEXT'));
# The null is $nulls[0]. n is $n. Observed is $obs[0], Expected is $exp[0],
# Test stat is $ts.

# $accinterp
# END_TEXT

1;