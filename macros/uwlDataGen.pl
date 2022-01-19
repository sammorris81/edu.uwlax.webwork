# datagen_UWL.pl

if (!exists(&rserve_start)) {
  loadMacros("RserveClient.pl");
}

if (!exists(&_parserRadioButtons_init)) {
  loadMacros("parserRadioButtons.pl");
}

if (!exists(&_unionTables_init)) {
  loadMacros("unionTables.pl");
}

if (!exists(&_uwlUsefulStats_init)) {
  loadMacros("uwlUsefulStats.pl");
}

if (!exists(&_uwlQuantitative_init)) {
  loadMacros("uwlQuantitative.pl");
}

# PG macros shouldn't reload by default if they're already loaded
loadMacros("PGgraphmacros.pl",
           "PGstandard.pl",
           "PGstatisticsmacros.pl",
           "PGunion.pl"
);

sub _uwlDataGen_init {};

package DataGenUWL;
@ISA = qw(Value::String);

sub Init {
    main::PG_restricted_eval(' sub DataGenUWL {DataGenUWL -> new(@_)}')
}

=pod

=cut

sub new {
    my $self = shift;
    my %options = @_;

    # check to see if the datatype is defined
    our $datatype = defined($options{'datatype'}) ? $options{'datatype'} : 1;

    if ($datatype eq 'one_cat') {
        $self -> new_categorical_UWL(@_);
    } elsif ($datatype eq 'two_cat') {
        $self -> new_categorical_UWL(@_);
    } elsif ($datatype eq 'single_quant') {
        $self -> new_quantitative_UWL(@_);
    } elsif ($datatype eq 'chi2_gof') {
        $self -> new_chi2_gof(@_);
    } elsif ($datatype eq 'chi2_ind') {
        $self -> new_chi2_ind(@_);
    } elsif ($datatype eq '1samp_t') {
        $self -> new_1samp_t(@_);
    } elsif ($datatype eq '2samp_t') {
        $self -> new_2samp_t(@_);
    } elsif ($datatype eq 'pdiff_t') {
        $self -> new_pdiff_t(@_);
    } elsif ($datatype eq '1way_aov') {
        $self -> new_1wayaov_UWL(@_);
    } elsif ($datatype eq 'simp_reg') {
        $self -> new_simpreg_UWL(@_);
    } elsif ($datatype eq 'bs_one_cat') {
        $self -> new_bs1cat_UWL(@_);
    } elsif ($datatype eq 'bs_two_cat') {
        $self -> new_bs2cat_UWL(@_);
    } elsif ($datatype eq 'bs_one_samp') {
        $self -> new_bs1samp_UWL(@_);
    } elsif ($datatype eq 'bs_one_mean') {
        $self -> new_bs1mean_UWL(@_);
    } elsif ($datatype eq 'bs_two_mean') {
        $self -> new_bs2mean_UWL(@_);
    } else {
        warn 'Warning: datatype must be one of the following: chi2_gof, chi2_ind, '.
             '1samp_t, 2samp_t, pdiff_t, 1way_aov, 2way_aov, simp_reg, mult_reg';
    }
}

