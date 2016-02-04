# macros_template.pl
# Rename this file (with .pl extension) and place it in your course macros
# directory,

# define any custom subroutines you want and then use them in
# problems by including the file in loadMacros() calls.

if (!defined(&rserve_start)) {
  loadMacros("RserveClient.pl");
}

if (!defined(&_parserRadioButtons_init)) {
  loadMacros("parserRadioButtons.pl");
}

if (!defined(&_unionTables_init)) {
  loadMacros("unionTables.pl");
}

if (!defined(&_uwlUsefulStats_init)) {
  loadMacros("uwlUsefulStats.pl");
}

if (!defined(&_uwlQuantitative_init)) {
  loadMacros("uwlQuantitative.pl");
}

# PG macros shouldn't reload by default if they're already loaded
loadMacros("PGgraphmacros.pl",
           "PGstandard.pl",
           "PGstatisticsmacros.pl",
           "PGunion.pl",
);

sub _uwlHyptestProblem_init {};

package hyptestProblemUWL;

#
#  The state data that is stored between invocations of
#  the problem.
#
our %defaultStatus = (
  part => 1,                # the current part
  part_attempts => 0,       # attempts on THIS part
  answers => "",            # answer labels from previous parts
  new_answers => "",        # answer labels for THIS part
  ans_rule_count => 0,      # the ans_rule count from previous parts
  new_ans_rule_count => 0,  # the ans_rule count from THIS part
  images_created => 0,      # the image count from the precious parts
  new_images_created => 0,  # the image count from THIS part
  imageName => "",          # name of images_created image file
  score => 0,               # the (weighted) score on this part
  total => 0,               # the total on previous parts
  raw => 0,                 # raw score on this part
);

#
#  Create a new instance of the compound Problem and initialize
#  it.  This includes reading the status from the previous
#  parts, defining the variables from the answers to previous parts,
#  and setting up the grader so that the current data can be saved.
#
sub new {
  my $self = shift; my $class = ref($self) || $self;
  my $hpt = bless {
    parts => 1,
    attempts => undef,           # number of attempts per part
    totalAnswers => undef,
    weights => undef,            # array of weights per part
    saveAllAnswers => 1,         # usually only save named answers
    parserValues => 0,           # make Parser objects from the answers?
    nextVisible => "ifCorrect",  # or "Always" or "Never"
    nextStyle   => "Checkbox",   # or "Button", "Forced", or "HTML"
    nextLabel   => undef,        # Checkbox text or button name or HTML
    nextNoChange => 1,           # true if answer can't change for new part
    allowReset => 0,             # true to show "back to part 1" button
    resetLabel => undef,         # label for reset button
    grader => $main::PG->{flags}->{PROBLEM_GRADER_TO_USE} || \&main::avg_problem_grader,
    @_,
    status => $defaultStatus,
  }, $class;
  die "You must provide either the totalAnswers or weights"
    unless $hpt->{totalAnswers} || $hpt->{weights};
  if ($hpt->{weights}) {
    $hpt->getTotalWeight;
  }
  main::loadMacros("Parser.pl") if $hpt->{parserValues};
  if ($hpt->{allowReset} && $main::inputs_ref->{_reset}) {
    $hpt->reset;
  }

  if (defined($hpt->{attempts}) && @{$hpt->{attempts}} != $hpt->{parts}) {
    die "You must indicate the number of attempts for each part.";
  }
  $hpt->getStatus;
  $hpt->initPart;
  $hpt->{status}->{part_attempts}++;
  return $hpt;
}

#
#  Compute the total of the weights so that the parts can
#  be properly scaled.
#
sub getTotalWeight {
  my $self = shift;
  $self->{totalWeight} = 0; $self->{totalAnswers} = 1;
  foreach my $w (@{$self->{weights}}) {$self->{totalWeight} += $w}
  $self->{totalWeight} = 1 if $self->{totalWeight} == 0;
}

#
#  Look up the status from the previous invocation
#  and see if we need to go on to the next part.
#
sub getStatus {
  my $self = shift;
  main::RECORD_FORM_LABEL("_next");
  main::RECORD_FORM_LABEL("_status");
  $self->{status} = $self->decode;
  $self->{isNew} = $main::inputs_ref->{_next} || ($main::inputs_ref->{submitAnswers} &&
     $main::inputs_ref->{submitAnswers} eq ($self->{nextLabel} || "Go on to Next Part"));
  if ($self->{isNew}) {
    $self->checkAnswers;
    $self->incrementPart unless $self->{nextNoChange} && $self->{answersChanged};
  }
}

