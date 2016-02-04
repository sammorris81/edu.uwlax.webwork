our @cat_gof;  # storage for the categorical variables
our @text_gof;
our @params_gof;
our @null_gof;  # will be an array of arrays

# used with the categorical generator - can either give observed proportions
# or observed frequencies from the sample to generate the new data
my @freqs; my @probs; my @labels; my @null;
my $cat; our $table;

# entry 0
@freqs = (29, 23, 12, 14, 8, 20);
@null = (0.20, 0.20, 0.10, 0.10, 0.10, 0.30);
@labels = ("Yellow", "Red", "Orange", "Blue", "Green", "Brown");
$cat = new DataGenUWL(
  datatype => 'one_cat',
  n => usefulstatUWL::sum(@freqs),
  nlevels => [scalar(@freqs)],
  freqs => [@freqs],
  random => "T",
  labels => [@labels],
);

$table = CategoricalUWL::freqtable(data => $cat, transpose => "Y");

push(@null_gof, [@null]);
push(@cat_gof, $cat);
push(@text_gof,
  "The Masterfoods Company says that until very recently yellow candies made up ".
  "20$PERCENT of its milk chocolate M${disp_amp}Ms, red another 20$PERCENT, and ".
  "orange, blue, and green 10$PERCENT each. The rest are brown. The following ".
  "table shows the counts for the different colors in a bag of M${disp_amp}Ms.".
  $table
);

push(@params_gof,
  "company's stated proportions of colors"
);

# entry 1
@freqs = (22, 39, 34, 19, 75);
@null = (0.10, 0.20, 0.20, 0.10, 0.40);
@labels = ("Brazil nuts", "Cashews", "Almonds", "Hazelnuts", "Peanuts");
$cat = new DataGenUWL(
  datatype => 'one_cat',
  n => usefulstatUWL::sum(@freqs),
  nlevels => [scalar(@freqs)],
  freqs => [@freqs],
  random => "T",
  labels => [@labels],
);

$table = CategoricalUWL::freqtable(data => $cat, transpose => "Y");

push(@null_gof, [@null]);
push(@cat_gof, $cat);
push(@text_gof,
  "A company says its premium mixture of nuts contains 10$PERCENT Brazil nuts, " .
  "20$PERCENT cashews, 20$PERCENT almonds, 10$PERCENT peanuts, and the rest are " .
  "peanuts. You buy a large can and separate the various kinds of nuts.  The following ".
  "table shows the amount of each kind of nuts in grams".
  $table
);

push(@params_gof,
  "company's stated proportions of nut types"
);

our $num_gof = scalar(@cat_gof);

1;  # required at end of file  a perl thing