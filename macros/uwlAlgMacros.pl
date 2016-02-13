sub _uwlAlgMacros_init {};

# sample in range - by default call perl if length = 1 otherwise R
# use argument names in subroutines
# min => 10, max => 15, replace => TRUE,

package uwlAlgMacros;

$clt = "Combine like terms";
$solcol = "OrangeRed";

sub random_variable {
    my $letter;

    ($letter) = rserve_eval('sample(x = letters, size = 1, replace = FALSE)');
    return($letter);
}

1; #required at end of file - a perl thing