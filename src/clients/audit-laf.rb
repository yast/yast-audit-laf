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

# File:	clients/audit-laf.ycp
# Package:	Configuration of audit-laf
# Summary:	Main file
# Authors:	Gabriele Mohr <gs@suse.de>
#
#
# Main file for audit-laf configuration. Uses all other files.
module Yast
  class AuditLafClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of audit-laf</h3>

      textdomain "audit-laf"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("yast2-audit-laf module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"

      Yast.import "CommandLine"

      Yast.include self, "audit-laf/wizards.rb"
      Yast.include self, "audit-laf/cmdline.rb"

      @cmdline_description = {
        "id"         => "audit-laf",
        # Command line help text for the audit-laf module
        "help"       => _(
          "Configuration of Linux Audit Framework (LAF)"
        ),
        "guihandler" => fun_ref(method(:AuditLafSequence), "any ()"),
        "initialize" => fun_ref(AuditLaf.method(:Read), "boolean ()"),
        "finish"     => fun_ref(AuditLaf.method(:Write), "boolean ()"),
        "actions"    => {
          "show" => {
            "handler" => fun_ref(
              method(:ShowHandler),
              "boolean (map <string, any>)"
            ),
            # translators: command line help text for show action
            "help"    => _(
              "Show information about audit settings"
            )
          },
          "set" =>
            #"options"   	: ["non_strict"],
            #"non_strict_help":	_("Use keywords and values specified in 'man auditd.conf'")
            {
              "handler" => fun_ref(
                method(:SettingsHandler),
                "boolean (map <string, any>)"
              ),
              # translators: command line help text for set action
              "help"    => _(
                "Set the specified option"
              )
            }
        },
        "options"    => {
          "logfile"                 => {
            # translators: command line help text for 'show logfile'
            "help" => _(
              "Show log file settings"
            )
          },
          "diskspace"               => {
            # translators: command line help text for 'show diskspace'
            "help" => _(
              "Show disk space settings"
            )
          },
          "disp"                    => {
            # translators: command line help text for 'show dispatcher'
            "help" => _(
              "Show dispatcher settings"
            )
          },
          "log_file"                => {
            # translators: command line help text for log_file option
            "help" => _(
              "Name of the log file (full path name)"
            ),
            "type" => "string"
          },
          "log_format"              => {
            # translators: command line help text for log_format option
            "help"     => _(
              "Log format"
            ),
            "type"     => "enum",
            "typespec" => ["RAW", "NOLOG"]
          },
          "flush"                   => {
            # translators: command line help text for flush option
            "help"     => _(
              "How to write data to disk"
            ),
            "type"     => "enum",
            "typespec" => ["INCREMENTAL", "NONE", "DATA", "SYNC"]
          },
          "freq"                    => {
            # translators: command line help text for frequency option
            "help" => _(
              "How many records to write before a flush to disk is issued"
            ),
            "type" => "integer"
          },
          "max_log_file"            => {
            # translators: command line help text for max_log_file option
            "help" => _(
              "Maximal size (in MByte) of the log file"
            ),
            "type" => "integer"
          },
          "max_log_file_action"     => {
            # translators: command line help text for max_log_file_action option
            "help"     => _(
              "Action if max_log_file is reached"
            ),
            "type"     => "enum",
            "typespec" => ["IGNORE", "SYSLOG", "SUSPEND", "ROTATE", "KEEP_LOG"]
          },
          "num_logs"                => {
            # translators: command line help text for num_logs option
            "help" => _(
              "Number of log files to keep"
            ),
            "type" => "integer"
          },
          "name_format"             => {
            # translators: command line help text for name_format option
            "help"     => _(
              "Computer name format"
            ),
            "type"     => "enum",
            "typespec" => ["NONE", "HOSTNAME", "FQD", "USER"]
          },
          "name"                    => {
            # translators: command line help text for name_format option
            "help" => _(
              "Computer name (used if format is set to USER)"
            ),
            "type" => "string"
          },
          "space_left"              => {
            # translators: command line help text for space_left option
            "help" => _(
              "Space left on log partition (in MByte) when system starts to run low"
            ),
            "type" => "integer"
          },
          "space_left_action"       => {
            # translators: command line help text for space_left_action option
            "help"     => _(
              "Action if space_left is reached"
            ),
            "type"     => "enum",
            "typespec" => [
              "IGNORE",
              "SYSLOG",
              "SUSPEND",
              "SINGLE",
              "HALT",
              "EMAIL"
            ]
          },
          "space_left_script"       => {
            # translators: command line help text for space_left_script option
            "help" => _(
              "Script to execute (full path name) if space_left is reached"
            ),
            "type" => "string"
          },
          "admin_space_left"        => {
            # translators: command line help text for admin_space_left
            "help" => _(
              "Space left on log partition (in MByte) when system is running low"
            ),
            "type" => "integer"
          },
          "admin_space_left_action" => {
            # command line help text for admin_space_left_action option
            "help"     => _(
              "Action if admin_space_left is reached"
            ),
            "type"     => "enum",
            "typespec" => [
              "IGNORE",
              "SYSLOG",
              "SUSPEND",
              "SINGLE",
              "HALT",
              "EMAIL"
            ]
          },
          "admin_space_left_script" => {
            # translators: command line help text for admin_space_left_script option
            "help" => _(
              "Script to execute (full path name) if admin_space_left is reached"
            ),
            "type" => "string"
          },
          "action_mail_acct"        => {
            # command line help text for action_mail_acct option
            "help" => _(
              "Mail sent to this account (if space_left_action set to EMAIL)"
            ),
            "type" => "string"
          },
          "disk_full_action"        => {
            # command line help text for disk_full_action option
            "help"     => _(
              "Action to perform if disk is full"
            ),
            "type"     => "enum",
            "typespec" => ["IGNORE", "SYSLOG", "SUSPEND", "SINGLE", "HALT"]
          },
          "disk_full_script"        => {
            # translators: command line help text for admin_space_left_script option
            "help" => _(
              "Script to execute (full path name) if disk is full"
            ),
            "type" => "string"
          },
          "disk_error_action"       => {
            # command line help text for disk_error_action option
            "help"     => _(
              "Action to perform on disk error"
            ),
            "type"     => "enum",
            "typespec" => ["IGNORE", "SYSLOG", "SUSPEND", "SINGLE", "HALT"]
          },
          "disk_error_script"       => {
            # translators: command line help text for script on disk error option
            "help" => _(
              "Script to execute (full path name) on disk error"
            ),
            "type" => "string"
          },
          "disp_qos"                => {
            # command line help text for communication control option
            "help"     => _(
              "How to communicate between dispatcher and the audit daemon"
            ),
            "type"     => "enum",
            "typespec" => ["lossy", "lossless"]
          },
          "dispatcher"              => {
            # command line help text for dispatcher option
            "help" => _(
              "Dispatcher program (full path name)"
            ),
            "type" => "string"
          }
        },
        "mappings"   => {
          "show" => ["logfile", "diskspace", "disp"],
          "set"  => [
            "log_file",
            "log_format",
            "flush",
            "freq",
            "max_log_file",
            "max_log_file_action",
            "num_logs",
            "name_format",
            "name",
            "space_left",
            "space_left_action",
            "space_left_script",
            "admin_space_left",
            "admin_space_left_action",
            "admin_space_left_script",
            "action_mail_acct",
            "disk_full_action",
            "disk_full_script",
            "disk_error_action",
            "disk_error_script",
            "disp_qos",
            "dispatcher"
          ]
        }
      }

      # is this proposal or not?
      @propose = false
      @args = WFM.Args
      if Ops.greater_than(Builtins.size(@args), 0)
        if Ops.is_path?(WFM.Args(0)) && WFM.Args(0) == path(".propose")
          Builtins.y2milestone("Using PROPOSE mode")
          @propose = true
        end
      end

      # main ui function
      @ret = nil

      if @propose
        @ret = AuditLafAutoSequence()
      else
        @ret = CommandLine.Run(@cmdline_description)
      end
      Builtins.y2milestone("Return value=%1", @ret)

      # Finish
      Builtins.y2milestone("yast2-audit-laf module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::AuditLafClient.new.main
