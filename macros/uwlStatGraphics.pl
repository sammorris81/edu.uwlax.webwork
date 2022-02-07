# uwlStatGraphics.pl

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
           "PGunion.pl",
           "RserveClient.pl"
);

sub _uwlStatGraphics_init {};

package StatGraphicsUWL;

@ISA = qw(Exporter);
@EXPORT_OK = qw(grpbarchart barchart boxplot histogram scatterplot);

sub tickmarks { #tick marks for the axes
    my @data = @_;

    my $range = main::max(@data) - main::min(@data);
    my $ticklength = 0; my $tickmult = 1;
    my $loopctr = 0;
    do {
        if ( $range <= 4 ){ $tickmult *= 0.10; $range *= 10; }
        elsif ( $range > 4  && $range <= 6  ){ $ticklength = 1 * $tickmult; }
        elsif ( $range > 6  && $range <= 12 ){ $ticklength = 2 * $tickmult; }
        elsif ( $range > 12 && $range <= 18 ){ $ticklength = 3 * $tickmult; }
        elsif ( $range > 18 && $range <= 24 ){ $ticklength = 4 * $tickmult; }
        elsif ( $range > 24 && $range <= 40 ){ $ticklength = 5 * $tickmult; }
        else { $tickmult *= 10; $range *= 0.1; }
        $loopctr ++;
        if( $loopctr > 15 ){
            die "Error: Tick length is not working. Data is ".join(", ", @data) .
                " range is $range";
        }
    } until ($ticklength != 0);

    return $ticklength;
}

sub labelround { #give labels consistent rounding
    my $ticklength = shift;
    my $labround = 0;
    my $loopctr = 0;
    while ($ticklength < 1) {

        # adjusts the rounding depending on how much smaller the ticklength is
        # than 1
        $ticklength *= 10;
        $labround ++;
        $loopctr ++;
        if ($loopctr > 10){
            die "Error: labelround is not working";
        }
    }

    return $labround;
}
# sub addLegend: make a legend

sub barchart { #index=>(1=rows, 2=cols): only necessary for two way table
    my %options = @_;
    my $self = $options{'data'};

    if (ref($self) ne 'CategoricalUWL') {
        die "Error: barcharts are only for categorical data"
    }

    my @freqs = @{$self->{freqs}};
    my @nlevels = @{$self->{nlevels}};
    my @labels = @{$self->{labels}};

    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    my $nbars; my $index;
    if( $ncols > 1 ){
        if (!exists($options{'index'})) {
            die "Error: Index must be defined for marginal groupings. Use 1 for rows ".
                "or 2 for columnns. For grouped bar charts use grpbarchart.";
        } elsif ($options{'index'} != 1 && $options{'index'} != 2) {
            die "Error: The index for the marginal groupings must either be 1 for rows ".
                "or 2 for columns.";
        } else {
            $index = $options{'index'};
        }
    } else {
        $index = 1;
    }

    $nbars = $nlevels[($index-1)];

    my @barfreqs; my @barlabels;
    if( $ncols == 1 ){
        @barfreqs = @freqs;
        @barlabels = @labels;
    } else {
        my $barfreq;
        if( $index == 1 ){ # group by rows
            for( my $i=0; $i<$nrows; $i++ ){
                $barfreq = 0;
                for( my $j=0; $j<$ncols; $j++ ){
                    $barfreq += $freqs[$i*$ncols + $j];
                }
                push(@barfreqs, $barfreq);
                push(@barlabels, $labels[$i]);
            }
        } else { # group by columns
            for( my $j=0; $j<$ncols; $j++ ){
                $barfreq = 0;
                for( my $i=0; $i<$nrows; $i++ ){
                    $barfreq += $freqs[$i*$ncols + $j];
                }
                push(@barfreqs, $barfreq);
                push(@barlabels, $labels[$nrows + $j]);
            }
        }
    }

    # define the size of the plot
    my $barspace = defined($options{'barspace'}) ? $options{'barspace'} : 0.2;
    my $barwidth = defined($options{'barwidth'}) ? $options{'barwidth'} : 1;
    my $lrmargin = defined($options{'lrmargin'}) ? $options{'lrmargin'} : 0.4;

    my $xmin = 0; my $xaxis = 0;
    my $xmax = $xmin + $lrmargin * 2 + $barwidth * $nbars + $barspace * ($nbars - 1);
    my $xrange = $xmax - $xmin;
    my $ymin = 0; my $yaxis = 0;
    my $ymax = main::max(@barfreqs);
    my $yrange = $ymax - $ymin;
    my @y = ($ymin, $ymax);

    my $xplot1 = $xmin-0.15*$xrange; my $xplot2 = $xmax;
    my $yplot1 = $ymin-0.15*$yrange; my $yplot2 = $ymax + 0.1 * $yrange;
    my $xlab = $xaxis - 0.01*$xrange; my $ylab = $yaxis - 0.01*$yrange;

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[0, 0],
        size=>[300, 300]
    );

    $gr -> lb('reset');

    my $xlabel; my $xcoord;
    for my $i (0..($nbars-1)) {
        $xcoord = $lrmargin + $barwidth * ($i + 0.5) + $barspace * $i;
        $xlabel = new Label ( $xcoord, $ylab, "$barlabels[$i]", 'black', 'center', 'top');
        $xlabel->{font} = GD::gdLargeFont;
        $gr -> lb($xlabel);
    }

    my $yticklength = tickmarks(@y);
    my $ylabel;
    my $ycoord = $yticklength; # avoid starting with 0
    do {
        $ylabel = new Label( $xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
        $ylabel->{font} = GD::gdLargeFont;
        $gr -> lb($ylabel);
        $ycoord += $yticklength;
    } until ($ycoord > $ymax);
    # add one last coord
    # $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
    # $ylabel->{font} = GD::gdLargeFont;
    # $gr -> lb($ylabel);

    # add in UWL specific colors
    @color = ("uwlred", "uwlorange", "uwlyellow", "uwlgreen", "uwlblue", "uwlpurple", "uwlbrown");
    $gr -> new_color("uwlred", 216, 39, 53);
    $gr -> new_color("uwlorange", 255, 116, 53);
    $gr -> new_color("uwlyellow", 255, 203, 53);
    $gr -> new_color("uwlgreen", 0, 158, 71);
    $gr -> new_color("uwlblue", 0, 121, 231);
    $gr -> new_color("uwlpurple", 125, 60, 181);
    $gr -> new_color("uwlbrown", 87, 65, 47);

    my $barcolor = defined($options{'color'}) ? $options{'color'} : 4;

    # make filled region for each bar
    my $xstart; my $xend; my $ystart; my $yend;
    for my $i (0..($nbars - 1)) {
        $xstart = $lrmargin + $i * $barwidth + $i * $barspace;
        $xend = $xstart + $barwidth;
        $height = $barfreqs[$i];

        $gr -> moveTo($xstart, 0);
        $gr -> lineTo($xstart, $height, "black", 1);
        $gr -> lineTo($xend, $height, "black", 1);
        $gr -> lineTo($xend, 0, "black", 1);
        $gr -> lineTo($xstart, 0, "black", 1);

        $gr -> fillRegion( [$xstart + 0.5*$barwidth, 0.5*$height, $color[$barcolor]] );
    }

    return $gr;
}

