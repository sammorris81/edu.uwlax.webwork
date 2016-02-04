our @cat_ind;  # storage for the categorical variables
our @text_ind;
our @params_ind;
our @rowvar_ind; our @colvar_ind;
our @rowlabs_ind; our @collabs_ind;

# used with the categorical generator - can either give observed proportions
# or observed frequencies from the sample to generate the new data
my @freqs; my @probs; my @rowlabs; my @collabs; my @labels;
my $cat; our $table;

# entry 0
@freqs = (36, 45, 24, 48, 33, 16);
@rowlabs = ("Male", "Female");
@collabs = ("Democrat", "Republican", "Independent");
@labels = (@rowlabs, @collabs);
$cat = new DataGenUWL(
  datatype => 'two_cat',
  nlevels => [scalar(@rowlabs), scalar(@collabs)],
  freqs => [@freqs],
  random => "T",
  labels => [@labels],
);

$table = CategoricalUWL::freqtable(data => $cat);

push(@cat_ind, $cat);
push(@text_ind,
  "A poll conducted by the University of Montana classified respondants by " .
  "whether they were male or female and political party, as shown in the table.".
  $table
);

push(@rowlabs_ind, [@rowlabs]);
push(@rowvar_ind, "gender");
push(@collabs_ind, [@collabs]);
push(@colvar_ind, "party affiliation");



our $num_ind = scalar(@cat_ind);

1;  # required at end of file  a perl thing