# TODO: Export df, test stat, p-value
sub new_categorical_UWL {
    my $self = shift;
    my $class = 'CategoricalUWL';
    my %options = @_;

    # pull entries from function arguments.
    my $n;
    $n = defined($options{'n'}) ? $options{'n'} : 200;

    my $nrows; my $ncols;
    my @nlevels; # an array to tell how many levels for each row group/col group.
    if ($datatype eq 'one_cat') {

        if (defined($options{'nlevels'})) {
            @nlevels = @{$options{'nlevels'}};
        } else {
            push(@nlevels, 2);
            warn 'Warning: nlevels not defined. Defaulting to one categorical '.
                 'variable with 2 levels.';
        }

        if (@nlevels > 1) {
            warn 'Warning: For a single categorical variable, nlevels should '.
                 'have length 1. Only using first entry in nlevels.';
        }
        while (@nlevels > 1) {
            pop(@nlevels);
        }

        $nrows = $nlevels[0];
        $ncols = 1;


    } elsif ($datatype eq 'two_cat') {
        if (defined($options{'nlevels'})) {
            @nlevels = @{$options{'nlevels'}};
        } else {
            while (@nlevels < 2) {
                push(@nlevels, 2);
            }
            warn 'Warning: nlevels not defined. Defaulting to two categorical '.
                 'variables with 2 levels each.';
        }

        if (@nlevels > 2) {
            warn 'Warning: For two categorical variables, nlevels should '.
                 'have length 2. Only using first two entries in nlevels.';
        }
        while (@nlevels > 2) {
            pop(@nlevels);
        }

        $nrows = $nlevels[0];
        $ncols = $nlevels[1];
    }

    my $ncells = $nrows * $ncols;

    my $randomfreqs = defined($options{'random'}) ? uc($options{'random'}) : "T";

    # preference is given to freqs for the table generation if defined.
    my @freqs; my $freq; my @probs; my $prob; my $sumprob;
    if (defined($options{'freqs'})) {
        @freqs = @{$options{'freqs'}};
        $n = usefulstatUWL::sum(@freqs); # will overwrite anything previously given.
        for my $cellidx (0..($ncells-1)) {
            $prob = $freqs[$cellidx] / $n;
            push(@probs, $prob);
        }
    } elsif (defined($options{'probs'})) {
        @probs = @{$options{'probs'}};
        $sumprob = sprintf("%.4f", usefulstatUWL::sum(@probs));
        if( scalar(@probs) != $ncells ){
            die "Error: The length of your probability vector does not match ".
                "the number of overall groups.";
        } elsif ($sumprob != 1){
            die "Error: The probabilities in your probability vector should add ".
                "to 1. It currently sums to $sumprob";
        }
    } else {
        $equalprob = 1 / $ncells;
        foreach (1..$ncells) {
            push(@probs, $equalprob);
        }
        warn "Warning: freqs and probs are not defined. Defaulting to equal cell ".
             "probabilities.";
    }

    if( $randomfreqs eq "T" ){
        my @tempprobs; my $tempprob; my $tempmin; my $tempmax;
        my @tempfreqs; my $tempfreq;
        for my $i (0..($ncells - 2)){ #need to constrain sum(@probs) to 1
            $tempmin = $probs[$i] - 0.025;
            $tempmin = main::max($tempmin, 0.0005);
            $tempmax = $probs[$i] + 0.025;
            $tempmax = main::min($tempmax, 0.9995);

            $tempprob = main::random($tempmin, $tempmax, 0.0001);

            $tempfreq = main::floor($n * $tempprob);

            $tempprob = $tempfreq / $n; #want the prob vector and freq to match
            $tempprob = sprintf("%.4f", $tempprob);
            push(@tempfreqs, $tempfreq);
            push(@tempprobs, $tempprob);
        }
        push(@tempfreqs, ($n - usefulstatUWL::sum(@tempfreqs)));
        push(@tempprobs, (1 - usefulstatUWL::sum(@tempprobs)));

        @freqs = @tempfreqs;
        @probs = @tempprobs;
    } else {
        if (@freqs == 0) {  # If @freqs has length, just use what was given
            for my $i (0..($ncells - 2)) {
                $freq = main::floor($n * $probs[$i]);
                push(@freqs, $freq);
            }
            push(@freqs, ($n - usefulstatUWL::sum(@freqs)));
        }
    }

    my @labels; my $label;
    my $nlabels = usefulstatUWL::sum(@nlevels);
    if( defined($options{'labels'}) ){
        @labels = @{$options{'labels'}};
        if( scalar(@labels) != $nlabels ){
            die "Error: The length of your label vector does not match ".
                "the number of overall groups.";
        }
    } else {
        for (my $i=0; $i < scalar(@nlevels); $i++) {
            for (my $j=0; $j<$nlevels[$i]; $j++) {
                $label = "Group ".($j+1);
                push(@labels, $label);
            }
        }
    }

    $self = bless {
        n => $n,
        nlevels => [@nlevels],
        probs => [@probs],
        freqs => [@freqs],
        labels => [@labels],
        nrows => $nrows, ncols => $ncols,
        datatype => $options{'datatype'},
    }, $class;
}