sub grpbarchart { #index=>(1=rows, 2=cols): index for group by
    my %options = @_;

    my $self = $options{'data'};

    if (ref($self) ne 'CategoricalUWL') {
        die "Error: barcharts are only for categorical data"
    }

    if ($self->{datatype} ne 'two_cat') {
        die 'Error: grpbarchart is only for two categorical variables. For a '.
            'single categorical variable, use barchart.';
    }

    my @freqs = @{$self->{freqs}};
    my @nlevels = @{$self->{nlevels}};
    my @labels = @{$self->{labels}};

    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    my $index;
    if (!defined($options{'index'}) ){
        die "Error: Index must be defined for groupings on barchart. Use 1 ".
            "for rows or 2 for columnns.";
    } elsif ( $options{'index'} != 1 && $options{'index'} != 2) {
        die "Error: The index for the groupings must either be 1 for rows ".
            "or 2 for columns.";
    } else {
        $index = $options{'index'};
    }

    my $ngrps = ($options{'index'} == 1) ? $nlevels[0] : $nlevels[1];
    my $nbars = ($options{'index'} == 1) ? $nlevels[1] : $nlevels[0];

    my @barfreqs; my @mainbarlabels; my @subbarlabels;
    if ($index == 1) {
        @barfreqs = @freqs;
        @mainbarlabels = @labels[0..($nrows - 1)];
        @subbarlabels = @labels[$nrows..($nrows + $ncols - 1)];
    } else {
        for my $i (0..($ngrps-1)) {
            for my $j (0..($nbars-1)) {
                push(@barfreqs, $freqs[$j * $ngrps + $i]);
            }
        }
        @mainbarlabels = @labels[$nrows..($nrows + $ncols - 1)];
        @subbarlabels = @labels[0..($nrows - 1)];
    }

    # warn "ngrps is $ngrps";
    # warn "nbars is $nbars";
    # warn "nrows is $nrows";
    # warn "ncols is $ncols";
    # warn "labels are ". join(", ", @labels);
    # warn "mainbarlabels are ". join(", ", @mainbarlabels);
    # warn "subbarlabels are ". join(", ", @subbarlabels);

    # debugged to here

    # define the size of the plot
    my $barspace = defined($options{'barspace'}) ? $options{'barspace'} : 0.5;
    my $barwidth = defined($options{'barwidth'}) ? $options{'barwidth'} : 1;
    my $lrmargin = defined($options{'lrmargin'}) ? $options{'lrmargin'} : 0.3;

    my $grpwidth = $barwidth * $nbars;
    my $xmin = 0; my $xaxis = 0;
    my $xmax = $xmin + $lrmargin * 2 + $grpwidth * $ngrps + $barspace * ($ngrps - 1);
    my $xrange = $xmax - $xmin;
    my $ymin = 0; my $yaxis = 0;
    my $ymax = main::max(@barfreqs);
    my $yrange = $ymax - $ymin;
    my @y = ($ymin, $ymax);

    my $xplot1 = $xmin-0.15*$xrange; my $xplot2 = $xmax;
    my $yplot1 = $ymin-0.15*$yrange; my $yplot2 = $ymax + 0.1 * $yrange + $nbars + 1;
    my $xlab = $xaxis - 0.01*$xrange; my $ylab = $yaxis - 0.01*$yrange;

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[0, 0],
        size=>[300, 300]
    );

    $gr -> lb('reset');

    my $xlabel; my $xcoord;
    for my $i (0..($ngrps - 1)) {
        $xcoord = $lrmargin + $grpwidth * ($i + 0.5) + $barspace * $i;
        $xlabel = new Label ( $xcoord, $ylab, "$mainbarlabels[$i]", 'black', 'center', 'top');
        $xlabel->{font} = GD::gdLargeFont;
        $gr -> lb($xlabel);
    }

    my $yticklength = tickmarks(@y);
    my $ylabel;
    my $ycoord = $yticklength; # avoid starting with 0
    do {
        $ylabel = new Label( $xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
        $ylabel->{font} = GD::gdLargeFont;
        $gr -> lb($ylabel);
        $ycoord += $yticklength;
    } until ($ycoord > $ymax);
    # add one last coord
    # $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
    # $ylabel->{font} = GD::gdLargeFont;
    $gr -> lb($ylabel);

    # add in UWL specific colors
    my @color;
    if ($nbars == 2) {
      @color = ("uwlred", "uwlblue");
    } elsif ($nbars == 6) {
      @color = ("uwlred", "uwlblue", "uwlyellow", "uwlpurple", "uwlgreen", "uwlorange");
    } else {
      @color = ("uwlred", "uwlyellow", "uwlblue", "uwlorange", "uwlpurple", "uwlgreen", "uwlbrown");
    }

    $gr -> new_color("uwlred", 216, 39, 53);
    $gr -> new_color("uwlorange", 255, 116, 53);
    $gr -> new_color("uwlyellow", 255, 203, 53);
    $gr -> new_color("uwlgreen", 0, 158, 71);
    $gr -> new_color("uwlblue", 0, 121, 231);
    $gr -> new_color("uwlpurple", 125, 60, 181);
    $gr -> new_color("uwlbrown", 87, 65, 47);

    # make filled region for each bar
    my $xstart; my $xend; my $ystart; my $yend;
    for my $j (0..($ngrps - 1)) {
      for my $i (0..($nbars - 1)) {
          $xstart = $lrmargin + $j * ($grpwidth + $barspace) + $i * $barwidth;
          $xend = $xstart + $barwidth;
          $height = $barfreqs[$j * $nbars + $i];

          $gr -> moveTo($xstart, 0);
          $gr -> lineTo($xstart, $height, "black", 1);
          $gr -> lineTo($xend, $height, "black", 1);
          $gr -> lineTo($xend, 0, "black", 1);
          $gr -> lineTo($xstart, 0, "black", 1);

          $gr -> fillRegion( [$xstart + 0.5*$barwidth, 0.5*$height, $color[$i % 7]] );
      }
    }

    my $leglabel;
    for my $i (0..($nbars - 1)) {
        $xstart = $lrmargin;
        $xend = $xstart + $barspace;
        $ystart = $ymax + 1 + ($nbars - $i) + 0.1;  # add a little padding above graph
        $yend = $ystart + 0.8;

        $gr -> moveTo($xstart, $ystart, "black", 1);
        $gr -> lineTo($xstart, $yend, "black", 1);
        $gr -> lineTo($xend, $yend, "black", 1);
        $gr -> lineTo($xend, $ystart, "black", 1);
        $gr -> lineTo($xstart, $ystart, "black", 1);

        $gr -> fillRegion( [$xstart + 0.5 * $barspace, $ystart + 0.5, $color[$i % 7]] );

        $xcoord = $xstart + $barspace + 0.1;
        $ycoord = $yend - 0.4;
        $leglabel = new Label( $xcoord, $ycoord, "$subbarlabels[$i]", 'black', 'left', 'middle');
        $leglabel->{font} = GD::gdLargeFont;
        $gr -> lb($leglabel);
    }

    # warn "legend_length is $legend_length";

    return $gr;
}

