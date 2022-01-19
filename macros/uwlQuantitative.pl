# quantitative_UWL.pl

# only load in the macros that don't already exist
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

# PG macros shouldn't reload by default if they're already loaded
loadMacros("PGgraphmacros.pl",
           "PGstandard.pl",
           "PGstatisticsmacros.pl",
           "PGunion.pl",
);



sub _uwlQuantitative_init { };

package QuantitativeUWL;
@ISA = qw(Value::String);

=pod


=cut

sub anovahead {
  my $rowref = shift; my @row = @{$rowref};
  my @texaligns = ('\hfil ', '\hfil ', '\hfil ', '\hfil ', '\hfil ', '\hfil ');

  my $tex = '\cr'."\n";
  my $html = "<TR VALIGN=\"MIDDLE\">\n";
  my $texalign; my $cell;
  do {
      $cell = shift(@row);
      $texalign = shift(@texaligns);

      $tex .= $texalign . $cell .'&';
      $html .= "<TD ALIGN=\"CENTER\">" .$cell . "</TD> \n";
    } until (@row == 1);
  $cell = shift(@row);
  $tex .= shift(@texaligns) . $cell;
  $html .= "<TD ALIGN=\"CENTER\">" .$cell . "</TD> \n </TR>\n";
  main::MODES (
    TeX => $tex,
    HTML => $html,
  );
}

sub anovarow {
  my $rowref = shift; my @row = @{$rowref};
  my @htmlaligns = ('LEFT', 'RIGHT', 'RIGHT', 'RIGHT', 'RIGHT', 'RIGHT');
  my @texaligns = ('', '\hfill ', '\hfill ', '\hfill ', '\hfill ', '\hfill ');

  my $tex = '\cr'."\n";
  my $html = "<TR VALIGN=\"MIDDLE\">\n";
  my $texalign; my $htmlalign; my $cell;
  do {
      $cell = shift(@row);
      $texalign = shift(@texaligns);
      $htmlalign = shift(@htmlaligns);

      $tex .= $texalign . $cell .'&';
      $html .= "<TD ALIGN=\"$htmlalign\">" .$cell . "</TD> \n";
    } until (@row == 1);
  $cell = shift(@row);
  $tex .= shift(@texaligns) . $cell;
  $html .= "<TD ALIGN=\"".shift(@htmlaligns)."\">" .$cell . "</TD> \n </TR>\n";
  main::MODES (
    TeX => $tex,
    HTML => $html,
  );
}

sub onewayaov_table {
  my %options = @_;
  my $anova = $options{'anova'};

  my $pvalue;
  if ($anova->{pvalue} < 0.0001) {
    $pvalue = '\( < 0.0001 \)';
  } else {
    $pvalue = sprintf("%.4f", $anova->{pvalue});
  }

  my $round = defined($anova->{round}) ? $anova->{round} : 3;
  my $dfa = $anova->{dfa};
  my $SSA = sprintf("%.".$round."f", $anova->{SSA});
  my $MSA = sprintf("%.".$round."f", $anova->{MSA});
  my $F = sprintf("%.".$round."f", $anova->{F});
  my $dfe = $anova->{dfe};
  my $SSE = sprintf("%.".$round."f", $anova->{SSE});
  my $MSE = sprintf("%.".$round."f", $anova->{MSE});
  my $dftot = $anova->{dftot};
  my $SSTot = sprintf("%.".$round."f", $anova->{SSTot});

  my $table;
  $table = main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
  $table .= anovahead(["Source", "df", "SS", "MS", "F", "p-value"]);
  $table .= anovarow([$anova->{factor}, $dfa, $SSA, $MSA, $F, $pvalue]);
  $table .= anovarow(["Error", $dfe, $SSE, $MSE, "", ""]);
  $table .= anovarow(["Total", $dftot, $SSTot, "", "", ""]);
  $table .= main::EndTable();

  return($table);
}

sub regHead {
  my $rowref = shift; my @row = @{$rowref};
  my @texaligns = ('\hfil ', '\hfil ', '\hfil ', '\hfil ', '\hfil ', '\hfil ');

  my $tex = '\cr'."\n";
  my $html = "<TR VALIGN=\"MIDDLE\">\n";
  my $texalign; my $cell;
  do {
      $cell = shift(@row);
      $texalign = shift(@texaligns);

      $tex .= $texalign . $cell .'&';
      $html .= "<TD ALIGN=\"CENTER\">" .$cell . "</TD> \n";
    } until (@row == 1);
  $cell = shift(@row);
  $tex .= shift(@texaligns) . $cell;
  $html .= "<TD ALIGN=\"CENTER\">" .$cell . "</TD> \n </TR>\n";
  main::MODES (
    TeX => $tex,
    HTML => $html,
  );
}

