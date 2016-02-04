Scaffold::Begin();
our $refreshCachedImages=0;
our $submission = $inputs_ref->{previewAnswers};

if ($displayMode eq "TeX") {
  our $anssep = "\( \\ \noindent \)";
  our $extrasep = "\( \noindent \)";
  our $tab = "\( \qquad \)";
  our $sp = "\( \ \)";
  our $BBQ = '';
  our $EBQ = '';
  our $disp_alpha = "\( \alpha \)";
  our $disp_p   = "\( p \)";
  our $disp_mu  = "\( \mu \)";
  our $disp_p1  = "\( p_1 \)";
  our $disp_p2  = "\( p_2 \)";
  our $disp_mu1 = "\( \mu_1 \)";
  our $disp_mu2 = "\( \mu_2 \)";
  our $disp_mud = "\( \mu_d \)";
  our $disp_lt  = "\( < \)";
  our $disp_le  = "\( \leq \)";
  our $disp_gt  = "\( > \)";
  our $disp_ge  = "\( \geq \)";
  our $disp_neq = "\( \neq \)";
  our $disp_null = "\( H_0 \)";
  our $disp_alt  = "\( H_a \)";
} else {
  our $extrasep = $PAR;
  our $anssep = $PAR;
  our $tab = '&nbsp; &nbsp; &nbsp; &nbsp;';
  our $sp  = '&nbsp;';
  our $BBQ = '<blockquote>';
  our $EBQ = '</blockquote>';
  our $disp_alpha = '<span style = "font-family: serf;">&alpha;</span>';
  our $disp_p   = 'p';
  our $disp_mu  = '&mu;';
  our $disp_p1  = 'p<sub>1</sub>';
  our $disp_p2  = 'p<sub>2</sub>';
  our $disp_mu1 = '&mu;<sub>1</sub>';
  our $disp_mu2 = '&mu;<sub>2</sub>';
  our $disp_mud = '&mu;<sub>d</sub>';
  our $disp_lt  = '&lt;';
  our $disp_le  = '&le;';
  our $disp_gt  = '&gt;';
  our $disp_ge  = '&ge;';
  our $disp_ne  = '&ne;';
  our $disp_null = 'H<sub>0</sub>';
  our $disp_alt  = 'H<sub>a</sub>';
}

##### Begin building the problem

### First select the procedure and question

# randomly select a type of hypothesis test
our $type = random(0, scalar(@include) - 1, 1);

# randomly select the question to be asked from the bank
our $this_q;
our $text;

# the include array starts the numbering at 1
if ($include[$type] == 1) {
  $this_q = random(0, ($num_sp - 1), 1);
  $text = $text_sp[$this_q];
  $build_macro = "uwlSinglePropBuild.pl";
} elsif ($include[$type] == 2) {
  $this_q = random(0, ($num_sa - 1), 1);
  $text = $text_sa[$this_q];
  $build_macro = "uwlSingleAvgBuild.pl";
} elsif ($include[$type] == 3) {
  $this_q = random(0, ($num_dp - 1), 1);
  $text = $text_dp[$this_q];
  $build_macro = "uwlTwoPropBuild.pl";
} elsif ($include[$type] == 4) {
  $this_q = random(0, ($num_da - 1), 1);
  $text = $text_da[$this_q];
  $build_macro = "uwlTwoAvgBuild.pl";
} elsif ($include[$type] == 5) {
  $this_q = random(0, ($num_pd - 1), 1);
  $text = $text_pd[$this_q];
  $build_macro = "uwlPairDiffBuild.pl";
} elsif ($include[$type] == 6) {
  $this_q = random(0, ($num_chigof - 1), 1);
  $text = $text_chigof[$this_q];
  $build_macro = "uwlChiGOFBuild.pl";
} elsif ($include[$type] == 7) {
  $this_q = random(0, ($num_chiind - 1), 1);
  $text = $text_chiind[$this_q];
  $build_macro = "uwlChiIndBuild.pl";
} elsif ($include[$type] == 8) {
  $this_q = random(0, ($num_anova - 1), 1);
  $text = $text_anova[$this_q];
  $build_macro = "uwlANOVABuild.pl";
} elsif ($include[$type] == 9) {
  $this_q = random(0, ($num_slr - 1), 1);
  $text = $text_slr[$this_q];
  $build_macro = "uwlSLRBuild.pl";
}

our @possible_procs = (
  " Single Proportion",
  " Single Average",
  " Difference in Proportions",
  " Difference in Averages",
  " Paired Differences",
  " Chi-Square Goodness of Fit",
  " Chi-Square Test of Independence",
  " One-Way ANOVA",
  " Simple Linear Regression"
);

our @possible_labels = (
  "i.", "ii.", "iii.", "iv.", "v.", "vi.", "vii.", "viii.", "ix."
);

if ($include[$type] <= 5) {
  our @params = (
    " i. $disp_p",
    " ii. $disp_mu",
    " iii. $disp_p1 - $disp_p2",
    " iv. $disp_mu1 - $disp_mu2",
    " v. $disp_mud"
  );
}

our @alphas = (0.01, 0.05, 0.10);
our $alpha = $alphas[random(0, 2, 1)];
my $label_idx = 0;

our @procs; my $proc;
foreach $inc (@include) {
  # label should be consecutive
  $proc = $possible_labels[$label_idx] . " " . $possible_procs[$inc - 1];
  if ($inc - 1 == $type) {
    our $correct_proc = $proc;
  }
  push(@procs, $proc);
  $label_idx++;
}

# TEXT(EV3(<<'END_TEXT'));
# $correct_proc and $this_q
# $BBOLD Single Proportion: $EBOLD $text_sp[0] $PAR
# $BBOLD Single Average: $EBOLD $text_sa[0] $PAR
# $BBOLD Difference in Proportions: $EBOLD $text_dp[0] $PAR
# $BBOLD Difference in Averages: $EBOLD $text_da[0] $PAR
# $BBOLD Paired Differences: $EBOLD $text_pd[0] $PAR
# END_TEXT
# our $correct_proc = $procs[$type];

our $mcpick = RadioButtons(
  [@procs],
  $correct_proc,
  order => [@procs],
  labels => [@possible_labels[0..(scalar(@procs) - 1)]],
  separator => $tab
);

Context("Numeric");
our $this_part = 1;

TEXT(EV3(<<'END_TEXT'));
$PAR $PAR
$BBOLD Instructions: $EBOLD There are multiple parts to this hypothesis test
question. You must get each part correct before you will be allowed to progress
to the next part of the question. To submit your answers for a part of the
question, click on the "Submit Answers" button. $PAR
$PAR
$BBOLD Study Description: $EBOLD $text
END_TEXT

Section::Begin("Part $this_part: Pick the Procedure",
  can_open => "always",
  is_open => "correct_or_first_incorrect"
);
if (scalar(@include) == 1) {
TEXT(EV3(<<'END_TEXT'));
$PAR
This is an example of a $possible_procs[$type] question.
END_TEXT
} else {
TEXT(EV3(<<'END_TEXT'));
$PAR
What is the most appropriate type of procedure for the study description given
above? $PAR
\\{ $mcpick->buttons() \\}
END_TEXT
ANS($mcpick->cmp());
}
Section::End();

# loadMacros($build_macro);

Scaffold::End();

1;  #required at end of file - a perl thing