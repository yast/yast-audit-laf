# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/audit-laf/helps.ycp
# Package:	Configuration of Linux Auditing
# Summary:	Help texts of all the dialogs
# Authors:	Gabriele Mohr <gs@suse.de>
#
module Yast
  module AuditLafHelpsInclude
    def initialize_audit_laf_helps(include_target)
      textdomain "audit-laf"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"               => _(
          "<p><b><big>Initializing Configuration of Linux Audit Framework</big></b><br>\n</p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"              => _(
          "<p><b><big>Saving auditd Configuration and Rules</big></b><br>\n</p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          ),
        # logfile_settings dialog help 1/8
        "logfile_settings"   => _(
          "<p><b><big>Auditd Log File Configuration</big></b><br>\n" +
            "The audit daemon is the component of the Linux Auditing System which is responsible for writing all relevant audit events to the log file <i>/var/log/audit/audit.log</i> (default).\n" +
            "Events may come from the <i>apparmor</i> kernel module, from applications which use <i>libaudit</i> (e.g. PAM) or incidents caused by rules (e.g. file watches).</p>"
        ) +
          #  logfile_settings dialog help 2/8
          _(
            "<p>The <b>Rules for auditctl</b> dialog offers more information about rules and the possibility to add rules.\nDetailed information about the log file settings can be obtained from the manual page ('man auditd.conf').</p>"
          ) +
          # logfile_settings dialog help 3/8
          _(
            "<p><b>Log File</b>: Enter the full path name to the log file\n(or use <b>Select File</b>.)</p>"
          ) +
          # logfile_settings dialog help 4/8
          _(
            "<p><b>Format</b>: set <i>RAW</i> to log all data (store in a format exactly as the kernel\n" +
              "sends it) or <i>NOLOG</i> to discard all audit information instead of writing it on disk (does not affect\n" +
              "data sent to the dispatcher).</p> "
          ) +
          # logfile_settings dialog help 5/8
          _(
            "<p><b>Flush</b>: describes how to write the data to disk. If set to <i>INCREMENTAL</i> the\n" +
              "<b>Frequency</b> parameter tells how many records to write before issuing an explicit flush to disk.\n" +
              "<i>NONE</i> means: no special effort is made to flush data, <i>DATA</i>: keep data portion synced,\n" +
              "<i>SYNC</i>: keep data and meta-data fully synced.</p>"
          ) +
          # logfile_settings dialog help 6/8
          _(
            "<p>Configure the maximum log file size (in megabytes) and the action to take when this\nvalue is reached via <b>Size and Action</b>.</p>\n"
          ) +
          # logfile_settings dialog help 7/8
          _(
            "<p>If the action is set to <i>ROTATE</i> the <b>Number of Log Files</b> specifies the number\n" +
              "of files to keep. Set to <i>SYSLOG</i>, the audit daemon will write a warning\n" +
              "to /var/log/messages. With <i>SUSPEND</i> the daemon stops writing records to\n" +
              "disk. <i>IGNORE</i> means do nothing, <i>KEEP_LOGS</i> is similar\n" +
              "to ROTATE, but log files are not overwritten.</p>\n"
          ) +
          # logfile_settings dialog help 8/8
          _(
            "<p><b>Computer Name Format</b> describes how to write the computer name to the\n" +
              "log file.  If <i>USER</i> is set, the <b>User Defined Name</b> is\n" +
              "used. <i>NONE</i> means no computer name is inserted. <i>HOSTNAME</i> uses the\n" +
              "name returned by the 'gethostname' syscall.  <i>FQD</i> uses the fully qualified\n" +
              "domain name.</p>\n"
          ),
        # dispatcher dialog help 1/5
        "dispatcher"         => _(
          "<p><b><big>Auditd Dispatcher Configuration</big></b><br>\n" +
            "Detailed information about the dispatcher settings can be obtained from the manual page\n" +
            "('man auditd.conf').</p>"
        ) +
          # dispatcher dialog help 2/5
          _(
            "<p><b>Dispatcher</b>: The dispatcher program is started by the audit daemon and\ngets all audit events on stdin.</p>"
          ) +
          # dispatcher dialog help 3/5
          _(
            "<p><b>Communication</b>: Controls the communication between the daemon and the dispatcher\n" +
              "program. A <i>lossy</i> communication means that events going to the dispatcher are discarded\n" +
              "when the queue (a 128kB buffer) is full. Choose <i>lossless</i> if you want a blocking/lossless\n" +
              "communication.</p>"
          ) +
          # dispatcher dialog help 4/5
          _(
            "<p>The dispatcher 'audispd' is an audit event multiplexor.\nFor more information see the manual pages ('man audispd' and 'man audispd.conf').</p>"
          ) +
          # dispatcher dialog help 5/5
          _(
            "<p><b>Note:</b> The dispatcher program must be owned by 'root', have '0750'\n file permissions, and the full path name has to be entered.</p>\n"
          ),
        # disk space dialog help 1/6
        "diskspace_settings" => _(
          "<p><b><big>Auditd Disk Space Configuration</big></b><br>\n" +
            "The settings made here refer to disk space on log partition.\n" +
            "For detailed information, refer to the manual page ('man auditd.conf').</p>\n"
        ) +
          # disk space dialog help 2/6
          _(
            "<p><b>Space Left</b> (in megabytes) tells the audit daemon when to perform an <b>Action</b> because\nthe system is starting to run low on space.</p>"
          ) +
          # disk space dialog help 3/6
          _(
            "<p>The value for <b>Admin Space Left</b> should be lower than above. The system <b>is running\nlow</b> on disk space if the value is reached and the specified <b>Action</b> will be performed.</p>"
          ) +
          # disk space dialog hep 4/6
          _(
            "<p>If an action is set to <i>EMAIL</i>, a warning mail will be sent to the\n" +
              "account specified in <b>Action Mail Account</b>.<br> <i>SYSLOG</i> means the\n" +
              "disk space warning will be written to /var/log/messages. <i>IGNORE</i> means\n" +
              "do nothing. <i>EXEC</i> runs the script specified in <b>Path to\n" +
              "Script</b>. <i>SUSPEND</i> stops writing records to disk. <i>SINGLE</i>\n" +
              "switches the system to single user mode. <i>HALT</i> shuts down the\n" +
              "system.</p>\n"
          ) +
          # disk space dialog help 5/6
          _(
            "<p>You can also specify a <b>Disk Full Action</b> (disk has become full already) and\n" +
              "a <b>Disk Error Action</b> (performed whenever an error is detected while writing to disk).\n" +
              "Available actions are the same as above (except for <i>EMAIL</i>).</p>"
          ) +
          # disk space dialog help 5/6
          _(
            "<p><b>Note:</b> All scripts specified for <i>EXEC</i> must be owned\nby 'root', have '0750' file permissions, and the full path name has to be entered.</p>\n"
          ),
        # rules dialog help 1/6
        "audit_rules"        => _(
          "<p><b><big>Rules for auditctl</big></b><br>\n" +
            "This dialog offers the possibility to enable or to disable the syscall\n" +
            "auditing as well as to lock the audit configuration.\n" +
            "The selected flag from <b>Set Enabled Flag</b> will be added to the rules.</p>"
        ) +
          # rules dialog help 2/6
          _(
            "<p><b>Note:</b><br>Locking the rules means they cannot be changed until next reboot.</p>"
          ) +
          # rules dialog help 3/6
          _(
            "<p>Enabling auditing without additional rules will cause the\n applications which use <i>libaudit</i>, e.g. PAM to log to /var/log/audit/audit.log (default).</p> "
          ) +
          # rules dialog help 4/6
          _(
            "<p>You can also edit the rules manually, which we only recommended for advanced users.<br>\nFor more information about all options, see 'man auditctl'.</p>\n"
          ) +
          # rules dialog help 5/6
          _(
            "<p><b>Check Syntax</b> sends the rules via <i>auditctl</i> to the audit subsystem and checks the syntax.<br><b>Restore</b> restores the settings from /etc/audit/audit.rules.</p>\n"
          ) +
          # rules dialog help 6/6
          _(
            "<p>Click <b>Restore and Reset</b> to restore the rules and reset\n" +
              "the changes (from previous syntax checks) by calling <i>auditctl</i>.<br>\n" +
              "Click <b>Load</b> to open a file selection dialog in which you can load\n" +
              "an example rules file.</p>\n"
          )
      } 

      # EOF
    end
  end
end