sub dotplot {  # not done yet - uninitialized nobs (line 471)
    my %options = @_;

    my $self = $options{'data'};
    if ($self->{datatype} ne 'single_quant') {
        die 'Error: dotplot is for a single quantitative variable only.';
    }

    my @x = @{$self->{x}};

    my $n = scalar(@x);

    my $xmin = main::min(@x); my $xmax = main::max(@x);
    my $xrange = $xmax - $xmin;

    my $xticklength;
    if (defined($options{'xticklength'})) {
        $xticklength = $options{'xticklength'};
    } elsif (defined($options{'xmin'}) && defined($options{'xmax'})) {
        $xticklength = tickmarks($options{'xmin'}, $options{'xmax'});
    } else {
        $xticklength = tickmarks(@x);
    }

    my $xlabround = defined($options{'xlabround'}) ? $options{'xlabround'} : labelround($xticklength);
    $xticklength = sprintf("%.".$xlabround."f", $xticklength);  # more for if user defined

    my $xminplot; my $xmaxplot;
    if (defined($options{'xmin'})) {
        # rounding to something reasonable
        $xminplot = sprintf("%.".$xlabround."f", $options{'xmin'});
    } else {
        $xminplot = main::floor($xmin) - 2;
    }
    if (defined($options{'xmax'})) {
        # rounding to something reasonable
        $xmaxplot = sprintf("%.".$xlabround."f", $options{'xmax'});
    } else {
        $xmaxplot = main::ceil($xmax) + 2;
    }
    my $xrangeplot = $xmaxplot - $xminplot;

    # by default make numbers show up every 5 unless they should be closer together.
    my $xlabdiff; my $xlaboffset;
    if ($xrangeplot % 4 == 0) {
      $xlabdiff = 4;
      $xlaboffset = 0;
    } elsif (($xrangeplot - 2) % 4 == 0) {
      $xlabdiff = 4;
      $xlaboffset = 1;
    } elsif ($xrangeplot % 3 == 0) {
      $xlabdiff = 3;
      $xlaboffset = 0;
    } elsif (($xrangeplot - 2) % 3 == 0) {
      $xlabdiff = 3;
      $xlaboffset = 1;
    } else {
      $xlabdiff = 3;
      $xlaboffset = 2;
    }

    my @binfreqs; my $binfreqidx;
    foreach $obs ( @x ){
        $binfreqidx = sprintf("%.0f", $obs) - $xminplot;
        $binfreqs[$binfreqidx] += 1;
    }

    for my $i (0..@binfreqs) {
        $binfreqs[$i] = defined($binfreqs[$i]) ? $binfreqs[$i] : 0;
    }

    my $ymin = 0; my $ymax = main::max(@binfreqs); my $yrange = $ymax - $ymin;

    my $xplot1 = $xminplot - 0.25 * $xrangeplot;
    my $xplot2 = $xmaxplot + 0.1 * $xrangeplot;
    my $yplot1 = $ymin - 0.15 * $yrange; my $yplot2 = $ymax + 0.1 * $yrange;
    my $xaxis = $xminplot - 0.1 * $xrangeplot; my $yaxis = 0;
    my $xlab = $xaxis - 0.04*$xrangeplot; my $ylab = $yaxis - 0.01*$yrange;

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[$xaxis, $yaxis],
        size=>[300, 300]
    );

    $gr -> lb('reset');

    my $xlabel;
    my $xcoord = $xminplot;

    do {  # $xlabdiff tells when to put a number
        if (($xcoord - $xlaboffset - $xminplot) % $xlabdiff == 0) {
          $xcoord = sprintf("%.".$xlabround."f", $xcoord);
          $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
          $xlabel->{font} = GD::gdSmallFont;
          $gr -> lb($xlabel);
        }

        $gr -> moveTo($xcoord, (-0.01 * $yrange), "black", 1);
        $gr -> lineTo($xcoord, (0.01 * $yrange), "black", 1);

        $xcoord += $xticklength;
    } until ($xcoord > $xmaxplot);
    # add one last coord
    # $xcoord = sprintf("%.".$xlabround."f", $xcoord);
    # $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
    # $xlabel->{font} = GD::gdSmallFont;
    # $gr -> lb($xlabel);

    my $ysub; my $axislabel; my $xmid = ($xminplot + $xmaxplot) / 2;
    if (defined($self->{name})) {
        $ysub = $yaxis - 0.08 * $yrange;
        $axislabel = new Label ($xmid, $ysub, "$self->{name}", 'black', 'center', 'middle');
        #$axislabel->{font} = GD::gdLargeFont;
        $gr -> lb($axislabel);
    }

    my $yticklength = tickmarks(@binfreqs);

    my $ylabel;
    my $ycoord = $yticklength; # avoid starting with 0
    do {
        $ylabel = new Label( $xlab, ($ycoord - 0.5), "$ycoord", 'black', 'right', 'middle');
        $ylabel->{font} = GD::gdSmallFont;
        $gr -> lb($ylabel);

        $gr -> moveTo((-0.01 * $xrangeplot + $xaxis), ($ycoord - 0.5), "black", 1);
        $gr -> lineTo((0.01 * $xrangeplot + $xaxis), ($ycoord - 0.5), "black", 1);

        $ycoord += $yticklength;
    } until ($ycoord > $ymax);
    # add one last coord
    # $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
    # $ylabel->{font} = GD::gdLargeFont;
    # $gr -> lb($ylabel);

    my $nobs; $binfreqidx = 0; my $height = 0;
    my $xstart = $xminplot; my $xcirc;
    do {
        $nobs = defined($binfreqs[$binfreqidx]) ? $binfreqs[$binfreqidx] : 0;
        $xcirc = $xminplot + $binfreqidx;
        if( $nobs > 0 ){
            $height = 0;  # reset height of the dots
            for my $i (0..($nobs - 1)){
                $gr -> stamps( main::open_circle($xcirc, ($i + 0.5)));
            }
        }
        $binfreqidx ++;

    } until ($binfreqidx > $xrangeplot);

    return $gr;
}

