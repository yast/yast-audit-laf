# Sources for audit-laf

module_DATA = \
  modules/AuditLaf.rb

client_DATA = \
  clients/audit-laf.rb \
  clients/audit-laf_proposal.rb \
  clients/audit-laf_auto.rb

yncludedir = @yncludedir@/audit-laf
ynclude_DATA = \
  include/audit-laf/wizards.rb \
  include/audit-laf/dialogs.rb \
  include/audit-laf/complex.rb \
  include/audit-laf/cmdline.rb \
  include/audit-laf/helps.rb

scrconf_DATA = \
  scrconf/auditd.scr

schemafilesdir = $(schemadir)/autoyast/rnc
schemafiles_DATA = \
  autoyast-rnc/audit-laf.rnc

desktop_DATA = \
  desktop/audit-laf.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(schemafiles_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common