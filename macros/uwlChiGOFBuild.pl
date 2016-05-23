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
our $f2ainterp = "We do not have statistically significant evidence that our sample " .
                 "matches the " . $param_desc . ".";

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