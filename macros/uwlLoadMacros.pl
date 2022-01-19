# going to check one by one and if the macro is not loaded, then load it

if (!exists(&_uwlCategorical_init)) {
  loadMacros("uwlCategorical.pl");
}

if (!exists(&_uwlDataGen_init)) {
  loadMacros("uwlDataGen.pl");
}

if (!exists(&_uwlHyptestProblem_init)) {
  loadMacros("uwlHyptestProblem.pl");
}

if (!exists(&_uwlQuantitative_init)) {
  loadMacros("uwlQuantitative.pl");
}

if (!exists(&_uwlStatGraphics_init)) {
  loadMacros("uwlStatGraphics.pl");
}

# if (!exists(&_uwlSummaryTable_init)) {
#   loadMacros("uwlSummaryTable.pl");
# }

if (0 && !exists(&_uwlUnionLists_init)) {
  loadMacros("uwlUnionLists.pl");
}

if (!exists(&_uwlUsefulStats_init)) {
  loadMacros("uwlUsefulStats.pl");
}

if (!exists(&_uwlDisplayMacros_init)) {
  loadMacros("uwlDisplayMacros.pl")
}

1; #required at end of file - a perl thing
