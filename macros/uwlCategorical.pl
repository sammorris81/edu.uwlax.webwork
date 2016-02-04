# categorical_UWL.pl

# only load in the macros that don't already exist
if (!defined(&_parserRadioButtons_init)) {
  loadMacros("parserRadioButtons.pl");
}

if (!defined(&_unionTables_init)) {
  loadMacros("unionTables.pl");
}

if (!defined(&_uwlUsefulStats_init)) {
  loadMacros("uwlUsefulStats.pl");
}

# PG macros shouldn't reload by default if they're already loaded
loadMacros("PGgraphmacros.pl",
           "PGstandard.pl",
           "PGstatisticsmacros.pl",
           "PGunion.pl",
);

sub _uwlCategorical_init { };

package CategoricalUWL;
@ISA = qw(Value::String);

=pod

=cut

sub freqtable {
    my %options = @_;
    my $self = $options{'data'};
    my @freqs = @{$self->{freqs}}; my @labels = @{$self->{labels}};
    my @nlevels = @{$self->{nlevels}};
    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};
    my @rowheads; my $rowhead;
    my @colheads; my $colhead;

    for( my $i=0; $i<$nrows; $i++ ){
        push(@rowheads, $labels[$i]);
    }
    if( scalar(@nlevels) == 1 ){
        push(@colheads, "");
        push(@colheads, "Freq");
    } else {
        push(@colheads, "");
        my $collabel;
        for( my $i=0; $i<$ncols; $i++ ){
            $collabel = $nlevels[0] + $i;
            push(@colheads, $labels[$collabel]);
        }
        push(@colheads, "Total");
    }

    my @coltotals;
    for( my $i=0; $i<$ncols; $i++ ){
        push(@coltotals, 0)
    }

    if (!defined($options{'transpose'})) {
        $options{'transpose'} = "N";
    }
    my @colheadstmp; my @rowheadstmp; my $nrowstmp; my $ncolstmp;
    if (defined($options{'transpose'})) {
    if ((uc($options{'transpose'}) eq "Y") && ($self->{datatype} eq 'one_cat')) {
       @colheadstmp = @colheads; @rowheadstmp = @rowheads;
       @colheads = @rowheadstmp; @rowheads = @colheadstmp;
       unshift(@colheads, ""); push(@colheads, "Total");
       $rowheads[0] = "Freq";
       $nrowstmp = $nrows; $ncolstmp = $ncols;
       $nrows = $ncolstmp; $ncols = $nrowstmp;
    } }

    $table = main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
    $table .= main::AlignedRow([@colheads], align=>"CENTER", valign=>"MIDDLE", separation=>0);

    for( my $i=0; $i<$nrows; $i++ ){
        my @rowentries;
        for( my $j=0; $j<$ncols; $j++ ){
             push(@rowentries, $freqs[$i*$ncols + $j]);
             $coltotals[$j] += $freqs[$i*$ncols + $j];
        }
        if( $ncols > 1 ){ # add column for totals if two-way table
            push(@rowentries, usefulstatUWL::sum(@rowentries));
        }
        unshift(@rowentries, $rowheads[$i]);
        $table .= main::AlignedRow([@rowentries], align=>"CENTER", valign=>"MIDDLE", separation=>0);
    }

    # Fill in the totals row for the table
    if (($ncols > 1) && ($self->{datatype} ne 'one_cat')) {
        push(@coltotals, usefulstatUWL::sum(@coltotals));
    }
    if (defined($options{'transpose'})) {
    if (uc($options{'transpose'}) ne 'Y') {  # don't want a totals row if transposed one_cat
        unshift(@coltotals, "Total");
        $table .= main::AlignedRow([@coltotals], align=>"CENTER", valign=>"MIDDLE", separation=>0);
    }
    }
    $table .= main::EndTable();
    return($table);
}

sub singlefreq { #row, col
    my %options = @_;
    my $self = $options{'data'};

    # die "row is $options{'row'}";
    my $row; my $col;
    if ($self->{datatype} eq 'chi2_gof') {
        if (!exists $options{'row'}) {
            die "Error: you must specify a row to use singlefreq with datatype ".
                "chi2_gof";
        } else {
            $row = $options{'row'};
            $col = 1;
        }
    } elsif ($self->{datatype} eq 'chi2_ind') {
        if (!exists $options{'row'} || !exists $options{'col'}) {
            die "Error: you must specify both a row and a col to use singlefreq ".
                "with datatype chi2_ind";
        } else {
            $row = $options{'row'};
            $col = $options{'col'};
        }
    } elsif ($self->{datatype} eq 'two_cat') {
        if (!exists $options{'row'} || !exists $options{'col'}) {
            die "Error: you must specify both a row and a col to use singlefreq ".
                "with datatype two_cat";
        } else {
            $row = $options{'row'};
            $col = $options{'col'};
        }
    } elsif ($self->{datatype} eq 'one_cat') {
        if (!exists $options{'row'}) {
            die "Error: you must specify a row to use single freq with datatype ".
                "with datatype one_cat";
        } else {
            $row = $options{'row'};
            $col = 1;
        }
    }

    my @freqs = @{$self->{freqs}};
    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    if ($row > $nrows || $col > $ncols) {
        die "Error: there are only $nrows rows and $ncols cols in this table. the ".
            "entry you have requested exceeds the dimensions in the table.";
    }

    my $freq;
    $freq = $freqs[($row - 1) * $ncols + ($col - 1)];
    return($freq);

}

