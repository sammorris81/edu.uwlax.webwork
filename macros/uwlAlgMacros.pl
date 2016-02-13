sub _uwlAlgMacros_init {};

# sample in range - by default call perl if length = 1 otherwise R
# use argument names in subroutines
# min => 10, max => 15, replace => TRUE,

package uwlAlgMacros;

@ISA = qw(Exporter);
@EXPORT_OK = qw(random_variable, random_number);

$clt = "Combine like terms";
$solcol = "red";

sub random_variable {
    my $howmany = shift // 1;
    my $letter;

    @letters = main::rserve_eval('sample(x = letters, size = ' . $howmany . ', replace = FALSE)');

    foreach my $letter (@letters) {
      main::Context()->variables->add($letter => 'Real');
    }

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
  @numbers = main::rserve_eval('sample(x = possible, size = ' . $n . ', replace = ' . $replace . ')');

  if ($n == 1) {
    return ($numbers[0]);
  } else {
    return @numbers;
  }

}

1; #required at end of file - a perl thing