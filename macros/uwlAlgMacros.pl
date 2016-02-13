sub _uwlAlgMacros_init {};

# sample in range - by default call perl if length = 1 otherwise R
# use argument names in subroutines
# min => 10, max => 15, replace => TRUE,

package uwlAlgMacros;

@ISA = qw(Exporter);
@EXPORT_OK = qw(random_variable, add_variable_to_Context);

##
 # Consistant formatting of MathObjects
 ##
main::Context()->noreduce('(-x)+y','(-x)-y');  # Formula will keep initial negatives

##
 # Macros for writing Solution section
 ##
$clt = "Combine like terms";
$solcol = "OrangeRed";

##
 # Adds variables to the main::Context, skipping x.  
 # 
 # @param  variables    list of variables to add 
 # @param  type         type of variables (default = 'Real')
 ##
sub add_variable_to_Context {
    my %options = @_;
    my $varlist;

    @varlist = $options{'variables'};
    my $type = defined($options{'type'}) ? $options{'type'} : 'Real';

    foreach my $var ($varlist) {
      if $var != 'x' {
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
  my $howmany = shift // 1;
  my %options = @_;

  my $min = defined($options{'min'}) ? $options{'min'} : -5;
  my $max = defined($options{'max'}) ? $options{'max'} : 5;
  my $type = defined($options{'type'}) ? $options{'type'} : "integer";



}

1; #required at end of file - a perl thing