#
#  Initialize the current part by setting the ans_rule
#  count (so that later parts will get unique answer names),
#  installing the grader (to save the data), and setting
#  the variables for previous answers.
#
sub initPart {
  my $self = shift;
  $main::ans_rule_count = $self->{status}{ans_rule_count};
  $main::images_created{$self->{status}{imageName}} = $self->{status}{images_created}
    if $self->{status}{imageName};
  main::install_problem_grader(\&hyptestProblemUWL::grader);
  $main::PG->{flags}->{hyptestProblemUWL} = $self;
  $self->initAnswers($self->{status}{answers});
}

#
#  Look through the list of answer labels and set
#  the variables for them to be the associated student
#  answer.  Make it a Parser value if requested.
#  Record the value so that is will be available
#  again on the next invocation.
#
sub initAnswers {
  my $self = shift; my $answers = shift;
  foreach my $id (split(/;/,$answers)) {
    my $value = $main::inputs_ref->{$id}; $value = '' unless defined($value);
    if ($self->{parserValues}) {
      my $parser = Parser::Formula($value);
      $parser = Parser::Evaluate($parser) if $parser && $parser->isConstant;
      $value = $parser if $parser;
    }
    ${"main::$id"} = $value unless $id =~ m/$main::ANSWER_PREFIX/o;
    $value = quoteHTML($value);
    main::TEXT(qq!<input type="hidden" name="$id" value="$value" />!);
    main::RECORD_FORM_LABEL($id);
  }
}

#
#  Look to see is any answers have changed on this
#  invocation of the problem.
#
sub checkAnswers {
  my $self = shift;
  foreach my $id (keys(%{$main::inputs_ref})) {
    if ($id =~ m/^previous_(.*)$/) {
      if ($main::inputs_ref->{$id} ne $main::inputs_ref->{$1}) {
        $self->{answersChanged} = 1;
        $self->{isNew} = 0 if $self->{nextNoChange};
        return;
      }
    }
  }
}

#
#  Go on to the next part, updating the status
#  to include the data from the old part so that
#  it will be properly preserved when the next
#  part is showing.
#
sub incrementPart {
  my $self = shift;
  my $status = $self->{status};
  if ($status->{part} < $self->{parts}) {
    $status->{part}++;
    $status->{part_attempts} = 0;
    $status->{answers} .= ';' if $status->{answers};
    $status->{answers} .= $status->{new_answers};
    # $status->{answers} = $status->{new_answers};
    $status->{ans_rule_count} = $status->{new_ans_rule_count};
    $status->{images_created} = $status->{new_images_created};
    $status->{total} += $status->{score};
    $status->{score} = $status->{raw} = 0;
    $status->{new_answers} = '';
  }
}

######################################################################