sub new_quantitative_UWL {
    my $self = shift;
    my $class = 'QuantitativeUWL';
    my %options = @_;

    # pull entries from function arguments.
    my $n = defined($options{'n'}) ? $options{'n'} : 200;
    my $mean = 0;
    if( defined($options{'mean'}) ){
        $mean = $options{'mean'};
    }

    my $sd = 1;
    if (defined($options{'sd'})){
        $sd = $options{'sd'};
        if( $sd < 0 ){
            die "Error: Standard deviation must be non-negative";
        }
    }

    my $tempmax; my $tempmin;
    my $randomsummary = defined($options{'randomsummary'}) ? $options{'randomsummary'} : 'T';
    if( $randomsummary eq 'T' ){
        $tempmin = $mean - $sd;
        $tempmax = $mean + $sd;
        $mean = main::random($tempmin, $tempmax, 0.01);

        $tempmin = 0.95 * $sd;
        $tempmax = 1.05 * $sd;
        $sd = main::random($tempmin, $tempmax, 0.01);
    }

    my $df = 'Inf';
    if (defined($options{'df'})){
        $df = $options{'df'};
        if( $df < 1 ){
            die "Error: df should be greater than 1";
        }
    }

    my $skew = 0;
    if (defined( $options{'skew'})){
        $skew = $options{'skew'};
    }

    my $name;
    if (defined($options{'name'})){
        $name = $options{'name'};
    } else {
        $name = "variable";
    }

    my $round = defined($options{'round'}) ? $options{'round'} : 4;

    # generate rvs
    my @x; my $tempx; my $tempx1; my $tempx2;
    my $randomx = defined($options{'randomx'}) ? uc($options{'randomx'}) : "T";
    if( $randomx eq "T"){
        if( $df eq 'Inf' ){
            for( my $i=0; $i<$n; $i++ ){
                $tempx1 = usefulstatUWL::rnorm(0, 1);
                $tempx2 = usefulstatUWL::rnorm(0, 1);
                $tempx  = $skew * main::abs($tempx1) + $tempx2;
                push(@x, $tempx);
            }
        } else {
            for( my $i=0; $i<$n; $i++ ){
                $tempx1 = usefulstatUWL::rt($df);
                $tempx2 = usefulstatUWL::rt($df);
                $tempx = $skew * main::abs($tempx1) + $tempx2;
                push(@x, $tempx);
            }
        }

        my $tempmean = usefulstatUWL::mean(@x);
        my $tempsd   = usefulstatUWL::sd(@x);

        # now give the mean and sd as requested
        my $z; my $zidx = 0;
        foreach (@x) {
            $z = ( $x[$zidx] - $tempmean )/ $tempsd;
            $x[$zidx] = sprintf("%.".$round."f", $z * $sd + $mean);
            $zidx ++;
        }
    } else {
        if( !defined($options{'x'}) ){
            die "Error: To use randomx => 'F', you must specify an x vector";
        }
        @x = @{$options{'x'}};
    }

    # Make sure $mean and $sd match the data
    $mean = usefulstatUWL::mean(@x);
    $sd   = usefulstatUWL::sd(@x);
    $mean = sprintf("%.4f", $mean);
    $sd   = sprintf("%.4f", $sd);

    # Five-number summary
    my $min; my $q1; my $med; my $q3; my $max;
    my $iqr; my $range;
    my $fivenumsum = defined($options{'include5num'}) ? uc($options{'include5num'}) : "T";
    if($fivenumsum eq 'T'){
        $min = main::min(@x);
        $q1 = sprintf("%.4f", usefulstatUWL::q1(@x));
        $med = sprintf("%.4f", usefulstatUWL::med(@x));
        $q3 = sprintf("%.4f", usefulstatUWL::q3(@x));
        $max = main::max(@x);
        $iqr = $q3 - $q1;
        $range = $max - $min;
    }

    $self = bless {
        n => $n,
        x => [@x],
        mean => $mean, sd => $sd,
        min => $min, q1 => $q1, med => $med, q3 => $q3, max => $max,
        iqr => $iqr, range => $range,
        df => $df,
        skew => $skew,
        name => $name,
        datatype => $options{'datatype'},
    }, $class;
}

