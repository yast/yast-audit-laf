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

# File:	include/audit-laf/cmdline.ycp
# Package:	Configuration of audit-laf
# Summary:	Command line interface functions.
# Authors:	Gabriele Mohr <gs@suse.de>
#
#
# All command line interface functions.
module Yast
  module AuditLafCmdlineInclude
    def initialize_audit_laf_cmdline(include_target)
      textdomain "audit-laf"

      Yast.import "CommandLine"
      Yast.import "AuditLaf"
      Yast.import "Report"

      @logfile_settings = [
        "log_file",
        "log_format",
        "flush",
        "freq",
        "max_log_file",
        "max_log_file_action",
        "num_logs",
        "name_format",
        "name"
      ]
      @diskspace_settings = [
        "space_left",
        "space_left_action",
        "admin_space_left",
        "admin_space_left_action",
        "action_mail_acct",
        "disk_full_action",
        "disk_error_action"
      ]
      @dispatcher_settings = ["disp_qos", "dispatcher"]
    end

    def GetLogfileSettings
      settings = ""

      Builtins.foreach(@logfile_settings) do |key|
        settings = Ops.add(
          Ops.add(
            Ops.add(Ops.add(settings, key), ": "),
            AuditLaf.GetAuditdOption(key)
          ),
          "\n"
        )
      end
      settings
    end

    def GetDiskspaceSettings
      settings = ""

      Builtins.foreach(@diskspace_settings) do |key|
        settings = Ops.add(
          Ops.add(
            Ops.add(Ops.add(settings, key), ": "),
            AuditLaf.GetAuditdOption(key)
          ),
          "\n"
        )
      end

      settings
    end

    def GetDispatcherSettings
      settings = ""

      Builtins.foreach(@dispatcher_settings) do |key|
        settings = Ops.add(
          Ops.add(
            Ops.add(Ops.add(settings, key), ": "),
            AuditLaf.GetAuditdOption(key)
          ),
          "\n"
        )
      end

      settings
    end
    def SettingsHandler(options)
      options = deep_copy(options)
      Builtins.y2milestone("Command line options: %1", options)

      Builtins.foreach(options) do |key, val|
        value = ""
        if Ops.is_integer?(val)
          value = Builtins.tostring(val)
        else
          value = Convert.to_string(val)
        end
        if Builtins.contains(@logfile_settings, key) ||
            Builtins.contains(@diskspace_settings, key) ||
            Builtins.contains(@dispatcher_settings, key)
          # option (key/value pair) can be written 'as is', e.g. log_format = RAW
          AuditLaf.SetAuditdOption(key, value)
        elsif Builtins.substring(key, Ops.subtract(Builtins.size(key), 6)) == "script"
          AuditLaf.SetAuditdOption(
            Ops.add(
              Builtins.substring(key, 0, Ops.subtract(Builtins.size(key), 6)),
              "action"
            ),
            Ops.add("EXEC ", value) # replace "script" by "action"
          ) # EXEC <script>
        end
      end

      true # call Write
    end

    # Show information about settings
    # @return [Boolean] false
    def ShowHandler(options)
      options = deep_copy(options)
      Builtins.y2milestone("Options:%1", options)
      sets = []

      Builtins.foreach(options) do |key, val|
        if Builtins.contains(["logfile", "diskspace", "disp"], key)
          sets = Builtins.add(sets, key)
        end
      end
      if sets == []
        CommandLine.Print(
          "Please specify information ('logfile', 'diskpace' or 'disp')"
        )
      end

      Builtins.foreach(sets) do |option|
        if option == "logfile"
          CommandLine.Print(GetLogfileSettings())
        elsif option == "diskspace"
          CommandLine.Print(GetDiskspaceSettings())
        elsif option == "disp"
          CommandLine.Print(GetDispatcherSettings())
        else
          CommandLine.Print("Unknown option")
        end
      end

      false # do not call Write...
    end
  end
end
