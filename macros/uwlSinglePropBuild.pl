
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
my $correct_ineq = $hyp_ineqs[$ineq];

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

our @interps = ($rejinterp, $f2rinterp, $accinterp);

our @dec_options = (
  " Reject " . $disp_null,
  " Fail to reject " . $disp_null,
  " Accept " . $disp_null,
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
  $this_interp = " $interps[$this_order]";
  if ($pvalans < $alpha && $order[$interp_idx] == 0) {
    $correct_interp = $this_interp;
  } elsif ($pvalans >= $alpha && $order[$interp_idx] == 2) {
    $correct_interp = $this_interp;
  }
  push(@interp_options, $this_interp);
  $interp_idx++;
# TEXT(EV3(<<'END_TEXT'));
# $this_interp $PAR
# $this_order $PAR
# END_TEXT
}

if ($pvalans < $alpha) {
  $correct_dec = " Reject " . $disp_null;
  $correct_err = " Type I error";
} else {
  $correct_dec = " Fail to reject " . $disp_null;
  $correct_err = " Type II error";
}

# TEXT(EV3(<<'END_TEXT'));
# $BBOLD pvalue: $EBOLD $pvalans
# $BBOLD alpha: $EBOLD $alpha $PAR
# $BBOLD Correct Decision: $EBOLD $correct_dec $PAR
# $BBOLD Correct Interpretation $EBOLD $correct_interp $PAR
# $BBOLD Correct Error $EBOLD $correct_err $PAR
# END_TEXT

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

1;