sub histogram_old { # binrule => "sturges", summaries => "F", round=>3
    my %options = @_;

    my $self = $options{'data'};
    if ($self->{datatype} ne 'single_quant') {
        die 'Error: histogram is for a single quantitative variable only.';
    }

    my @x = @{$self->{x}};

    my $n = scalar(@x);

    my $xmin = main::min(@x); my $xmax = main::max(@x);
    my $q1 = usefulstatUWL::q1(@x); my $q3 = usefulstatUWL::q3(@x);
    my $iqr = $q3 - $q1;
    my $xrange = $xmax - $xmin;
    my $mean = usefulstatUWL::mean(@x);
    my $sd = usefulstatUWL::sd(@x);

    my $nbins; my $optbinwidth; my $index;
    my $binrule = defined($options{'breaks'}) ? lc($options{'breaks'}) : 'sturges';
    my $round = defined($options{'round'}) ? $options{'round'} : 3;

    if( $binrule eq 'sturges' ){
        $nbins = 1 + main::ln($n) / main::ln(2);
        $nbins = main::floor($nbins) - 2;
        $optbinwidth = $xrange / $nbins;
    } elsif ( $binrule eq 'fd' ){
        $optbinwidth = 2 * $iqr * $n ** (-1/3);
    } elsif ($binrule eq 'scott' ){
        $optbinwidth = 3.5 * $sd * $n ** (-1/3);
    } elsif ($binrule eq 'fixed' ){
        if( !defined($options{'nbins'}) ){
            die "Error: You must specify the number of bins when using fixed. ".
                "Otherwise select from sturges, fd, or scott";
        } else {
            $nbins = $options{'nbins'} - 2; # we add in start and ending bins when drawing
            $optbinwidth = $xrange / $nbins;
        }
    }

    my $xticklength;
    if (defined($options{'xticklength'})) {
        $xticklength = $options{'xticklength'};
    } elsif (defined($options{'xmin'}) && defined($options{'xmax'})) {
        $xticklength = tickmarks($options{'xmin'}, $options{'xmax'});
    } else {
        $xticklength = tickmarks(@x);
    }

    my $xlabround = defined($options{'xlabround'}) ? $options{'xlabround'} : labelround($xticklength);
    $xticklength = sprintf("%.".$xlabround."f", $xticklength);  # more for if user defined

    my $nbinspertick = main::ceil($xticklength / $optbinwidth);
    my $binwidth = $xticklength / $nbinspertick;

    my $xminplot; my $xmaxplot;
    if (defined($options{'xmin'})) {
        # rounding to something reasonable
        $xminplot = sprintf("%.".$xlabround."f", $options{'xmin'});
    } else {
        $xminplot = main::floor($xmin / $xticklength) * $xticklength;
    }
    if (defined($options{'xmax'})) {
        # rounding to something reasonable
        $xmaxplot = sprintf("%.".$xlabround."f", $options{'xmax'});
    } else {
        $xmaxplot = main::ceil($xmax / $xticklength) * $xticklength;
    }
    my $xrangeplot = $xmaxplot - $xminplot;

    my $bininit = main::floor(($xmin - $xminplot) / $binwidth) * $binwidth + $xminplot;

    my @binfreqs; my $binfreqidx;
    foreach $obs ( @x ){
        $binfreqidx = main::floor( ($obs - $bininit) / $binwidth );
        $binfreqs[$binfreqidx] += 1;
    }
    for my $i (0..@binfreqs) {
        $binfreqs[$i] = defined($binfreqs[$i]) ? $binfreqs[$i] : 0;
    }

    my $ymin = 0; my $ymax = main::max(@binfreqs); my $yrange = $ymax - $ymin;

    my $xplot1 = $xminplot - 0.25 * $xrangeplot;
    my $xplot2 = $xmaxplot + 0.1 * $xrangeplot;
    my $yplot1 = $ymin - 0.15 * $yrange; my $yplot2 = $ymax + 0.1 * $yrange;
    my $xaxis = $xminplot - 0.1 * $xrangeplot; my $yaxis = 0;
    my $xlab = $xaxis - 0.01*$xrangeplot; my $ylab = $yaxis - 0.01*$yrange;

    my $summaryleg = defined($options{'summaries'}) ? uc($options{'summaries'}) : "F";
    my $xmain; my $ymain; my $main; my $sub1; my $sub2;
    if( $summaryleg eq 'T' ){
        $xmain = $xaxis + 0.05 * $xrange;
        $yplot2 += 0.15 * $yrange;
        $ymain = $yplot2 - 0.05 * $yrange;
        $main = "mean = ".sprintf("%.".$round."f", $mean);
        $sub1 = "st.dev = ".sprintf("%.".$round."f", $sd);
        $sub2 = '# samples = '. @x;
    }

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[$xaxis, $yaxis],
        size=>[300, 300]
    );

    $gr -> lb('reset');

    if( $summaryleg eq 'T' ){
        my $title = new Label ($xmain, $ymain, "$main", 'black', 'left', 'top');
        $title->{font} = GD::gdSmallFont;
        $gr -> lb($title);
        $title = new Label ($xmain, $ymain, "$sub1", 'black', 'left');
        $title->{font} = GD::gdSmallFont;
        $title->{tb_nudge} = 1;
        $gr -> lb($title);
        $title = new Label ($xmain, $ymain, "$sub2", 'black', 'left');
        $title->{font} = GD::gdSmallFont;
        $title->{tb_nudge} = 2;
        $gr -> lb($title);
    }

    my $xlabel;
    my $xcoord = $xminplot;

    do {
        $xcoord = sprintf("%.".$xlabround."f", $xcoord);
        $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
        $xlabel->{font} = GD::gdSmallFont;
        $gr -> lb($xlabel);
        $xcoord += $xticklength;
    } until ($xcoord > $xmaxplot);
    # add one last coord
    # $xcoord = sprintf("%.".$xlabround."f", $xcoord);
    # $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
    # $xlabel->{font} = GD::gdSmallFont;
    # $gr -> lb($xlabel);

    my $ysub; my $axislabel; my $xmid = ($xminplot + $xmaxplot) / 2;
    if (defined($self->{name}) || defined($options{'name'})) {
        my $xlabname = defined($options{'name'}) ? $options{'name'} : $self->{name};
        $ysub = $yaxis - 0.08 * $yrange;
        $axislabel = new Label ($xmid, $ysub, "$xlabname", 'black', 'center', 'middle');
        #$axislabel->{font} = GD::gdLargeFont;
        $gr -> lb($axislabel);
    }


    my $binstart = $bininit; my $binend;
    $binfreqidx = 0;
    do {
        $binend = $binstart + $binwidth;
        if( defined($binfreqs[$binfreqidx]) ){
            $height = $binfreqs[$binfreqidx];
            $gr -> moveTo($binstart, 0);
            $gr -> lineTo($binstart, $height, "black", 1);
            $gr -> lineTo($binend, $height, "black", 1);
            $gr -> lineTo($binend, 0, "black", 1);
            $gr -> lineTo($binstart, 0, "black", 1);
        }
        $binfreqidx ++;
        $binstart = $binend; # to restart the loop

    } until ($binstart > $xmax);

    my $yticklength = tickmarks(@binfreqs);

    my $ylabel;
    my $ycoord = $yticklength; # avoid starting with 0
    do {
        $ylabel = new Label( $xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
        $ylabel->{font} = GD::gdSmallFont;
        $gr -> lb($ylabel);
        $ycoord += $yticklength;
    } until ($ycoord > $ymax);
    # add one last coord
    # $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
    # $ylabel->{font} = GD::gdLargeFont;
    # $gr -> lb($ylabel);

    return $gr;
}

