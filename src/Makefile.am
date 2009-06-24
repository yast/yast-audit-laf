# Makefile.am for audit-laf/src

yncludedir = @yncludedir@/audit-laf

client_DATA =			\
	audit-laf.ycp		\
	audit-laf_auto.ycp	\
	audit-laf_proposal.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp		\
	cmdline.ycp

desktop_DATA =			\
	audit-laf.desktop

rncdir = $(schemadir)/autoyast/rnc
rnc_DATA = audit-laf.rnc

module_DATA =			\
	AuditLaf.ycp

# create a symlink for local build, #145327
audit-laf:
	ln -sf . $@
ycpchook = audit-laf

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA) $(rnc_DATA)

include $(top_srcdir)/Makefile.am.common