sub margintotal { # row or col number, index(1=rows, 2=cols)
    my %options = @_;
    my $self = $options{'data'};
    if ($self->{datatype} eq 'chi2_gof') {
        die "Error: margintotal is only valid for datatype chi2_ind or two_cat. For chi2_gof ".
            "use singlefreq.";
    } elsif ($self->{datatype} eq 'one_cat') {
        die "Error: margintotal is only valid for datatype two_cat or chi2_ind. For one_cat ".
            "use singlefreq.";
    }

    my $level; my $index;
    if( !defined($options{'level'}) ){
        die "Need a level for the margin total";
    } else {
        $level = $options{'level'} - 1;
    }

    if (!defined($options{'index'}) ){
        die "Error: Index must be defined for marginal distribution. Use 1 for rows ".
            "or 2 for columnns";
    } elsif ( $options{'index'} != 1 && $options{'index'} != 2) {
        die "Error: The index for the marginal distribution must either be 1 for rows ".
            "or 2 for columns.";
    } else {
        $index = $options{'index'};
    }

    my $n = $self->{n};

    my @freqs = @{$self->{freqs}};
    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    if($index == 1){
        if($level > $nrows){
            die "Error: there are only $nrows rows this table. The ".
                "entry you have requested exceeds the dimensions in the table.";
        }
    } else {
        if($level > $ncols){
           die "Error: there are only $ncols cols this table. The ".
                "entry you have requested exceeds the dimensions in the table.";
        }
    }


    my $margintotal = 0;
    if($index == 1){
        for(my $j=0; $j<$ncols; $j++){
            $margintotal += $freqs[$level*$ncols + $j];
        }
    } else {
        for (my $i=0; $i<$nrows; $i++){
            $margintotal += $freqs[$i*$ncols + $level];
        }
    }
    return($margintotal);
}

sub jointprop { #row, col
    my %options = @_;
    my $self = $options{'data'};

    my $row; my $col;
    if( !defined($options{'row'}) ){
        die "Need a row for the table cell";
    } else {
        $row = $options{'row'} - 1;
    }

    if( !defined($options{'col'}) ){
        die "Need a col for the table cell";
    } else {
        $col = $options{'col'} - 1;
    }

    my $n = $self->{n};

    my @freqs = @{$self->{freqs}};
    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    if($row > $nrows || $col > $ncols){
        die "Error: there are only $nrows rows and $ncols cols in this table. the ".
            "entry you have requested exceeds the dimensions in the table.";
    }

    my $freq = $freqs[$row*$ncols + $col];
    my $prop = sprintf("%.4f", $freq / $n);
    return($prop);

}

sub marginalprop { #row, col, index(1=rows, 2=cols)
    my %options = @_;
    my $self = $options{'data'};

    my $row; my $col; my $index;
    if( !defined($options{'row'}) ){
        die "Need a row for the table cell";
    } else {
        $row = $options{'row'} - 1;
    }

    if( !defined($options{'col'}) ){
        die "Need a col for the table cell";
    } else {
        $col = $options{'col'} - 1;
    }

    if (!defined($options{'index'}) ){
        die "Error: Index must be defined for marginal distribution. Use 1 for rows ".
            "or 2 for columnns";
    } elsif ( $options{'index'} != 1 && $options{'index'} != 2) {
        die "Error: The index for the marginal distribution must either be 1 for rows ".
            "or 2 for columns.";
    } else {
        $index = $options{'index'};
    }

    my $n = $self->{n};

    my @freqs = @{$self->{freqs}};
    my $nrows = $self->{nrows}; my $ncols = $self->{ncols};

    if($row > $nrows || $col > $ncols){
        die "Error: there are only $nrows rows and $ncols cols in this table. the ".
            "entry you have requested exceeds the dimensions in the table.";
    }

    my $margintotal = 0;
    if($index == 1){
        for(my $j=0; $j<$ncols; $j++){
            $margintotal += $freqs[$row*$ncols + $j];
        }
    } else {
        for (my $i=0; $i<$nrows; $i++){
            $margintotal += $freqs[$i*$ncols + $col];
        }
    }

    my $prop;
    $prop = $freqs[$row*$ncols + $col] / $margintotal;
    $prop = sprintf("%.4f", $prop);
    return($prop);
}


#}
1; #required at end of file - a perl thing