# Categorical methods
sub new_chi2_gof {
    my $self = shift;
    my $class = 'chi2_gof';
    my %options = @_;
    my $data = $options{'data'};

    if ($data->{'datatype'} ne "one_cat") {
        die "Error: Chi-square goodness of fit statistics should be for a single ".
            "categorical variable only";
    }

    my $n = $data->{n};
    my @nlevels = @{$data->{nlevels}};
    my $a = $nlevels[0];

    my @expecteds; my $expected; my @ratios; my $ratiotot;
    if (defined($options{'expected'})) {
        if ($options{'expected'} eq 'equal') {
            for my $i (0..($a - 1)) {
                $expected = $n / $a;
                push(@expecteds, $expected);
            }
        } else {
            @ratios = @{$options{'expected'}};
            $ratiotot = usefulstatUWL::sum(@ratios);
            foreach (@ratios) {
                $expected = $n * $_ / $ratiotot;
                push(@expecteds, $expected);
            }
        }
    } else {
        warn 'Warning: defaulting to equal expected counts per category. If this '.
             'is desired, use expected => "equal"';
        for my $i (0..($a - 1)) {
                $expected = $n / $a;
                push(@expecteds, $expected);
        }
    }

    my @freqs = @{$data->{freqs}};
    my $chi2; my $df = $a - 1;

    for my $i (0..($a - 1)) {
        $chi2 += ($freqs[$i] - $expecteds[$i])**2 / $expecteds[$i];
    }

    my $pval = main::chisqrprob($df, $chi2);

    $self = bless {
        n => $n, expected => [@expecteds],
        df => $df, chi2 => $chi2,
        pvalue => $pval,
    }, $class;
}

sub new_chi2_ind {
    my $self = shift;
    my $class = 'chi2_ind';
    my %options = @_;
    my $data = $options{'data'};

    if ($data->{'datatype'} ne "two_cat") {
        die "Error: Chi-square independence statistics should be for two ".
            "categorical variables only";
    }

    my $n = $data->{n};
    my @nlevels = @{$data->{nlevels}};
    my $a = $nlevels[0];
    my $b = $nlevels[1];

    my @expecteds; my $expected; my $rowtot; my $coltot;

    for my $i (0..($a - 1)) {
        for my $j (0..($b - 1)) {
            $rowtot = CategoricalUWL::margintotal(data=>$data, level=>($i + 1), index=>1);
            $coltot = CategoricalUWL::margintotal(data=>$data, level=>($j + 1), index=>2);
            $expected = $rowtot * $coltot / $n;
            push(@expecteds, $expected);
        }
    }

    my @freqs = @{$data->{freqs}};
    my $chi2; my $df = ($a - 1) * ($b - 1);

    for my $i (0..($a * $b - 1)) {
        $chi2 += ($freqs[$i] - $expecteds[$i])**2 / $expecteds[$i];
    }

    my $pval = main::chisqrprob($df, $chi2);

    $self = bless {
        n => $n, expected => [@expecteds],
        df => $df, chi2 => $chi2,
        pvalue => $pval,
    }, $class;
}

# Quantitative methods
sub new_1samp_t {
    my $self = shift;
    my $class = '1samp_t';
    my %options = @_;
}

sub new_2samp_t {
    my $self = shift;
    my $class = '2samp_t';
    my %options = @_;
}

sub new_pdiff_t {
    my $self = shift;
    my $class = 'pdiff_t';
    my %options = @_;
}

sub new_1wayaov_UWL{
    my $self = shift;
    my $class = '1wayaov_UWL';
    my %options = @_;

    my $factor = defined($options{'factor'}) ? $options{'factor'} : "Factor A";

    my @datasets = @{$options{'data'}};
    my $a = @datasets;
    my $data; my @sums; my @sums2; my @means; my @sds; my @ns;

    do {
        $data = shift(@datasets);
        push(@sums, usefulstatUWL::sum(@{$data->{x}}));
        push(@sums2, usefulstatUWL::sumsquare(@{$data->{x}}));
        push(@means, $data->{mean});
        push(@sds, $data->{sd});
        push(@ns, $data->{n});
    } until (@datasets == 0);

    my $N = usefulstatUWL::sum(@ns);
    my $xbartot = usefulstatUWL::sum(@sums) / $N;

    my $SSA; my $SSE;
    for my $i (0..($a - 1)) {
        $SSA += $ns[$i] * ($means[$i] - $xbartot)**2;
        $SSE += ($ns[$i] - 1) * $sds[$i]**2;
    }

    my $dfa = $a - 1;
    my $dftot = $N - 1;
    my $dfe = $dftot - $dfa;
    my $SSTot = $SSA + $SSE;

    my $MSA = $SSA / $dfa;
    my $MSE = $SSE / $dfe;
    my $F = $MSA / $MSE;

    my $pval = main::fprob($dfa, $dfe, $F);

    $self = bless {
        N => $N,
        dfa => $dfa, SSA => $SSA, MSA => $MSA, F => $F,
        dfe => $dfe, SSE => $SSE, MSE => $MSE,
        dftot => $dftot, SSTot => $SSTot,
        pvalue => $pval,
        factor => $factor,
        datatype => $options{'datatype'},
    }, $class;
}

