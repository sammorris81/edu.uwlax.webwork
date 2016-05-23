
our $correct_param = " $disp_p";
our $mcparam = RadioButtons(
  [@params],
  $correct_param,
  order => [@params],
  labels => [@possible_labels[0..(scalar(@params) - 1)]],
  separator => $tab
);

# extract summary data
our $x = Real($x_sp[$this_q]);
our $n = Real($n_sp[$this_q]);
our $null_val = Real(sprintf("%.4f", $null_sp[$this_q]));
our $param_desc = $params_sp[$this_q];
our $param_desc_special = $params_special_sp[$this_q];

# sample statistic
our $phat = $x / $n;

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
if ($phat < $null_val) {
  $ineq = random(1, 3, 2);
} else {
  $ineq = random(2, 3, 1);
}

our $question_compare; our $question;
my $compare_idx;
if ($null_val == 0.5) {
  $compare_idx = random(0, 3, 1);
  if ($ineq == 1) {
    if ($compare_idx < 3) {
      $question_compare = $question_compare_neg[$compare_idx] . " half of ";
    } else {
      $question_compare = "minority of ";
    }
    $question = $question_compare . $param_desc_special;
  } elsif ($ineq == 2) {
    if ($compare_idx < 3) {
      $question_compare = $question_compare_pos[$compare_idx] . " half of ";
    } else {
      $question_compare = "majority of ";
    }
    $question = $question_compare . $param_desc_special;
  } else {
    $question = "the " . $param_desc . " is different from half.";
  }
} elsif ($null_val == 0.25) {
  $compare_idx = random(0, 2, 1);
  if ($ineq == 1) {
    $question_compare = $question_compare_neg[$compare_idx] . " one-quarter of ";
    $question = $question_compare . $param_desc_special;
  } elsif ($ineq == 2) {
    $question_compare = $question_compare_pos[$compare_idx] . " one-quarter of ";
    $question = $question_compare . $param_desc_special;
  } else {
    $question = "the " . $param_desc . " is different from one-quarter";
  }
} elsif ($null_val == 0.75) {
  $compare_idx = random(0, 2, 1);
  if ($ineq == 1) {
    $question_compare = $question_compare_neg[$compare_idx] . " three-quarters of ";
    $question = $question_compare . $param_desc_special;
  } elsif ($ineq == 2) {
    $question_compare = $question_compare_pos[$compare_idx] . " three-quarters of ";
    $question = $question_compare . $param_desc_special;
  } else {
    $question = "the " . $param_desc . " is different from three-quarters";
  }
} elsif ($null_val >= 0.33 && $null_val <= 0.34) {
  $null_val = 0.3333;
  $compare_idx = random(0, 2, 1);
  if ($ineq == 1) {
    $question_compare = $question_compare_neg[$compare_idx] . " one-third of ";
    $question = $question_compare . $param_desc_special;
  } elsif ($ineq == 2) {
    $question_compare = $question_compare_pos[$compare_idx] . " one-third of ";
    $question = $question_compare . $param_desc_special;
  } else {
    $question = "the " . $param_desc . " is different from one-third";
  }
} elsif ($null_val >= 0.66 && $null_val <= 0.67 ) {
  $null_val = 0.6667;
  $compare_idx = random(0, 2, 1);
  if ($ineq == 1) {
    $question_compare = $question_compare_neg[$compare_idx] . " two-thirds of ";
    $question = $question_compare . $param_desc_special;
  } elsif ($ineq == 2) {
    $question_compare = $question_compare_pos[$compare_idx] . " two-thirds of ";
    $question = $question_compare . $param_desc_special;
  } else {
    $question = "the " . $param_desc . " is different from two-thirds";
  }
} else {
  $compare_idx = random(0, 2, 1);
  if ($ineq == 1) {
    $question = "the " . $param_desc . " is " . $question_compare_neg[$compare_idx] .
                " " . $null_val;
  } elsif ($ineq == 2) {
    $question = "the " . $param_desc . " is " . $question_compare_pos[$compare_idx] .
                " " . $null_val;
  } else {
    $question = "the " . $param_desc . " is different from " . $null_val;
  }
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

our $null_hyp = "$disp_null: p $ineqs[0] $null_val";
our $alt_hyp = "$disp_alt: p $ineqs[$ineq] $null_val";
our $ts = Real(sprintf("%0.4f", ($phat - $null_val) / sqrt(($null_val * (1 - $null_val)) / $n)));
our $pval = Real(uprob(abs($ts)));
$pval = ($ineq == 3) ? $pval * 2 : $pval;
our $pvalans = Real(sprintf("%0.4f", $pval));

our $rejinterp = "We have statistically significant evidence that " . $question .
                 ".";
our $f2rinterp = "We do not have statistically significant evidence that " .
                 $question . ".";
our $accinterp = "We have statistically significant evidence that the " .
                 $param_desc . " is exactly " . $null_val . ".";
our $f2ainterp = "We do not have statistically sigificant evidence that the " .
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