sub _uwlAlgMacros_init {};

# sample in range - by default call perl if length = 1 otherwise R
# use argument names in subroutines
# min => 10, max => 15, replace => TRUE,

package uwlAlgMacros;

@ISA = qw(Exporter);

@EXPORT_OK = qw(random_variable, random_number, add_variable_to_Context,
                initialize_Context, solution_addsub_move_format);

##
 # Macros for writing Solution section
 ##
$main::clt = "Combine like terms";
$main::solcol = "OrangeRed";
$main::dist = "Distributive property";

##
 # Consistant formatting of MathObjects
 ##
sub initialize_Context {
  main::Context()->texStrings();
  main::Context()->noreduce('(-x)+y','(-x)-y');  # Formula will keep initial negatives
}

##
 # Adds variables to the main::Context, skipping x.
 #
 # @param  variables    list of variables to add
 # @param  type         type of variables (default = 'Real')
 ##
sub add_variable_to_Context {
    my %options = @_;

    my @varlist = @{$options{'variables'}};
    my $type = defined($options{'type'}) ? $options{'type'} : 'Real';

    foreach my $var (@varlist) {
      if ($var ne 'x') {
        main::Context()->variables->add($var => $type);
      }
    }
}

##
 # Returns a list of random letters from a .. z.
 #
 # @param  size   the number of variables to generate (default = 1).
 # @return        a list if size > 1 and a single variable if size = 1.
 ##
sub random_variable {
  my $howmany = shift // 1;
  my $letter;

  @letters = main::rserve_eval('sample(x = letters, size = ' . $howmany . ', replace = FALSE)');

  if ($howmany == 1) {
    return($letters[0]);
  } else {
    return @letters;
  }
}

sub random_number {
  my %options = @_;
  my $n = defined($options{'n'}) ? $options{'n'} : 1;
  my $min = defined($options{'min'}) ? $options{'min'} : -5;
  my $max = defined($options{'max'}) ? $options{'max'} : 5;
  my $one = defined($options{'one'}) ? uc($options{'one'}) : "TRUE";  # should we allow -1, or 1
  my $zero = defined($options{'zero'}) ? uc($options{'zero'}) : "TRUE";  # should we allow 0
  my $by = defined($options{'by'}) ? $options{'by'} : 1;  # by default give integers
  my $replace = defined($options{'replace'}) ? uc($options{'replace'}) : 'FALSE';

  main::rserve_eval('possible <- seq(' . $min . ', ' . $max .', by = ' . $by . ')');
  if ($one eq "FALSE") {
    main::rserve_eval('possible <- possible[abs(possible) != 1]');
  }
  if ($zero eq "FALSE") {
    main::rserve_eval('possible <- possible[possible != 0]');
  }
  if (defined($options{'exclude'})) {
    my $exclude = $options{'exclude'};
    main::rserve_eval('possible <- possible[abs(possible) != ' . $exclude . ']');
  }
  @numbers = main::rserve_eval('sample(x = possible, size = ' . $n . ', replace = ' . $replace . ')');

  if ($n == 1) {
    return ($numbers[0]);
  } else {
    return @numbers;
  }

}

sub solution_addsub_move_format {
  my %options = @_;
  my $value = $options{'value'};
  my $includeVariable = "FALSE";
  my $var; my $move; my $invop;

  if (defined($options{'variable'})) {
    $includeVariable = "TRUE";
    $var = $options{'variable'};
  }

  if ($value < 0) {
    $action = "Add ";
    $symbol = " + ";
    $text = abs($value);
  } else {
    $action = "Subtract ";
    $symbol = " - ";
    $text = $value;
  }

  if ($includeVariable eq "TRUE") {
    if ($value == 1) {
      $text = $var;
    } else {
      $text = $text . $var;
    }
  }

  $move = $action . $text;
  $invop = $symbol . $text;

  return ($move, $invop);
}

1; #required at end of file - a perl thing