sub new_simpreg_UWL{
    my $self = shift;
    my $class = 'simple_reg_UWL';
    my %options = @_;

    if( !defined($options{'x'}) || !defined($options{'slope'}) ||
        !defined($options{'int'}) ){
        die "Error: x, slope, and intercept must be defined";
    }

    # round the values to a specified number
    my $round = defined($options{'round'}) ? $options{'round'} : 3;

    my $b0 = $options{'int'}; my $b1 = $options{'slope'};

    my @x = @{$options{'x'}}; my $n = scalar(@x);

    for( my $i = 0; $i < $n; $i++ ){
        $x[$i] = sprintf("%.".$round."f", $x[$i]);
    }

    my $xsum = usefulstatUWL::sum(@x);
    my $x2sum = usefulstatUWL::sumsquare(@x);
    my $xbar = usefulstatUWL::mean(@x);
    my $ssx = usefulstatUWL::ss(@x);
    my $sx = usefulstatUWL::sd(@x);

    # if y is undefined generate y. by default assume assumptions are met.
    # by default use sig=1
    my $assumptions = 'SATISFIED'; my @y; my $err; my $yval;
    my $sig = defined($options{'sig'}) ? $options{'sig'} : 1;
    if( !defined($options{'y'}) ){
        $assumptions = uc($options{'assumptions'}) if defined($options{'assumptions'});
        @y = genysig($b0, $b1, $sig, [@x], $assumptions);
    } else {
        @y = @{$options{'y'}};
    }

    for( my $i = 0; $i < $n; $i++ ){
        $y[$i] = sprintf("%.".$round."f", $y[$i]);
    }

    # summaries for y
    my $ysum = usefulstatUWL::sum(@y);
    my $y2sum = usefulstatUWL::sumsquare(@y);
    my $ybar = usefulstatUWL::mean(@y);
    my $ssy = usefulstatUWL::ss(@y);
    my $sy = usefulstatUWL::sd(@y);

    my $r = usefulstatUWL::cor([@x], [@y]);
    my $rsq = $r**2;

    # estimates
    $b1 = $r * $sy / $sx;
    $b0 = $ybar - $b1 * $xbar;

    # s = sqrt(mse)
    my @res = QuantitativeUWL::findres($b0, $b1, [@x], [@y]);
    my $sse = usefulstatUWL::sumsquare(@res);
    my $mse = $sse / ($n - 2);
    my $s = sqrt($mse);

    # remaining ANOVA parts
    my $sstot = $ssy;
    my $ssm = $sstot - $sse;

    # standard errors
    my $b1se = $s / sqrt($ssx);
    my $b0se = $s * sqrt($x2sum / ($n * $ssx));

    # t-stats
    my $b1t = $b1 / $b1se;
    my $b0t = $b0 / $b0se;

    # p-values
    my $df = $n - 2;
    my $b1pval = 2 * main::tprob($df, abs($b1t));
    my $b0pval = 2 * main::tprob($df, abs($b0t));

    $self = bless {
        x => [@x], y => [@y],
        ssm => sprintf("%.".$round."f", $ssm),
        msm => sprintf("%.".$round."f", $ssm),
        residuals => [@res],
        mse => sprintf("%.".$round."f", $mse),
        s => sprintf("%.".$round."f", $s),
        sse => sprintf("%.".$round."f", $sse),
        sstot => sprintf("%.".$round."f", $sstot),
        b0 => sprintf("%.".$round."f", $b0),
        b0se => sprintf("%.".$round."f", $b0se),
        b0t => sprintf("%.".$round."f", $b0t),
        b0pval => $b0pval,
        b1 => sprintf("%.".$round."f", $b1),
        b1se => sprintf("%.".$round."f", $b1se),
        b1t => sprintf("%.".$round."f", $b1t),
        b1pval => $b1pval,
        r => sprintf("%.".$round."f", $r),
        rsq => sprintf("%.".$round."f", $rsq),
        df => $df,
        n => $n,
        datatype => $options{'datatype'},
    }, $class;
}

