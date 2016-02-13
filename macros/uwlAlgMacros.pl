sub _uwlAlgMacros_init {};

# sample in range - by default call perl if length = 1 otherwise R
# use argument names in subroutines
# min => 10, max => 15, replace => TRUE,

package uwlAlgMacros;

@ISA = qw(Exporter);
@EXPORT_OK = qw(random_variable);

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
  my $howmany = shift // 1;
  my %options = @_;

  my $min = defined($options{'min'}) ? $options{'min'} : -5;
  my $max = defined($options{'max'}) ? $options{'max'} : 5;
  my $type = defined($options{'type'}) ? $options{'type'} : "integer";



}

1; #required at end of file - a perl thing