sub histogram { # binrule => "sturges", summaries => "F", round=>3
    my %options = @_;

    my $self = $options{'data'};
    if ($self->{datatype} ne 'single_quant') {
        die 'Error: histogram is for a single quantitative variable only.';
    }

    my @x = @{$self->{x}};
    my $round = defined($options{'round'}) ? $options{'round'} : 3;
    my $summaryleg = defined($options{'summaries'}) ? uc($options{'summaries'}) : "F";
    my $xmin = defined($options{'xmin'}) ? $options{'xmin'} : "NULL";
    my $xmax = defined($options{'xmax'}) ? $options{'xmax'} : "NULL";


    my $xvec = "c(" . join(", ", @x) . ")";
    main::rserve_eval('xvec <- ' . $xvec);
    if ($xmin eq "NULL") {
        main::rserve_eval('xmin <- min(xvec)');
    } else {
        main::rserve_eval('xmin <- ' . $xmin);
    }
    if ($xmax eq "NULL") {
        main::rserve_eval('xmax <- max(xvec)');
    } else {
        main::rserve_eval('xmax <- ' . $xmax);
    }
    main::rserve_eval('xmin <- xmin - (xmax - xmin) * 0.05');
    main::rserve_eval('xmax <- xmax + (xmax - xmin) * 0.05');


    my $width = defined($options{'width'}) ? $options{'width'} : 300;
    my $height = defined($options{'height'}) ? $options{'height'} : 300;

    my $title = defined($options{'main'}) ? $options{'main'} :
                "Histogram of ". $self->{name};
    my $xlab = defined($options{'xlab'}) ? $options{'xlab'} : "";
    my $ylab = defined($options{'ylab'}) ? $options{'ylab'} : "";

    my $img = main::rserve_start_plot('png', $width, $height);
    if ($xlab eq "" && $ylab eq "" && $summaryleg eq "F") {
        main::rserve_eval('par(mar = c(2.2, 2.2, 3, 1) + 0.1)');
    } elsif ($xlab eq "" && $ylab eq "" && $summaryleg eq "T") {
        main::rserve_eval('par(xpd = TRUE, mar = c(2.2, 2.2, 3, 1) + 0.1)');
    }


    if ($summaryleg eq "T") {
        main::rserve_eval('xmax <- xmax + (xmax - xmin) * 0.4');
    }

    main::rserve_eval('hist(xvec, main = "' . $title . '",
                       xlab = "' . $xlab . '", ylab = "' . $ylab . '",
                       xlim = c(xmin, xmax))');
    if ($summaryleg eq "T") {
      main::rserve_eval('text(par("usr")[2], par("usr")[4],
                        paste("\n \n",
                            "# samples =", length(xvec), "\r
                            mean =", round(mean(xvec), ' . $round . '), "\r
                            std. error =", round(sd(xvec), '  . $round . ')
                        ),
                        adj = 1)');
      # main::rserve_eval('legend = c(paste("mean = ", round(mean(xvec), ' . $round . ')),
      #              paste("st. error. = ", round(sd(xvec), ' . $round . ')),
      #              paste("# samples = ", length(xvec))
      #              ),
      #   xjust=1, yjust = 1, xpd = TRUE

      #   )');
    }

    our $gr = main::rserve_finish_plot($img);


    return $gr;
}