sub genysig { # $b0, $b1, $sig, [@x], $assumptions
    my $b0 = shift; my $b1 = shift; my $sig = shift;
    my $x_ref = shift; my @x = @{$x_ref}; my $n = scalar( @x );

    my $assumptions = uc(shift);

    my $xbar = usefulstatUWL::mean( @x );

    my @residuals = genres($n, $sig);

    my $yval; my @y;
    my $xdiff; my $xmin = main::min(@x); my $xmax = main::max(@x);
    for (my $i=0; $i < $n; $i++) {

        if ($assumptions eq "FAN") {
            $xdiff = ($x[$i] - $xmin);
            $yval = $b0 + $b1 * $x[$i] + $xdiff * $residuals[$i];
        } elsif ($assumptions eq "SQUARE") {
            $yval = $b0 + $b1 * ($x[$i] - $xbar)**2 + $residuals[$i];
        } else { # should default to meeting assumptions.
            $yval = $b0 + $b1 * $x[$i] + $residuals[$i]
        }

        push(@y, $yval);
    }

    return @y;
}

sub genres { # $n, $sig
    my $n = shift; my $sig = shift;

    my @residuals;
    for (my $i = 0; $i < $n; $i++) {
        push(@residuals, usefulstatUWL::rnorm(0, 1));
    }

    # want to ensure that R-sq matches, so let's scale residuals
    my @z = usefulstatUWL::standardize(@residuals);

    for (my $i = 0; $i < $n; $i++) {
        $residuals[$i] = $z[$i] * $sig;
    }

    return @residuals;
}


# Bootstrap Methods
sub new_bs1cat_UWL{
    my $self = shift;
    my $class = 'BootstrapUWL';
    my %options = @_;

    my $N = defined($options{'N'}) ? $options{'N'} : 1000;
    my $n; my $prob;
    my $cat; my $level; my @probs;
    if (defined($options{'nullval'})) {
        $n = $options{'n'};
        $prob = $options{'nullval'};
    } else {
        $cat = $options{'data'};
        # success_level is which proportion to use
        $level = defined($options{'success_level'}) ? ($options{'success_level'} - 1) : 0;

        $n = $cat->{n};
        @probs = @{$cat->{probs}};
        $prob = $probs[$level];  # base the bootstrap on proportion of success
    }

    my @props; my $count; my $prop;
    main::rserve_eval('samp <- rbinom(n = ' . $N . ',
                                      size = ' . $n . ',
                                      prob = ' . $prob .')');
    @props = main::rserve_eval('samp / ' . $n);

    my $mean = usefulstatUWL::mean(@props);
    my $sd = usefulstatUWL::sd(@props);
    my $name = $options{'name'};

    $self = bless {
        n => $n,
        x => [@props],
        mean => $mean, sd => $sd,
        name => $name,
        datatype => 'single_quant',  # for making histograms
    }, $class;
}

