Scaffold::Begin();
our $refreshCachedImages=0;
our $submission = $inputs_ref->{previewAnswers};

# loadMacros('uwlHypTestBank.pl');

##### Begin building the problem

### First select the procedure and question

# randomly select a type of hypothesis test
our $type = random(0, (scalar(@include) - 1), 1);

# randomly select the question to be asked from the bank
our $this_q;
our $text;

# the include array starts the numbering at 1
if ($include[$type] == 1) {
  $qtype = "SingleProp";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_sp - 1), 1);
  $text = $text_sp[$this_q];
} elsif ($include[$type] == 2) {
  $qtype = "SingleAvg";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_sa - 1), 1);
  $text = $text_sa[$this_q];
} elsif ($include[$type] == 3) {
  $qtype = "DiffProp";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_dp - 1), 1);
  $text = $text_dp[$this_q];
} elsif ($include[$type] == 4) {
  $qtype = "DiffAvg";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_da - 1), 1);
  $text = $text_da[$this_q];
} elsif ($include[$type] == 5) {
  $qtype = "PairDiff";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_pd - 1), 1);
  $text = $text_pd[$this_q];
} elsif ($include[$type] == 6) {
  $qtype = "ChiGOF";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_gof - 1), 1);
  $text = $text_gof[$this_q];
} elsif ($include[$type] == 7) {
  $qtype = "ChiInd";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_ind - 1), 1);
  $text = $text_ind[$this_q];
} elsif ($include[$type] == 8) {
  $qtype = "ANOVA";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_anova - 1), 1);
  $text = $text_anova[$this_q];
} elsif ($include[$type] == 9) {
  $qtype = "SLR";
  loadMacros("uwl" . $qtype . "Desc.pl");
  $this_q = random(0, ($num_slr - 1), 1);
  $text = $text_slr[$this_q];
}

$build_macro = "uwl" . $qtype . "Build.pl";
$scaffold_macro = "uwl" . $qtype . "Scaf.pl";

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

our @procs; our $proc;
foreach $inc (@include) {
  # label should be consecutive
  $proc = $possible_labels[$label_idx] . " " . $possible_procs[$inc - 1];

  if ($inc == $include[$type]) {
    our $correct_proc = $proc;
  }
  push(@procs, $proc);
  $label_idx++;
}

# our $correct_proc = $procs[$type];

Context("Numeric");
our $this_part = 1;

# TEXT(EV3(<<'END_TEXT'));
# The build macro is $build_macro
# END_TEXT

loadMacros($build_macro);

TEXT(EV3(<<'END_TEXT'));
$PAR $PAR
$BBOLD Instructions: $EBOLD There are multiple parts to this hypothesis test
question. You must get each part correct before you will be allowed to progress
to the next part of the question. To submit your answers for a part of the
question, click on the "Submit Answers" button. $PAR
$PAR
$BBOLD Study Description: $EBOLD $text $PAR
$PAR
$BBOLD Research Question: $EBOLD We are interested in knowing if $question.
END_TEXT

Section::Begin("Part $this_part: Pick the Procedure",
  can_open => "always",
  is_open => "correct_or_first_incorrect"
);
if (scalar(@include) == 1) {
TEXT(EV3(<<'END_TEXT'));
$PAR
This is an example of a $possible_procs[$include[$type] - 1] question.
END_TEXT
} else {
our $mcpick = RadioButtons(
  [@procs],
  $correct_proc,
  order => [@procs],
  labels => [@possible_labels[0..(scalar(@procs) - 1)]],
  separator => $tab
);

TEXT(EV3(<<'END_TEXT'));
$PAR
What is the most appropriate type of procedure for the study description given
above? $PAR
\\{ $mcpick->buttons() \\}
END_TEXT
ANS($mcpick->cmp());
}
Section::End();

loadMacros($scaffold_macro);

Scaffold::End();

1;  #required at end of file - a perl thing