sub boxplot {
    my %options = @_;

    my @datasets;
    if(!defined($options{'data'})){
        die 'Error: Use data => ($quant1, $quant2) to indicate data for boxplot';
    } else {
        # @data is an array of arrays
        @datasets = @{$options{'data'}};
    }

    my $ngroups = @datasets;

    # my @boxlabels;
    # if( defined($options{'names'}) ){
    #     @boxlabels = @{$options{'names'}};
    # } else {
    #     for my $i (1..@data){
    #         push(@boxlabels, "Group $i");
    #     }
    # }

    my @x; my @allx;
    my $q1; my $q3; my $iqr;
    my @mins; my @q1s; my @meds; my @q3s; my @maxs;
    my @outliers; my @nsoutliers; my $noutliers;
    my $lowerout; my $upperout;
    my $xlinemin; my $xlinemax;
    my @xlinemins; my @xlinemaxs;
    my @boxloabels; my $boxlabel;

    do {
        $data = shift(@datasets);
        @x = @{$data->{x}};
        $q1 = $data->{q1};
        $med = $data->{med};
        $q3 = $data->{q3};
        $iqr = $q3 - $q1;
        $lowerout = $q1 - 1.5 * $iqr;
        $upperout = $q3 + 1.5 * $iqr;
        $boxlabel = $data->{name};

        #outlier stuff
        $xlinemin = $med;
        $xlinemax = $med;

        $noutliers = 0;
        foreach $obs (@x){
            if($obs > $upperout || $obs < $lowerout){
                push(@outliers, $obs);
                $noutliers ++;
            } else {
                $xlinemin = main::min($obs, $xlinemin);
                $xlinemax = main::max($obs, $xlinemax);
            }
        }

        push(@mins, $data->{min});
        push(@q1s, $q1);
        push(@meds, $med);
        push(@q3s, $q3);
        push(@maxs, $data->{max});
        push(@allx, @x);
        push(@boxlabels, $boxlabel);
        push(@nsoutliers, $noutliers);

        push(@xlinemins, $xlinemin);
        push(@xlinemaxs, $xlinemax);

    } until (@datasets == 0);

    # define the size of the plot
    my $boxspace = defined($options{'boxspace'}) ? $options{'boxspace'} : 0.3;
    my $boxheight = defined($options{'boxheight'}) ? $options{'boxheight'} : 1;
    my $tbmargin = defined($options{'tbmargin'}) ? $options{'tbmargin'} : 0.4;

    my $xmin = main::min(@mins);
    my $xmax = main::max(@maxs);
    my $xrange = $xmax - $xmin;

    my $ymin = 0; my $yaxis = 0;
    my $ymax = $ymin + $tbmargin * 2 + $boxheight * $ngroups + $boxspace * ($ngroups - 1);
    my $yrange = $ymax - $ymin;

    my $xticklength = tickmarks(@allx);

    my $labelpush = main::max(scalar(@boxlabels)) * 0.5 * $xticklength;

    my $xplot1 = $xmin - 0.25 * $xrange - $labelpush; my $xplot2 = $xmax + 0.1 * $xrange;
    my $yplot1 = $ymin - 0.15 * $yrange; my $yplot2 = $ymax;
    my $xlab = $xmin - 0.2 * $xrange; my $ylab = $yaxis - 0.01*$yrange;
    my $xaxis = $xplot1 - 0.1 * $xrange;

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[$xaxis, $yaxis],
        size=>[300, 300]
    );

    $gr -> lb('reset');

    my $xlabel;
    my $xstart = main::floor($xmin / $xticklength) * $xticklength;
    my $xcoord = $xstart;
    do {
        $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
        $xlabel->{font} = GD::gdLargeFont;
        $gr -> lb($xlabel);
        $xcoord += $xticklength;
    } until ($xcoord > $xmax);

    # add one last coord
    $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
    $xlabel->{font} = GD::gdLargeFont;
    $gr -> lb($xlabel);

    my $yupper = $ymax - $tbmargin; my $ymid; my $ylower;
    my $xminplot; my $xq1plot; my $xmedplot; my $xq3plot; my $xmaxplot;
    my @outliersplot; my $outlierplot; my $ylabel; my $coord;
    for my $i (0..($ngroups - 1)){
        $xminplot = $xlinemins[$i];
        $xq1plot = $q1s[$i];
        $xmedplot = $meds[$i];
        $xq3plot = $q3s[$i];
        $xmaxplot = $xlinemaxs[$i];

        $ymid = $yupper - 0.5 * $boxheight;
        $ylower = $yupper - $boxheight;

        # lower whisker
        $gr -> moveTo($xminplot, $ymid);
        $gr -> lineTo($xq1plot, $ymid, "black", 1);

        # middle box
        $gr -> moveTo($xq1plot, $ylower);
        $gr -> lineTo($xq1plot, $yupper, "black", 1);
        $gr -> lineTo($xq3plot, $yupper, "black", 1);
        $gr -> lineTo($xq3plot, $ylower, "black", 1);
        $gr -> lineTo($xq1plot, $ylower, "black", 1);

        # median line
        $gr -> moveTo($xmedplot, $ylower);
        $gr -> lineTo($xmedplot, $yupper, "black", 1);

        # upper whisker
        $gr -> moveTo($xq3plot, $ymid);
        $gr -> lineTo($xmaxplot, $ymid, "black", 1);

        # outliers
        for my $j (0..($nsoutliers[$i] - 1)) {
            $xoutplot = shift(@outliers);
            $outlierplot = new Label ( $xoutplot, $ymid, '*', 'black', 'center', 'middle');
            $outlierplot->{font} = GD::gdLargeFont;
            $gr -> lb($outlierplot);
        }

        # y labels
        $ylabel = new Label ( $xlab, $ymid, "$boxlabels[$i]", 'black', 'center', 'middle');
        $ylabel->{font} = GD::gdLargeFont;
        $gr -> lb($ylabel);

        $yupper -= $boxspace + $boxheight;
    }

    return $gr;
}