sub new_bs2cat_UWL{
    my $self = shift;
    my $class = 'BootstrapUWL';
    my %options = @_;

    my @counts;
    if(!defined($options{'counts'})){
        die 'Error: Use counts => ($count1, $count2) to indicate data for hypothesis '.
            'test.';
    } else {
        @counts = @{$options{'counts'}};
    }

    my @ns;
    if(!defined($options{'n'})){
        die 'Error: Use n => ($n1, $n2) to indicate data for hypothesis '.
            'test.';
    } else {
        @ns = @{$options{'n'}};
    }

    if (scalar(@counts) != 2 || scalar(@ns) != 2){
        die 'Error: You can only use two groups for difference in proportions '.
            'randomization hypothesis test. You have passed in '.
            scalar(@counts).' counts ('. join(", ", @counts) .') and '.scalar(@ns).
            ' group sizes ('.join(", ", @ns) .')';
    }

    my $N = defined($options{'N'}) ? $options{'N'} : 1000;
    my @samples;

    my @dataall;
    foreach (1..$counts[0]){
        push(@dataall, 1);
    }
    foreach (1..($ns[0] - $counts[0])){
        push(@dataall, 0);
    }
    foreach (1..$counts[1]){
        push(@dataall, 1);
    }
    foreach (1..($ns[1] - $counts[1])){
        push(@dataall, 0);
    }

    my $ntotal = scalar(@dataall);
    my $counttotal = usefulstatUWL::sum(@dataall);

    my $phatall = $counttotal / $ntotal;

    my $idx; # for bootstrapping in combine and shift
    my @group1; my @group2;
    my $phat1; my $phat2;

    my $method = defined($options{'method'}) ? lc($options{'method'}) : 'null';

    if ($method eq 'reallocate'){

        foreach (1..$N) {
            @perm = main::shuffle($ntotal);
            @group1 = @dataall[@perm[0..($ns[0]-1)]];
            @group2 = @dataall[@perm[$ns[0]..($ntotal-1)]];

            $phat1 = usefulstatUWL::mean(@group1);
            $phat2 = usefulstatUWL::mean(@group2);

            push(@samples, sprintf("%.4f", ($phat1 - $phat2)));
        }

    } elsif ($method eq 'resample') {
        my $u; my $tempcount;
        foreach (1..$N) {
            $tempcount = 0;
            foreach (1..$ns[0]){
                $u = main::random(0, 1, 0.0001);
                $obs = ($u < $phatall) ? 1 : 0;
                $tempcount += $obs;
            }
            $phat1 = $tempcount / $ns[0];

            $tempcount = 0;
            foreach (1..$ns[0]){
                $u = main::random(0, 1, 0.0001);
                $obs = ($u < $phatall) ? 1 : 0;
                $tempcount += $obs;
            }
            $phat2 = $tempcount / $ns[1];


            push(@samples, sprintf("%.4f", ($phat1 - $phat2)));
        }
    } else {
        die 'Error: Use method => "reallocate" or "resample" to set '.
            'randomization method.';
    }

    my $mean = usefulstatUWL::mean(@samples);
    my $sd = usefulstatUWL::sd(@samples);
    my $name = $options{'name'};

    $self = bless {
        N => $N,
        x => [@samples],
        mean => $mean, sd => $sd,
        name => $name,
        datatype => 'single_quant',  # for making histograms
    }, $class;
}

sub new_bs1samp_UWL {
    my $self = shift;
    my $class = 'BootstrapUWL';
    my %options = @_;

    my $quant = $options{'data'};
    my @x = @{$quant->{x}};
    my $nx = scalar(@x);
    # incorrect sample size (for identification purposes)
    my $n = defined($options{'n'}) ? $options{'n'} : scalar(@x);

    my @sample; my $idx;
    for my $i (1..$n) {
        $idx = main::random(0, ($nx-1), 1);
        push(@sample, $x[$idx]);
  }

    # includes values not in original sample (for identification purposes)
    my $extras = defined($options{'extras'}) ? $options{'extras'} : "F";
    my $wrong; my $inset;
    if (uc($extras) eq "T") {
        do {
            $inset = 0;
            # select a number within the range of the original data
            $wrong = main::random(main::min(@x), main::max(@x), 1);
            foreach (@x) {
                if ($wrong == $_) { $inset++; }
            }
        } until ($inset == 0);

        $idx = main::random(0, ($n-1), 1);
        $sample[$idx] = $wrong;
    }

    my $mean = usefulstatUWL::mean(@sample);
    my $sd = usefulstatUWL::sd(@sample);
    my $name = $options{'name'};

    $self = bless {
        n => $n,
        x => [@sample],
        mean => $mean, sd => $sd,
        name => $name,
        datatype => 'single_quant',  # for making histograms
    }, $class;
}

sub new_bs1mean_UWL{
    my $self = shift;
    my $class = 'BootstrapUWL';
    my %options = @_;

    my $quant = $options{'data'};

    my @x = @{$quant->{x}};
    my $n = scalar(@x);

    my $diff = 0;
    if (defined($options{'nullval'})) {
        $diff = $options{'nullval'} - $quant->{mean};
        for my $i (0..($n-1)) {
            $x[$i] += $diff;
        }
    }

    my $N = defined($options{'N'}) ? $options{'N'} : 1000;

    my $idx; my $average; my @averages;
    for my $i (1..$N) {
        $average = 0;
        foreach (@x) {
            $idx = main::random(0, ($n-1), 1);
            $average += $x[$idx] / $n;
        }

        push(@averages, $average);
    }

    my $mean = usefulstatUWL::mean(@averages);
    my $sd = usefulstatUWL::sd(@averages);
    my $name = $options{'name'};

    $self = bless {
        n => $n,
        x => [@averages],
        mean => $mean, sd => $sd,
        name => $name,
        datatype => 'single_quant',  # for making histograms
    }, $class;
}

