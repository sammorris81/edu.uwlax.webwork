# some useful display macros

sub _uwlDisplayMacros_init {};

if ($displayMode eq "TeX") {
  our $anssep = '\( \ \noindent \)';
  our $extrasep = '\( \noindent \)';
  our $tab = '\( \qquad \)';
  our $sp = '\( \ \)';
  our $BBQ = '';
  our $EBQ = '';
  our $disp_alpha = '\( \alpha \)';
  our $disp_chisq = '\( \chi^2 \)';
  our $disp_p   = '\( p \)';
  our $disp_mu  = '\( \mu \)';
  our $disp_p1  = '\( p_1 \)';
  our $disp_p2  = '\( p_2 \)';
  our $disp_pf  = '\( p_F \)';
  our $disp_pm  = '\( p_M \)';
  our $disp_pu  = '\( p_U \)';
  our $disp_mu1 = '\( \mu_1 \)';
  our $disp_mu2 = '\( \mu_2 \)';
  our $disp_mua = '\( \mu_A \)';
  our $disp_mub = '\( \mu_B \)';
  our $disp_muf = '\( \mu_F \)';
  our $disp_mum = '\( \mu_M \)';
  our $disp_muu = '\( \mu_U \)';
  our $disp_mud = '\( \mu_d \)';
  our $disp_lt  = '\( < \)';
  our $disp_le  = '\( \leq \)';
  our $disp_gt  = '\( > \)';
  our $disp_ge  = '\( \geq \)';
  our $disp_ne  = '\( \neq \)';
  our $disp_null = '\( H_0 \)';
  our $disp_alt  = '\( H_a \)';
  our $disp_amp  = '\( \& \)';
  our $disp_rsq  = '\( R^2 \)';
} else {
  our $extrasep = $PAR;
  our $anssep = $PAR;
  our $tab = '&nbsp; &nbsp; &nbsp; &nbsp;';
  our $sp  = '&nbsp;';
  our $BBQ = '<blockquote>';
  our $EBQ = '</blockquote>';
  our $disp_alpha = '<span style = "font-family: serif; font-size:110%">&alpha;</span>';
  our $disp_chisq = '<span style = "font-family: serif; font-size:110%">&chi;</span><sup>2</sup>';
  our $disp_p   = 'p';
  our $disp_mu  = '&mu;';
  our $disp_phat = '<span style = "font-family:serif; font-size:120%; font-style:oblique;">p&#770;</span>';
  our $disp_xbar = '<span style = "font-family:serif; font-size:120%; font-style:oblique;">x&#772;</span>';
  our $disp_p1  = 'p<sub><span style = "font-size:85%">1</span></sub>';
  our $disp_p2  = 'p<sub><span style = "font-size:85%">2</span></sub>';
  our $disp_pf  = 'p<sub><span style = "font-size:85%">F</span></sub>';
  our $disp_pm  = 'p<sub><span style = "font-size:85%">M</span></sub>';
  our $disp_mu1 = '&mu;<sub><span style = "font-size:85%">1</span></sub>';
  our $disp_mu2 = '&mu;<sub><span style = "font-size:85%">2</span></sub>';
  our $disp_mua = '&mu;<sub><span style = "font-size:85%">A</span></sub>';
  our $disp_mub = '&mu;<sub><span style = "font-size:85%">B</span></sub>';
  our $disp_muf = '&mu;<sub><span style = "font-size:85%">F</span></sub>';
  our $disp_mum = '&mu;<sub><span style = "font-size:85%">M</span></sub>';
  our $disp_muu = '&mu;<sub><span style = "font-size:85%">U</span></sub>';
  our $disp_mud = '&mu;<sub><span style = "font-size:90%">d</span></sub>';
  our $disp_lt  = '&lt;';
  our $disp_le  = '&le;';
  our $disp_gt  = '&gt;';
  our $disp_ge  = '&ge;';
  our $disp_ne  = '&ne;';
  our $disp_null = 'H<sub><span style = "font-size:85%">0</span></sub>';
  our $disp_alt  = 'H<sub><span style = "font-size:90%">a</span></sub>';
  our $disp_amp  = '&amp;';
  our $disp_rsq  = '<span style = "font-family:serif; font-size:120%; font-style:oblique;">R<sup><span style = "font-size:85%">2</span></sup></span>';
}

sub computer {
  my $message = shift;
  MODES(
    TeX => '\hbox{\texttt{'.$message.'}}',
    Latex2HTML =>
       $bHTML.'<NOBR><TT>'.$eHTML.$message.$bHTML.'</TT></NOBR>'.$eHTML,
    HTML => '<NOBR><TT>'.$message.'</TT></NOBR>'
  );
}

1;