# sub dotplot {
#     return ("Work in progress");
# }

sub scatterplot {
    my %options = @_;

    my $self = $options{'data'};
    if ($self->{datatype} ne 'simp_reg') {
        die 'Error: scatterplot is for a simp_reg variable only.';
    }

    my $b0 = $self->{b0}; my $b1 = $self->{b1};
    my @x = @{$self->{x}}; my @y = @{$self->{y}};
    my $n = scalar(@x);

    my $xmin = main::min(@x); my $xmax = main::max(@x);
    my $ymin = main::min(@y); my $ymax = main::max(@y);

    # information about x scale/axis
    my $xticklength;
    if (defined($options{'xticklength'})) {
        $xticklength = $options{'xticklength'};
    } elsif (defined($options{'xmin'}) && defined($options{'xmax'})) {
        $xticklength = tickmarks($options{'xmin'}, $options{'xmax'});
    } else {
        $xticklength = tickmarks(@x);
    }

    my $xlabround = defined($options{'xlabround'}) ? $options{'xlabround'} : labelround($xticklength);
    $xticklength = sprintf("%.".$xlabround."f", $xticklength);  # more for if user defined

    my $xminplot; my $xmaxplot;
    if (defined($options{'xmin'})) {
        # rounding to something reasonable
        $xminplot = sprintf("%.".$xlabround."f", $options{'xmin'});
    } else {
        $xminplot = main::floor($xmin / $xticklength) * $xticklength;
    }
    if (defined($options{'xmax'})) {
        # rounding to something reasonable
        $xmaxplot = sprintf("%.".$xlabround."f", $options{'xmax'});
    } else {
        $xmaxplot = main::ceil($xmax / $xticklength) * $xticklength;
    }
    my $xrangeplot = $xmaxplot - $xminplot;

    # information about y scale/axis
    my $yticklength;
    if (defined($options{'yticklength'})) {
        $yticklength = $options{'yticklength'};
    } elsif (defined($options{'ymin'}) && defined($options{'ymax'})) {
        $yticklength = tickmarks($options{'ymin'}, $options{'ymax'});
    } else {
        $yticklength = tickmarks(@y);
    }

    my $ylabround = defined($options{'ylabround'}) ? $options{'ylabround'} : labelround($yticklength);
    $yticklength = sprintf("%.".$ylabround."f", $yticklength);  # more for if user defined

    my $yminplot; my $ymaxplot;
    if (defined($options{'ymin'})) {
        # rounding to something reasonable
        $yminplot = sprintf("%.".$ylabround."f", $options{'ymin'});
    } else {
        $yminplot = main::floor($ymin / $yticklength) * $yticklength;
    }
    if (defined($options{'ymax'})) {
        # rounding to something reasonable
        $ymaxplot = sprintf("%.".$ylabround."f", $options{'ymax'});
    } else {
        $ymaxplot = main::ceil($ymax / $yticklength) * $yticklength;
    }
    my $yrangeplot = $ymaxplot - $yminplot;

    # parameters for the plot
    my $xplot1 = $xminplot - 0.25 * $xrangeplot;
    my $xplot2 = $xmaxplot + 0.1 * $xrangeplot;
    my $xaxis = $xminplot - 0.1 * $xrangeplot;
    my $xlab = $xaxis - 0.01 * $xrangeplot;

    my $yplot1 = $yminplot - 0.25 * $yrangeplot;
    my $yplot2 = $ymaxplot + 0.1 * $yrangeplot;
    my $yaxis = $yminplot - 0.1 * $yrangeplot;
    my $ylab = $yaxis - 0.01 * $yrangeplot;

    # set length of tickmarks
    my $xtickstart = $xaxis - 0.01 * $xrangeplot;
    my $xtickend = $xaxis + 0.01 * $xrangeplot;
    my $ytickstart = $yaxis - 0.01 * $yrangeplot;
    my $ytickend = $yaxis + 0.01 * $yrangeplot;

    my $gr;
    $gr = main::init_graph($xplot1, $yplot1, $xplot2, $yplot2,
        axes=>[$xaxis, $yaxis],
        size=>[300, 300],
    );

    $gr -> lb('reset');

    my $xstart = main::ceil($xaxis / $xticklength) * $xticklength;

    my $xlabel; my $xcoord = $xstart;
    do{
        $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
        $xlabel->{font} = GD::gdSmallFont;
        $gr -> lb($xlabel);
        # add in ticks on axis
        $gr -> moveTo($xcoord, $ytickstart);
        $gr -> lineTo($xcoord, $ytickend, "black", 1);
        $xcoord += $xticklength;
    } until ($xcoord > $xmaxplot);

    # add one last coord
    # $xlabel = new Label ($xcoord, $ylab, "$xcoord", 'black', 'center', 'top');
    # $xlabel->{font} = GD::gdSmallFont;
    # $gr -> lb($xlabel);
    # $gr -> moveTo($xcoord, $ytickstart);
    # $gr -> lineTo($xcoord, $ytickend, "black", 1);

    my $ystart = main::ceil($yaxis / $yticklength) * $yticklength;

    my $ylabel; my $ycoord = $ystart;
    do {
        $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
        $ylabel->{font} = GD::gdSmallFont;
        $gr -> lb($ylabel);
        $gr -> moveTo($xtickstart, $ycoord);
        $gr -> lineTo($xtickend, $ycoord, "black", 1);
        $ycoord += $yticklength;
    } until ($ycoord > $ymaxplot);

    # add one last coord
    # $ylabel = new Label ($xlab, $ycoord, "$ycoord", 'black', 'right', 'middle');
    # $ylabel->{font} = GD::gdSmallFont;
    # $gr -> lb($ylabel);
    # $gr -> moveTo($xtickstart, $ycoord);
    # $gr -> lineTo($xtickend, $ycoord, "black", 1);

    my $circle_object;
    for( my $i=0; $i < $n; $i++ ){
        $circle_object = new Circle ($x[$i], $y[$i], 3, 'black', 'black');
        $gr -> stamps($circle_object);
    }

    if (defined($self->{line})) {
        if (uc($self->{line}) eq "INCLUDE") {
            my $reg; my $xrangemin = $xmin - 0.05*$xrange; my $xrangemax = $xmax + 0.05*$xrange;
            $reg = "$b0 + $b1 * x for x in <$xrangemin,$xrangemax> using color:blue and weight:2";
            main::add_functions($gr, $reg);
        }
    }

    return $gr;
}

1; #required at end of file - a perl thing