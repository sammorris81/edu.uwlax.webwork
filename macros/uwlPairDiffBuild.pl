
our $correct_param = " $disp_mud";
our $mcparam = RadioButtons(
  [@params],
  $correct_param,
  order => [@params],
  labels => [@possible_labels[0..(scalar(@params) - 1)]],
  separator => $tab
);

# extract summary data
our $ybard = Real($ybard_pd[$this_q]);
our $sd = Real($sd_pd[$this_q]);
our $n = Real($n_pd[$this_q]);
our $param1_desc = $params1_pd[$this_q];
our $param2_desc = $params2_pd[$this_q];
our $null_val = Real(0);

# construct the question of interest
our @question_compare_pos = (
  "greater than",
  "higher than"
);
our @question_compare_neg = (
  "less than",
  "lower than"
);

my $ineq;
if ($ybard < 0) {
  $ineq = random(1, 3, 2);
} else {
  $ineq = random(2, 3, 1);
}

our $question;
my $compare_idx = random(0, 1, 1);
if ($ineq == 1) {
  $question = "the " . $param1_desc . " is " . $question_compare_neg[$compare_idx] .
              " the " . $param2_desc;
} elsif ($ineq == 2) {
  $question = "the " . $param1_desc . " is " . $question_compare_pos[$compare_idx] .
              " the " . $param2_desc;
} else {
  $question = "the " . $param1_desc . " is different from the " . $param2_desc;
}

our @ineqs = (" =", " $disp_lt", " $disp_gt", " $disp_ne");
my $correct_ineq = $ineqs[$ineq];

our $mcineq = RadioButtons(
  [@ineqs],
  $correct_ineq,
  order => [@ineqs],
  labels => [@possible_labels[0..(scalar(@ineqs) - 1)]],
  separator => $tab
);

our $null_hyp = "$disp_null: $disp_mud $ineqs[0] $null_val";
our $alt_hyp = "$disp_alt: $disp_mud $ineqs[$ineq] $null_val";

# workaround for no partial degrees of freedom
our $df = Real($n - 1);

our $ts = Real(sprintf("%0.4f", $ybard / ($sd / sqrt($n))));
our $pval = Real(tprob($df, abs($ts)));  # set the tolerance
$pval = ($ineq == 3) ? $pval * 2 : $pval;
our $pvalans = Real(sprintf("%0.4f", $pval));

our $rejinterp = "We have statistically significant evidence that " . $question .
                 ".";
our $f2rinterp = "We do not have statistically significant evidence that " .
                 $question . ".";
our $accinterp = "We have statistically significant evidence that the " .
                 $param1_desc . " is the same as the " . $param2_desc . ".";
our $f2ainterp = "We do not have statistically significant evidence that the " .
                 $param1_desc . " is the same as the " . $param2_desc . ".";

our @interps = ($rejinterp, $accinterp, $f2rinterp, $f2ainterp);
our @order = NchooseK(4, 4);
our @interps = @interps[@order];

our @dec_options = (
  " Reject " . $disp_null,
  " Fail to reject " . $disp_null,
  " Accept " . $disp_null,
);

if ($pvalans < $alpha) {
  $correct_dec = " Reject " . $disp_null;
  $correct_interp = $rejinterp;
  $correct_err = " Type I error";
} else {
  $correct_dec = " Fail to reject " . $disp_null;
  $correct_interp = $f2rinterp;
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
  [@interps],
  $correct_interp,
  order => [@interps],
  labels => [@possible_labels[0..(scalar(@interps) - 1)]],
);

our @error_options = (" Type I error", " Type II error");
our $mcerror = RadioButtons(
  [@error_options],
  $correct_err,
  order => [@error_options],
  labels => [@possible_labels[0..(scalar(@error_options) - 1)]],
  separator => $tab
);

1;