#
#  Encode all the status information so that it can be
#  maintained as the student submits answers.  Since this
#  state information includes things like the score from
#  the previous parts, it is "encrypted" using a dumb
#  hex encoding (making it harder for a student to recognize
#  it as valuable data if they view the page source).
#
sub encode {
  my $self = shift; my $status = shift || $self->{status};
  my @data = (); my $data = "";
  foreach my $id (main::lex_sort(keys(%defaultStatus))) {push(@data,$status->{$id})}
  foreach my $c (split(//,join('|',@data))) {$data .= toHex($c)}
  return $data;
}

#
#  Decode the data and break it into the status hash.
#
sub decode {
  my $self = shift; my $status = shift || $main::inputs_ref->{_status};
  return {%defaultStatus} unless $status;
  my @data = (); foreach my $hex (split(/(..)/,$status)) {push(@data,fromHex($hex)) if $hex ne ''}
  @data = split('\\|',join('',@data)); $status = {%defaultStatus};
  if (scalar(@data) == 8) {
    # insert imageName, images_created, new_images_created, if missing
    splice(@data,2,0,"",0); splice(@data,6,0,0);
  }
  foreach my $id (main::lex_sort(keys(%defaultStatus))) {$status->{$id} = shift(@data)}
  return $status;
}


#
#  Hex encoding is shifted by 10 to obfuscate it further.
#  (shouldn't be a problem since the status will be made of
#  printable characters, so they are all above ASCII 32)
#
sub toHex {main::spf(ord(shift)-10,"%X")}
sub fromHex {main::spf(hex(shift)+10,"%c")}


#
#  Make sure the data can be properly preserved within
#  an HTML <INPUT TYPE="HIDDEN"> tag.
#
sub quoteHTML {
  my $string = shift;
  $string =~ s/&/\&amp;/g; $string =~ s/"/\&quot;/g;
  $string =~ s/>/\&gt;/g;  $string =~ s/</\&lt;/g;
  return $string;
}

######################################################################

#
#  Set the grader for this part to the specified one.
#
sub useGrader {
  my $self = shift;
  $self->{grader} = shift;
}

#
#  Make additional answer blanks from the current part
#  be preserved for use in future parts.
#
sub addAnswers {
  my $self = shift;
  $self->{extraAnswers} = [] unless $self->{extraAnswers};
  push(@{$self->{extraAnswers}},@_);
}

#
#  Go back to part 1 and clear the answers and scores.
#
sub reset {
  my $self = shift;
  if ($main::inputs_ref->{_status}) {
    my $status = $self->decode($main::inputs_ref->{_status});
    foreach my $id (split(/;/,$status->{answers})) {delete $main::inputs_ref->{$id}}
    foreach my $id (1..$status->{ans_rule_count})
      {delete $main::inputs_ref->{"${main::QUIZ_PREFIX}${main::ANSWER_PREFIX}$id"}}
  }
  $main::inputs_ref->{_status} = $self->encode(\%defaultStatus);
  $main::inputs_ref->{_next} = 0;
}

#
#  Return the HTML for the "Go back to part 1" checkbox.
#
sub resetCheckbox {
  my $self = shift;
  my $label = shift || " <b>Go back to Part 1</b> (when you submit your answers).";
  my $par = shift; $par = ($par ? $main::PAR : '');
  qq'$par<input type="checkbox" name="_reset" value="1" />$label';
}

#
#  Return the HTML for the "next part" checkbox.
#
sub nextCheckbox {
  my $self = shift;
  my $label = shift || " <b>Go on to next part</b> (when you submit your answers).";
  my $par = shift; $par = ($par ? $main::PAR : '');
  $self->{nextInserted} = 1;
  qq!$par<input type="checkbox" name="_next" value="next" />$label!;
}

#
#  Return the HTML for the "next part" button.
#
sub nextButton {
  my $self = shift;
  my $label = quoteHTML(shift || "Go on to Next Part");
  my $par = shift; $par = ($par ? $main::PAR : '');
  $par . qq!<input type="submit" name="submitAnswers" value="$label" !
       .      q!onclick="document.getElementById('_next').value=1" />!;
}

#
#  Return the HTML for when going to the next part is forced.
#
sub nextForced {
  my $self = shift;
  my $label = shift || "<b>Submit your answers again to go on to the next part.</b>";
  $label = $main::PAR . $label if shift;
  $self->{nextInserted} = 1;
  qq!$label<input type="hidden" name="_next" id="_next" value="Next" />!;
}

#
#  Return the raw HTML provided
#
sub nextHTML {shift; shift}

######################################################################

#
#  Return the current part, or try to set the part to the given
#  part (returns the part actually set, which may be earlier if
#  the student didn't complete an earlier part).
#
sub part {
  my $self = shift; my $status = $self->{status};
  # debug
  my $part = shift;
  return $status->{part} unless defined $part && $main::displayMode ne 'TeX';
  $part = 1 if $part < 1;
  if ($part > $self->{parts}){
    $part = $self->{parts};
  }

  if ($part > $status->{part} && !$main::inputs_ref->{_noadvance}) {
    unless ((lc($self->{nextVisible}) eq 'ifcorrect' && $status->{raw} < 1) ||
             lc($self->{nextVisible}) eq 'never') {
      $self->initAnswers($status->{new_answers});
      $self->incrementPart;
      $self->{isNew} = 1;
    }
  }
  if ($part != $status->{part}) {
    main::TEXT('<input type="hidden" name="_noadvance" value="1" />');
    if (lc($self->{nextVisible}) eq 'never') {
      $self->{nextVisible} = 'IfCorrect';
    }
  }
  return $status->{part};
}

#
#  Return the various scores
#
sub score {shift->{status}{score}}
sub scoreRaw {shift->{status}{raw}}
sub scoreOverall {
  my $self = shift;
  return $self->{status}{score} + $self->{status}{total};
}

######################################################################
#
#  The custom grader that does the work of computing the scores
#  and saving the data.
#
sub grader {
  my $self = $main::PG->{flags}->{hyptestProblemUWL};
  #
  #  Get the answer names and the weight for the current part.
  #
  my @answers = keys(%{$_[0]});
  my $weight = scalar(@answers)/$self->{totalAnswers};

  if ($self->{weights} && defined($self->{weights}[$self->{status}{part}-1])){
    $weight = $self->{weights}[$self->{status}{part}-1]/$self->{totalWeight};
  }
  @answers = grep(!/$main::ANSWER_PREFIX/o,@answers) unless $self->{saveAllAnswers};
  push(@answers,@{$self->{extraAnswers}}) if $self->{extraAnswers};
  my $space = '<img src="about:blank" style="height:1px; width:3em; visibility:hidden" />';

  #
  #  Call the original grader, but put back the old recorded_score
  #  (the grader will have updated it based on the score for the PART,
  #  not the problem as a whole).
  #
  my $oldScore = ($_[1])->{recorded_score};
  my ($result,$state) = &{$self->{grader}}(@_);
  $state->{recorded_score} = $oldScore;

  #
  #  Update that state information and encode it.
  #
  my $status = $self->{status};
  $status->{raw}   = $result->{score};
  $status->{score} = $result->{score}*$weight;
  $status->{new_ans_rule_count} = $main::ans_rule_count;
  if (defined(%main::images_created)) {
    $status->{imageName} = (keys %main::images_created)[0];
    $status->{new_images_created} = $main::images_created{$status->{imageName}};
  }
  $status->{new_answers} = join(';',@answers);
  my $data = quoteHTML($self->encode);

  #
  #  Update the recorded score
  #
  my $newScore = $status->{total} + $status->{score};
  $state->{recorded_score} = $newScore if $newScore > $oldScore;
  $state->{recorded_score} = 0 if $self->{allowReset} && $main::inputs_ref->{_reset};

  #
  #  Add the compoundProblem message and data
  #
  $result->{type} = "hyptestProblemUWL ($result->{type})";
  $result->{msg} .= '</i><p><strong>Note:</strong> <em>' if $result->{msg};
  $result->{msg} .= 'This problem has more than one part. '.
     'Your score for this attempt is for this part only. '.
     'The overall score is for all the parts combined. </em>'.
     qq!<input type="hidden" name="_status" value="$data" />!;

  #
  #  Warn if the answers changed when they shouldn't have
  #
  if ($self->{nextNoChange} && $self->{answersChanged}){
    $result->{msg} .= '<p><b>You may not change your answers when going on to the next part!</b>';
  }
  #
  #  Include the "next part" checkbox, button, or whatever.
  #
  my $par = 1;
  if ($self->{parts} > $status->{part} && !$main::inputs_ref->{previewAnswers}) {
    # debug
    if (lc($self->{nextVisible}) eq 'always' ||
        (lc($self->{nextVisible}) eq 'ifcorrect' && $status->{score} >= 1)) {
      my $method = "next".$self->{nextStyle};
      $par = 0;
      $result->{msg} .= $self->$method($self->{nextLabel},1).'<br/>';
    }
  }

  # added by Sam. Checks the score or to see if this is the last attempt.
  if ($status->{raw} == 1 && lc($self->{nextVisible}) eq 'ifcorrect') {
    $par = 0;
    if ($self->{parts} > $status->{part} && !$main::inputs_ref->{previewAnswers}) {
      $result->{msg} .= '<p><strong>You have answered this part correctly.</strong> ';
      $result->{msg} .= 'Click on the "Submit Answers" button again to move to the ';
      $result->{msg} .= 'next part';
      $result->{msg} .= '<input type="hidden" name="_next" value="1" />';
      $self->{nextInserted} = 1;
    }
  } elsif ($status->{part_attempts} == $self->{attempts}[$status->{part}-1]) {
    $result->{msg} .= '<p><strong>This is your final attempt on this part.</strong>';
    $result->{msg} .= 'When you click the "Submit Answers" button, you will automatically ';
    $result->{msg} .= 'start the next part.';
    # force to move on if correct or exhausted number of attempts
    if ($self->{parts} > $status->{part} && !$main::inputs_ref->{previewAnswers}) {
        $result->{msg} .= '<input type="hidden" name="_next" value="1" />';
        $self->{nextInserted} = 1;
    }
  }

  #
  #  Add the reset checkbox, if needed
  #
  $result->{msg} .= $self->resetCheckbox($self->{resetLabel},$par)
    if $self->{allowReset} && $status->{part} > 1;

  #
  #  Make sure we don't go on unless the next button really is checked
  #
  $result->{msg} .= '<input type="hidden" name="_next" value="0" />'
    unless $self->{nextInserted};

  return ($result,$state);
}

sub statenull { #$nullval
    my %options = @_;

    my $nullval;
    if (!defined($options{'nullval'})) {
        die "Error: You must specify nullval => $nullval";
    } else {
        $nullval = $options{'nullval'};
    }

    my $param;
    if (!defined($options{'param'})) {
        die 'Error: You must specify the parameter using param => $param '.
            "you should use the latex for any parameters";
    } else {
        $param = $options{'param'};
    }

    my $hyp = '\(H_0: '.$param.' = '. $nullval .'\)';
    return($hyp);
}

sub statealt { #$type, $nullval
    my %options = @_;

    my $type;
    if (!defined($options{'type'})) {
        die "Error: You must specify type => 'GT', 'LT', or 'NEQ' for the ".
            "alternative hypothesis";
    } else {
        $type = uc($options{'type'});
    }

    if( ($type ne 'GT' && $type ne 'LT' && $type ne 'NEQ') || !defined($type) ){
        die "The type of alternative hypothesis must be defined as".
        "either gt, lt, or neq";
    }

    my $nullval;
    if (!defined($options{'nullval'})) {
        die "Error: You must specify nullval => $nullval";
    } else {
        $nullval = $options{'nullval'};
    }

    my $param;
    if (!defined($options{'param'})) {
        die "Error: You must specify the parameter using param => $param ".
            "you should use the latex for any parameters";
    } else {
        $param = $options{'param'};
    }

    my $hyp;
    if( $type eq 'GT' ){
        $hyp = '\(H_a: '.$param.' > '. $nullval .'\)';
    } elsif( $type eq 'LT' ){
        $hyp = '\(H_a: '.$param.' < '. $nullval .'\)';
    } else {
        $hyp = '\(H_a: '.$param.' \neq '. $nullval .'\)';
    }

    return($hyp);
}

sub selectnull { #$nullval
    my %options = @_;

    my $nullval;
    if (!defined($options{'nullval'})) {
        die "Error: You must specify nullval => $nullval";
    } else {
        $nullval = $options{'nullval'};
    }

    my $param;
    if (!defined($options{'param'})) {
        die "Error: You must specify the parameter using param => $param ".
            "you should use the latex for any parameters";
    } else {
        $param = $options{'param'};
    }

    my $select = main::RadioButtons(
        [ # choices
        ' \(H_0: '.$param.' = '. $nullval .' \)',
        ' \(H_0: '.$param.' < '. $nullval .' \)',
        ' \(H_0: '.$param.' > '. $nullval .' \)',
        ' \(H_0: '.$param.' \neq '. $nullval .' \)'
        ],
        ' \(H_0: '.$param.' = '. $nullval .' \)',
        order => [
        ' \(H_0: '.$param.' = '. $nullval .' \)',
        ' \(H_0: '.$param.' < '. $nullval .' \)',
        ' \(H_0: '.$param.' > '. $nullval .' \)',
        ' \(H_0: '.$param.' \neq '. $nullval .' \)'
        ],
        labels => [
        'a',
        'b',
        'c',
        'd'
        ]
    );

    return($select);
}

sub selectalt { #$type, $nullval
    my %options = @_;

    my $type;
    if (!defined($options{'type'})) {
        die "Error: You must specify type => 'GT', 'LT', or 'NEQ' for the ".
            "alternative hypothesis";
    } else {
        $type = uc($options{'type'});
    }

    if( ($type ne 'GT' && $type ne 'LT' && $type ne 'NEQ') || !defined($type) ){
        die "The type of alternative hypothesis must be defined as".
        "either gt, lt, or neq";
    }

    my $nullval;
    if (!defined($options{'nullval'})) {
        die "Error: You must specify nullval => $nullval";
    } else {
        $nullval = $options{'nullval'};
    }

    my $param;
    if (!defined($options{'param'})) {
        die "Error: You must specify the parameter using param => $param ".
            "you should use the latex for any parameters";
    } else {
        $param = $options{'param'};
    }

    my $correct;
    if( $type eq 'GT' ){
        $correct = ' \(H_a: '.$param.' > '. $nullval .' \)';
    } elsif( $type eq 'LT' ){
        $correct = ' \(H_a: '.$param.' < '. $nullval .' \)';
    } else {
        $correct = ' \(H_a: '.$param.' \neq '. $nullval .' \)';
    }

    my $select = main::RadioButtons(
        [ # choices
        ' \(H_a: '.$param.' = '. $nullval .' \)',
        ' \(H_a: '.$param.' < '. $nullval .' \)',
        ' \(H_a: '.$param.' > '. $nullval .' \)',
        ' \(H_a: '.$param.' \neq '. $nullval .' \)'
        ],
        $correct,
        order => [
        ' \(H_a: '.$param.' = '. $nullval .' \)',
        ' \(H_a: '.$param.' < '. $nullval .' \)',
        ' \(H_a: '.$param.' > '. $nullval .' \)',
        ' \(H_a: '.$param.' \neq '. $nullval .' \)'
        ],
        labels => [
        'a',
        'b',
        'c',
        'd'
        ]
    );

    return($select);
}

1;