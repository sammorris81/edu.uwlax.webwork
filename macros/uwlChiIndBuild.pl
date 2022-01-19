our $cat = $cat_ind[$this_q];
our @obs = @{$cat->{freqs}};
our @labels = @{$cat->{labels}};
our @rowlabs = @{$rowlabs_ind[$this_q]};
our $rowvar = $rowvar_ind[$this_q];
our @collabs = @{$collabs_ind[$this_q]};
our $colvar = $colvar_ind[$this_q];
our $n = $cat->{n};
our $param_desc = $params_ind[$this_q];
our $question = "there is an association between " . $rowvar . " and " . $colvar;

# need row totals and col totals for expected counts
our @rowtotals; our @coltotals;
foreach $rowidx (1..scalar(@rowlabs)) {
  push(@rowtotals,
    CategoricalUWL::margintotal(
      data => $cat, index => 1, level => $rowidx,
    )
  );
}
foreach $colidx (1..scalar(@collabs)) {
  push(@coltotals,
    CategoricalUWL::margintotal(
      data => $cat, index => 2, level => $colidx,
    )
  );
}

our @exp; my $cellidx = 0;
our $ts = Real(0);
foreach $rowidx (0..(scalar(@rowlabs) - 1)) {
  foreach $colidx (0..(scalar(@collabs) - 1)) {
    push(@exp, $rowtotals[$rowidx] * $coltotals[$colidx] / $n);
    $ts += ($obs[$cellidx] - $exp[$cellidx])**2 / $exp[$cellidx];
    $cellidx++;
  }
}

# for hypothesis test block
our $randomrow = random(0, (scalar(@rowtotals) - 1), 1);
our $randomcol = random(0, (scalar(@coltotals) - 1), 1);
our $this_cell = $randomrow * scalar(@coltotals) + $randomcol;
our $this_exp = Real($exp[$this_cell]);
our $this_rowlab = lc($rowlabs[$randomrow]);
our $this_collab = lc($collabs[$randomcol]);

our $nullhyp = "There is not an association between " . $rowvar . " and " .
               $colvar;
our $althyp  = "There is an association between " . $rowvar . " and " . $colvar;
our @hyps;

my $hyporder = random(0, 1, 1);
if ($hyporder == 0) {
  @hyps = ($nullhyp, $althyp);
  $correctnull = $hyps[0];
  $correctalt = $hyps[1];
} else {
  @hyps = ($althyp, $nullhyp);
  $correctnull = $hyps[1];
  $correctalt = $hyps[0];
}

our $mcnull = RadioButtons(
  [@hyps],
  $correctnull,
  order => [@hyps],
  labels => [@possible_labels[0..(scalar(@hyps) - 1)]],
);
our $mcalt = RadioButtons(
  [@hyps],
  $correctalt,
  order => [@hyps],
  labels => [@possible_labels[0..(scalar(@hyps) - 1)]],
);

# test statistic and p-value
our $df = Real((scalar(@rowlabs) - 1) * (scalar(@collabs) - 1));
our $pval = Real(chisqrprob($df, $ts));
our $pvalans = Real(sprintf("%0.4f", $pval));

# conclusion and interpretation
our $rejinterp = "We have statistically significant evidence that " . $question .
                 ".";
our $f2rinterp = "We do not have statistically significant evidence that " .
                 $question . ".";
our $accinterp = "We have statistically significant evidence that there is no " .
                 "association between " . $rowvar . " and " . $colvar;

our @interps = ($rejinterp, $f2rinterp, $accinterp);

our @dec_options = (
  " Reject " . $disp_null,
  " Fail to reject " . $disp_null,
  " Accept " . $disp_null,
);

our @interps = ($rejinterp, $accinterp, $f2rinterp);

# my $order_a = random(0, 2, 1); my $order_b; my $order_c;
# if ($order_a == 0) {
#   $order_b = random(1, 2, 1);
#   if ($order_b == 1) {
#     $order_c = 2;
#   } else {
#     $order_c = 1;
#   }
# } elsif ($order_a == 1) {
#   $order_b = random(0, 2, 2);
#   if ($order_b == 0) {
#     $order_c = 2;
#   } else {
#     $order_c = 0;
#   }
# } else {
#   $order_b = random(0, 1, 1);
#   if ($order_b == 0) {
#     $order_c = 1;
#   } else {
#     $order_c = 2;
#   }
# }

# my @order = ($order_a, $order_b, $order_c);
my @order = NchooseK(3, 3);
our @interp_options;
my $interp_idx = 0; our $this_interp; our $this_order;
foreach $interp (@interps) {
  $this_order = $order[$interp_idx];
  $this_interp = " $interps[$this_order]";
  if ($pvalans < $alpha && $order[$interp_idx] == 0) {
    $correct_interp = $this_interp;
  } elsif ($pvalans >= $alpha && $order[$interp_idx] == 2) {
    $correct_interp = $this_interp;
  }
  push(@interp_options, $this_interp);
  $interp_idx++;
}

if ($pvalans < $alpha) {
  $correct_dec = " Reject " . $disp_null;
  $correct_err = " Type I error";
} else {
  $correct_dec = " Fail to reject " . $disp_null;
  $correct_err = " Type II error";
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

our @error_options = (" Type I error", " Type II error");
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
# The null is $nulls[0]. n is $n. $BR
# Observed is $obs[0], Expected is $exp[0] $BR
# Observed is $obs[1], Expected is $exp[1] $BR
# Observed is $obs[2], Expected is $exp[2] $BR
# Observed is $obs[3], Expected is $exp[3] $BR
# Observed is $obs[4], Expected is $exp[4] $BR
# Observed is $obs[5], Expected is $exp[5] $BR
# Test stat is $ts.

# $accinterp
# END_TEXT

1;