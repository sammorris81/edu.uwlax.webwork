# going to check one by one and if the macro is not loaded, then load it

if (!defined(&_uwlCategorical_init)) {
  loadMacros("uwlCategorical.pl");
}

if (!defined(&_uwlDataGen_init)) {
  loadMacros("uwlDataGen.pl");
}

if (!defined(&_uwlHyptestProblem_init)) {
  loadMacros("uwlHyptestProblem.pl");
}

if (!defined(&_uwlQuantitative_init)) {
  loadMacros("uwlQuantitative.pl");
}

if (!defined(&_uwlStatGraphics_init)) {
  loadMacros("uwlStatGraphics.pl");
}

# if (!defined(&_uwlSummaryTable_init)) {
#   loadMacros("uwlSummaryTable.pl");
# }

if (!defined(&_uwlUnionLists_init)) {
  loadMacros("uwlUnionLists.pl");
}

if (!defined(&_uwlUsefulStats_init)) {
  loadMacros("uwlUsefulStats.pl");
}

if (!defined(&_uwlDisplayMacros_init)) {
  loadMacros("uwlDisplayMacros.pl")
}

1; #required at end of file - a perl thing