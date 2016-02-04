### Build text for remaining parts of question

# state the hypotheses
$this_part++;

Section::Begin("Part $this_part: Identify the hypotheses",
  can_open => "when_previous_correct",
  is_open  => "correct_or_first_incorrect"
);

TEXT(EV3(<<'END_TEXT'));
For this study we wish to determine if $question.
\\{ BeginList("OL", type=>"a") \\}
  $ITEM What proportion should be used for $this_label in the null hypothesis?
  \\{ ans_rule(10) \\}
  $ITEM What is the expected count for $this_label?
  \\{ ans_rule(10) \\}
\\{ EndList("OL") \\}
END_TEXT
ANS($this_null->with(tolerance=>0.01, tolType=>"Absolute")->cmp());
ANS($this_exp->with(tolerance=>0.01, tolType=>"Absolute")->cmp());
Section::End();

## test statistic and p-value
$this_part++;

Section::Begin("Part $this_part: Test statistic and p-value",
  can_open => "when_previous_correct",
  is_open  => "correct_or_first_incorrect"
);

TEXT(EV3(<<'END_TEXT'));
What are the test statistic, degrees of freedom, and p-value for this hypothesis
test? Give your answers to 4 decimal places. If p-value $disp_lt 0.001, enter 0.
\\{ BeginList("OL", type=> "a") \\}
  $ITEM $disp_chisq = \\{ ans_rule(10) \\}
  $ITEM degrees of freedom = \\{ ans_rule(10) \\}
  $ITEM p-value = \\{ ans_rule(10)\\}
\\{ EndList("OL") \\}
END_TEXT
ANS($ts->with(tolerance=>0.001, tolType=>"Absolute")->cmp());
ANS($df->with(tolerance=>0, tolType=>"Absolute")->cmp());
ANS($pvalans->with(tolerance=>0.001, tolType=>"Absolute")->cmp());
Section::End();

# conclusion and interpretation
$this_part++;

Section::Begin("Part $this_part: Conclusion and interpretation",
  can_open => "when_previous_correct",
  is_open  => "correct_or_first_incorrect"
);
TEXT(EV3(<<'END_TEXT'));
For the following questions, use a significance level of $disp_alpha = $alpha. $PAR
\\{ BeginList("OL", type=> "a") \\}
  $ITEM Select the appropriate decision for this hypothesis test. $BR
  \\{ $mcdec -> buttons() \\} $PAR
  $ITEM Select the appropriate interpretation for this hypothesis test. $BR
  \\{ $mcinterp -> buttons() \\} $PAR
  $ITEM If an error had been made on this test, what kind of error would it have
  been? $BR
  \\{ $mcerror -> buttons() \\} $PAR
\\{ EndList("OL") \\}
END_TEXT
ANS($mcdec->cmp());
ANS($mcinterp->cmp());
ANS($mcerror->cmp());
Section::End();

1;