sub new_bs2mean_UWL{
    my $self = shift;
    my $class = 'BootstrapUWL';
    my %options = @_;

    my @data;
    if (!defined($options{'data'})) {
        die 'Error: Use data => [[@x1], [@x2]] to indicate data for hypothesis '.
            'test.';
    } else {
        @data = @{$options{'data'}};
    }

    my $ngroups = @data;
    if ($ngroups != 2) {
        die 'Error: You can only use two groups for difference in averages '.
            'randomzation hypothesis test.';
    }

    my $N = defined($options{'N'}) ? $options{'N'} : 1000;
    my @samples;

    my @dataall; my @ns; my $ntotal=0;
    my $idx; # for bootstrapping in combine and shift
    my @group1; my @group2;
    my $xbar1; my $xbar2;
    my $method = defined($options{'method'}) ? lc($options{'method'}) : 'null';
    if ($method eq 'reallocate'){
        # first combine into a single array of data
        foreach $set (@data) {
            $ntotal += scalar(@{$set});
            push(@ns, scalar(@{$set}));  # retain sample size information
            push(@dataall, @{$set});
        }

        foreach (1..$N) {
            @perm = main::shuffle($ntotal);
            @group1 = @dataall[@perm[0..($ns[0]-1)]];
            @group2 = @dataall[@perm[$ns[0]..($ntotal-1)]];

            $xbar1 = usefulstatUWL::mean(@group1);
            $xbar2 = usefulstatUWL::mean(@group2);

            push(@samples, sprintf("%.4f", ($xbar1 - $xbar2)));
        }

    } elsif ($method eq 'combine') {
        # first combine into a single array of data
        foreach $set (@data) {
            $ntotal += scalar(@{$set});
            push(@ns, scalar(@{$set}));  # retain sample size information
            push(@dataall, @{$set});
        }

        foreach (1..$N) {
            foreach $groupidx (1..$ns[0]) {
                $idx = main::random(0, ($ntotal-1), 1);
                $group1[($groupidx - 1)] = $dataall[$idx];
            }
            foreach $groupidx (1..$ns[1]){
                $idx = main::random(0, ($ntotal-1), 1);
                $group2[($groupidx - 1)] = $dataall[$idx];
            }

            $xbar1 = usefulstatUWL::mean(@group1);
            $xbar2 = usefulstatUWL::mean(@group2);

            push(@samples, sprintf("%.4f", ($xbar1 - $xbar2)));
        }
    } elsif ($method eq 'shift') {
        my @x1; my @x2; my $mean1; my $mean2; my $diff;
        my @x2new;
        @x1 = @{$data[0]};
        @x2 = @{$data[1]};
        @ns = (scalar(@x1), scalar(@x2));
        $mean1 = usefulstatUWL::mean(@x1);
        $mean2 = usefulstatUWL::mean(@x2);
        $diff = $mean1 - $mean2;

        # shift it so both groups have the same mean
        foreach $obs (@x2) {
            push(@x2new, ($obs + $diff));
        }

        foreach (1..$N){
            foreach $groupidx (1..$n[0]){
                $idx = main::random(0, ($ns[0] - 1), 1);
                $group1[($groupidx - 1)] = $x1[$idx];
            }
            foreach $groupidx (1..$n[1]){
                $idx = main::random(0, ($ns[1] - 1), 1);
                $group2[($groupidx - 1)] = $x2new[$idx];
            }

            $xbar1 = usefulstatUWL::mean(@group1);
            $xbar2 = usefulstatUWL::mean(@group2);

            push(@samples, sprintf("%.4f", ($xbar1 - $xbar2)));
        }


    } else {
        die 'Error: Use method => "reallocate", "combine", or "shift" to set '.
            'randomization method.';
    }

    my $mean = usefulstatUWL::mean(@samples);
    my $sd = usefulstatUWL::sd(@samples);
    my $name = $options{'name'};

    $self = bless {
        N => $N,
        x => [@samples],
        mean => $mean, sd => $sd,
        name => $name,
        datatype => 'single_quant',  # for making histograms
    }, $class;
}

#}
1; #required at end of file - a perl thing