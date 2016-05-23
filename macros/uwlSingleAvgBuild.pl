our $correct_param = " $disp_mu";
our $mcparam = RadioButtons(
  [@params],
  $correct_param,
  order => [@params],
  labels => [@possible_labels[0..(@params) - 1]],
  separator => $tab
);

# extract summary data
our $ybar = Real($ybar_sa[$this_q]);
our $s = Real($s_sa[$this_q]);
our $n = Real($n_sa[$this_q]);
our $df = Real($n - 1);
our $null_val = Real($null_sa[$this_q]);
our $param_desc = $params_sa[$this_q];

# construct the question of interest
our @question_compare_pos = (
  "at least",
  "greater than",
  "more than"
);
our @question_compare_neg = (
  "at most",
  "less than",
  "lower than"
);

my $ineq;
if ($ybar < $null_val) {
  $ineq = random(1, 3, 2);
} else {
  $ineq = random(2, 3, 1);
}

our $question;
my $compare_idx = random(0, 2, 1);
if ($ineq == 1) {
  $question = "the " . $param_desc . " is " . $question_compare_neg[$compare_idx] .
              " " . $null_val;
} elsif ($ineq == 2) {
  $question = "the " . $param_desc . " is " . $question_compare_pos[$compare_idx] .
              " " . $null_val;
} else {
  $question = "the " . $param_desc . " is different from " . $null_val;
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

our $null_hyp = "$disp_null: $disp_mu $ineqs[0] $null_val";
our $alt_hyp = "$disp_alt: $disp_mu $ineqs[$ineq] $null_val";

our $ts = Real(sprintf("%0.4f", ($ybar - $null_val) / ($s / sqrt($n))));
our $pval = Real(tprob($df, abs($ts)));
$pval = ($ineq == 3) ? $pval * 2 : $pval;
our $pvalans = Real(sprintf("%0.4f", $pval));

our $rejinterp = "We have statistically significant evidence that " . $question .
                 ".";
our $f2rinterp = "We do not have statistically significant evidence that " .
                 $question . ".";
our $accinterp = "We have statistically significant evidence that the " .
                 $param_desc . " is exactly " . $null_val . ".";
our $f2ainterp = "We do not have statistically significant evidence that the " .
                 $param_desc . " is exactly " . $null_val . ".";

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