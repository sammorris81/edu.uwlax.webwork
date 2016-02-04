our @ybars_aov; our @sds_aov; our @ns_aov;
our @quants_aov;
our @text_aov;

# entry 0



push(@text_aov,
  "Contrast baths are a treatment commonly used in hand clinics to reduce " .
  "and stiffness after surgery. Patients' hands are immersed alternately in " .
  "warm and cool water. Sometimes, the treatment is combined with mild exercise. " .
  "Although the treatment is widely used, it had never been verified that it " .
  "would accomplish the stated outcome goal of reducing swelling. Researchers " .
  "randomly assigned $N patients who had received carpal tunnel release surgery " .
  "to one of three treatements: contrast bath, contrast bath with exercise, and " .
  "(as a control) exercise alone. Hand therapists who did not know how the " .
  "subjects had been treated measured hand volumes before and after treatments " .
  "in milliliters by measuring how much water the hand displaced when submerged. " .
  "The change in hand volume (after treatment minus before) was reported as the " .
  "outcome."
);

our $num_aov = scalar(@ns_aov);

1;