sub regRow {
  my $rowref = shift; my @row = @{$rowref};
  my @htmlaligns = ('LEFT', 'RIGHT', 'RIGHT', 'RIGHT', 'RIGHT', 'RIGHT');
  my @texaligns = ('', '\hfill ', '\hfill ', '\hfill ', '\hfill ', '\hfill ');

  my $tex = '\cr'."\n";
  my $html = "<TR VALIGN=\"MIDDLE\">\n";
  my $texalign; my $htmlalign; my $cell;
  do {
      $cell = shift(@row);
      $texalign = shift(@texaligns);
      $htmlalign = shift(@htmlaligns);

      $tex .= $texalign . $cell .'&';
      $html .= "<TD ALIGN=\"$htmlalign\">" .$cell . "</TD> \n";
    } until (@row == 1);
  $cell = shift(@row);
  $tex .= shift(@texaligns) . $cell;
  $html .= "<TD ALIGN=\"".shift(@htmlaligns)."\">" .$cell . "</TD> \n </TR>\n";
  main::MODES (
    TeX => $tex,
    HTML => $html,
  );
}

sub simpRegTable {
  my %options = @_;
  my $reg = $options{'reg'};

  my $xname = defined($options{'xlab'}) ? $options{'xlab'} : "x";
  my $yname = defined($options{'ylab'}) ? $options{'ylab'} : "y";

  my $round = defined($options{'round'}) ? $options{'round'} : 3;
  my $pvallim = 10**(-$round);
  my $b0 = sprintf("%.".$round."f", $reg->{b0});
  my $b0se = sprintf("%.".$round."f", $reg->{b0se});
  my $b0t = sprintf("%.".$round."f", $reg->{b0t});
  my $b1 = sprintf("%.".$round."f", $reg->{b1});
  my $b1se = sprintf("%.".$round."f", $reg->{b1se});
  my $b1t = sprintf("%.".$round."f", $reg->{b1t});

  my $b0pval;
  if ($reg->{b0pval} < $pvallim) {
    $b0pval = '\( < '.$pvallim.'\)';
  } else {
    $b0pval = sprintf("%.".$round."f", $reg->{b0pval});
  }

  my $b1pval;
  if ($reg->{b1pval} < $pvallim) {
    $b1pval = '\( < '.$pvallim.'\)';
  } else {
    $b1pval = sprintf("%.".$round."f", $reg->{b1pval});
  }

  my $table;
  $table = main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
  $table .= regHead(["Coefficients", "Estimate", "Std. Error", "t value", 'p-value']);
  $table .= regRow(["(Intercept)", $b0, $b0se, $b0t, $b0pval]);
  $table .= regRow([$xname, $b1, $b1se, $b1t, $b1pval]);
  $table .= main::EndTable();

  return($table);
}

sub summarystats {
    my %options = @_;
    my @datasets = @{$options{'data'}};
    my $round = defined($options{'round'}) ? $options{'round'} : 3;
    my $nsets = @datasets;
    my $data; my @means; my @sds; my @ns; my @names;
    do {
      $data = shift(@datasets);
      push(@means, $data->{mean});
      push(@sds, $data->{sd});
      push(@ns, $data->{n});
      push(@names, $data->{name});
    } until (@datasets == 0);

    my $table;
    $table = main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
    $table .= main::AlignedRow(["Name", "Mean", "Std. Dev", "n"], align=>"CENTER", valign=>"MIDDLE", separation=>0);

    my @rowentries;
    for my $i (0..($nsets - 1)) {
      @rowentries = ();
      push(@rowentries, $names[$i]);
      push(@rowentries, sprintf("%.".$round."f", $means[$i]));
      push(@rowentries, sprintf("%.".$round."f", $sds[$i]));
      push(@rowentries, $ns[$i]);
      $table .= main::AlignedRow([@rowentries], align=>"CENTER", valign=>"MIDDLE", separation=>0);
    }

    $table .= main::EndTable();
    return($table);

}

sub fivenum {
    my %options = @_;
    my $self = $options{'data'};
    my $round = defined($self->{round}) ? $self->{round} : 3;

    my @fivenums = (sprintf("%.".$round."f", $self->{min}),
                    sprintf("%.".$round."f", $self->{q1}),
                    sprintf("%.".$round."f", $self->{med}),
                    sprintf("%.".$round."f", $self->{q3}),
                    sprintf("%.".$round."f", $self->{max}) );

    my $summary = join(", ", @fivenums);

    return($summary);
}


sub percentile { # p => 0.25
    my %options = @_;
    my $self = $options{'data'};

    my $percentile;
    if( !defined( $options{'p'} ) ){
        die "Error: p must be defined";
    } else {
        $percentile = $options{'p'};
        if ($percentile <= 0 || $percentile >= 1) {
            die "Error: p must be between 0 and 1";
        }
    }

    my @x = @{$self->{x}};
    # my $n = scalar(@x);
    # my $idx = main::floor($n * $percentile);
    # my $result = $x[$idx];

    my $x = QuantitativeUWL::disp_r(@x);
    main::rserve_eval('x <- '. $x);
    my ($result) = main::rserve_eval('quantile(x = x, probs = '. $percentile .')');

    return($result);
}

sub percentile_table {
  my %options = @_;
  my $self = $options{'data'};

  my @percentiles;
  if (defined($options{'percentiles'})) {
    @percentiles = @{$options{'percentiles'}};
  } else {
    @percentiles = (0.005, 0.010, 0.025, 0.050, 0.100, 0.900, 0.950, 0.975, 0.990, 0.995);
  }

  my @header = ("");
  my @quantiles = ("Percentile: ");

  my $round = defined($options{'round'}) ? $options{'round'} : 3;
  my $npercentiles = scalar(@percentiles);
  my $headerp; my $quantile;

  my $probs = QuantitativeUWL::disp_r(@percentiles);
  my $x = QuantitativeUWL::disp_r(@{$self->{x}});
  push(@header, @percentiles);
  push(@quantiles, main::rserve_eval('round(quantile(x = ' . $x . ',
                                      probs = '. $probs . '), ' . $round . ')'));

  # for my $i (0..($npercentiles - 1)) {
  #   $headerp = sprintf("%.3f", $percentiles[$i]);
  #   push(@header, $headerp);
  #   $quantile = percentile(data=>$self, p=>$percentiles[$i]);
  #   $quantile = sprintf("%.".$round."f", $quantile);
  #   push(@quantiles, $quantile);
  # }

  my $table;
  $table = main::BeginTable(border=>1, tex_border=>"1pt", spacing=>0, padding=>4, center=>0);
  $table .= main::AlignedRow([@header], align=>"CENTER", valign=>"MIDDLE", separation=>0);
  $table .= main::AlignedRow([@quantiles], align=>"CENTER", valign=>"MIDDLE", separation=>0);
  $table .= main::EndTable();

  return($table);
}

sub random_pvalue {
  my %options = @_;
  my $self = $options{'data'};

  my @x = @{$self->{x}};
  my $test_stat;
  if (!defined($options{'test_stat'})) {
    die "Error: To get a p-value you must specify test_stat";
  } else {
    $test_stat = $options{'test_stat'};
  }

  my $alternative;
  if (!defined($options{'alternative'})) {
    die "Error: You must specify an alternative hypothesis";
  } else {
    $alternative = $options{'alternative'};
  }

  my $acc; my $att;
  my $gt = 0; my $lt = 0;
  foreach (@x) {
    if ($_ >= $test_stat) {
      $gt ++;
    } elsif ($_ <= $test_stat) {
      $lt ++;
    }
    $att ++;
  }

  if ($alternative eq uc('LT')) {
    $acc = $lt;
  } elsif ($alternative eq uc('GT')) {
    $acc = $gt;
  }  elsif ($alternative eq uc('NEQ')) {
    $acc = ($lt < $gt) ? $lt : $gt;
    $acc *= 2;
  } else {
    die "Error: alternative must be one of LT, GT, or NEQ";
  }

  my $pval = $acc / $att;
  $pval = sprintf("%.4f", $pval);

  return($pval);
}

sub rsq2sig { # $rsq, $SSR, $n
    my $rsq = shift; my $ssr = shift; my $n = shift;

    my $lsse = ln($ssr) - ln($rsq) + ln(1 - $rsq);
    my $lmse = $lsse - ln($n - 2);
    my $mse = exp($lmse);
    my $sig = sqrt($mse);

    return($sig);
}

sub ypred { # $b0, $b1, $x Note: scalar $x
    my $b0 = shift; my $b1 = shift; my $x = shift;
    my $value = $b0 + $b1 * $x;

    return($value);
}

sub findres { # $b0, $b1, [@x], [@y]
    my $b0 = shift; my $b1 = shift;
    my $x_ref = shift; my @x = @{$x_ref};
    my $y_ref = shift; my @y = @{$y_ref};
    my $n = scalar( @x );

    my @residuals; my $yhat; my $residual;
    for( my $i=0; $i < $n; $i++ ){
        $yhat = ypred($b0, $b1, $x[$i]);
        $residual = $yhat - $y[$i];
        push(@residuals, $residual);
    }

    return @residuals;
}

sub disp_r {
  my $results = "c(".join(", ", @_).")";
  return($results);
}

sub disp_r_x {
    my $self = shift;
    my @x = @{$self->{x}};
    my $results = "x <- c(".join(", ", @x).")";

    return($results);
}

sub disp_r_y {
    my $self = shift;
    my @y = @{$self->{y}};
    my $results = "y <- c(".join(", ", @y).")";

    return($results);
}

1; #required at end of file - a perl thing