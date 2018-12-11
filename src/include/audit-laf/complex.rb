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

# File:	include/audit-laf/complex.ycp
# Package:	Configuration of Linux Auditing
# Summary:	Dialogs definitions
# Authors:	Gabriele Mohr <gs@suse.de>
#

require "shellwords"

module Yast
  module AuditLafComplexInclude
    def initialize_audit_laf_complex(include_target)
      Yast.import "UI"

      textdomain "audit-laf"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Confirm"
      Yast.import "AuditLaf"
      Yast.import "Report"
      Yast.import "FileUtils"

      Yast.include include_target, "audit-laf/helps.rb"
    end

    # Return a modification status
    # @return true if data was modified
    def Modified
      AuditLaf.Modified
    end

    def ReallyAbort
      Popup.ReallyAbort(AuditLaf.Modified)
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      return :abort if !Confirm.MustBeRoot

      ret = AuditLaf.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))

      ret = AuditLaf.Write
      ret ? :next : :abort
    end

    # Init log file dialog (set values to values read with AuditLad::Read())
    def InitLogfileSettingsDialog(id)
      UI.ChangeWidget(Id("max_log_file"), :ValidChars, "0123456789")

      # Set all values to values read from /etc/audit/auditd.conf
      UI.ChangeWidget(
        Id("freq"),
        :Value,
        Builtins.tointeger(AuditLaf.GetAuditdOption("freq"))
      )
      UI.ChangeWidget(
        Id("num_logs"),
        :Value,
        Builtins.tointeger(AuditLaf.GetAuditdOption("num_logs"))
      )
      Builtins.foreach(["log_file", "max_log_file", "name"]) do |key|
        UI.ChangeWidget(Id(key), :Value, AuditLaf.GetAuditdOption(key))
      end

      Builtins.foreach(
        ["log_format", "flush", "max_log_file_action", "name_format"]
      ) do |key|
        UI.ChangeWidget(
          Id(key),
          :Value,
          Builtins.toupper(AuditLaf.GetAuditdOption(key))
        )
        if key == "name_format"
          if Builtins.toupper(AuditLaf.GetAuditdOption(key)) == "USER"
            UI.ChangeWidget(Id("name"), :Enabled, true)
          else
            UI.ChangeWidget(Id("name"), :Enabled, false)
          end
        end
      end

      Builtins.y2milestone("Init log file settings")

      nil
    end

    # Handle actions of log file dialog (button 'Select file')
    def HandleLogfileSettingsDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      Builtins.y2milestone("HandleLogfileSettingsDialog got action: %1", action)

      if action == "select_file"
        file_name = UI.AskForSaveFileName(
          "/var/log/audit",
          "*.log",
          _("Select the log file")
        )
        UI.ChangeWidget(Id("log_file"), :Value, file_name)

        Builtins.y2milestone("Logfile set to: %1", file_name)
      elsif action == "name_format"
        option = Convert.to_string(UI.QueryWidget(Id("name_format"), :Value))
        if option == "USER"
          UI.ChangeWidget(Id("name"), :Enabled, true)
        else
          UI.ChangeWidget(Id("name"), :Enabled, false)
        end
      end
      nil
    end

    # Store all settings made in log file dialog
    def StoreLogfileSettingsDialog(id, event)
      event = deep_copy(event)
      # Store all values in SETTINGS
      AuditLaf.SetAuditdOption(
        "freq",
        Builtins.tostring(
          Convert.to_integer(UI.QueryWidget(Id("freq"), :Value))
        )
      )
      AuditLaf.SetAuditdOption(
        "num_logs",
        Builtins.tostring(
          Convert.to_integer(UI.QueryWidget(Id("num_logs"), :Value))
        )
      )

      Builtins.foreach(
        [
          "log_file",
          "log_format",
          "max_log_file",
          "flush",
          "max_log_file_action",
          "name_format"
        ]
      ) do |key|
        AuditLaf.SetAuditdOption(
          key,
          Convert.to_string(UI.QueryWidget(Id(key), :Value))
        )
      end

      if AuditLaf.GetAuditdOption("name_format") == "USER"
        if Convert.to_string(UI.QueryWidget(Id("name"), :Value)) == ""
          Report.Error(
            _(
              "The 'User Defined Name' is NOT set although\n" +
                "the 'Computer Name Format' is set to 'USER'.\n" +
                "Setting the format to 'NONE' (default)."
            )
          )
          AuditLaf.SetAuditdOption("name_format", "NONE")
        else
          AuditLaf.SetAuditdOption(
            "name",
            Convert.to_string(UI.QueryWidget(Id("name"), :Value))
          )
        end
      end

      AuditLaf.SetDataModified

      Builtins.y2milestone("Store log file settings")

      nil
    end

    # Init dispatcher dialog (set values to values read with AuditLad::Read())
    def InitDispatcherDialog(id)
      # Set all values to values read from /etc/audit/auditd.conf
      Builtins.foreach(["dispatcher", "disp_qos"]) do |key|
        UI.ChangeWidget(Id(key), :Value, AuditLaf.GetAuditdOption(key))
      end

      Builtins.y2milestone("Init dispatcher dialog")

      nil
    end

    # Handle actions of dispatcher dialog (button 'Select file')
    def HandleDispatcherDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")

      Builtins.y2milestone("HandleDispatcherDialog got action: %1", action)

      if action == "select_disp"
        file_name = UI.AskForExistingFile(
          "/sbin",
          "*",
          _("Select the dispatcher program")
        )

        UI.ChangeWidget(Id("dispatcher"), :Value, file_name)
        Builtins.y2milestone("Dispatcher program set to: %1", file_name)
      end
      nil
    end

    # Store all settings made in dispatcher dialog
    def StoreDispatcherDialog(id, event)
      event = deep_copy(event)
      # Store all values in SETTINGS
      Builtins.foreach(["dispatcher", "disp_qos"]) do |key|
        AuditLaf.SetAuditdOption(
          key,
          Convert.to_string(UI.QueryWidget(Id(key), :Value))
        )
      end

      AuditLaf.SetDataModified

      Builtins.y2milestone("Store dispatcher dialog")

      nil
    end

    # Init disk space dialog (set values to values read with AuditLad::Read())
    def InitDiskspaceSettingsDialog(id)
      UI.ChangeWidget(Id("space_left"), :ValidChars, "0123456789")
      UI.ChangeWidget(Id("admin_space_left"), :ValidChars, "0123456789")

      # Set all values to values read from /etc/audit/auditd.conf
      Builtins.foreach(["space_left", "action_mail_acct", "admin_space_left"]) do |key|
        UI.ChangeWidget(Id(key), :Value, AuditLaf.GetAuditdOption(key))
      end

      Builtins.foreach(
        [
          "space_left_action",
          "admin_space_left_action",
          "disk_full_action",
          "disk_error_action"
        ]
      ) do |key|
        if Builtins.toupper(
            Builtins.substring(AuditLaf.GetAuditdOption(key), 0, 4)
          ) == "EXEC"
          UI.ChangeWidget(Id(key), :Value, "EXEC")
          UI.ChangeWidget(Id(Ops.add(key, "_exec")), :Enabled, true)
          UI.ChangeWidget(
            Id(Ops.add(key, "_exec")),
            :Value,
            Builtins.substring(AuditLaf.GetAuditdOption(key), 5)
          )
        else
          UI.ChangeWidget(
            Id(key),
            :Value,
            Builtins.toupper(AuditLaf.GetAuditdOption(key))
          )
          UI.ChangeWidget(Id(Ops.add(key, "_exec")), :Enabled, false)
        end
      end

      Builtins.y2milestone("Init disk space settings")

      nil
    end

    # Handle actions of disk space
    def HandleDiskspaceSettingsDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")
      Builtins.y2milestone(
        "HandleDiskspaceSettingsDialog got action: %1",
        action
      )

      actions_list = [
        "space_left_action",
        "admin_space_left_action",
        "disk_full_action",
        "disk_error_action"
      ]

      if Ops.is_string?(action) &&
          Builtins.contains(actions_list, Convert.to_string(action))
        option = Convert.to_string(
          UI.QueryWidget(Id(Convert.to_string(action)), :Value)
        )
        Builtins.y2milestone("Option: %1", option)

        if option == "EXEC"
          UI.ChangeWidget(
            Id(Ops.add(Convert.to_string(action), "_exec")),
            :Enabled,
            true
          )
        else
          UI.ChangeWidget(
            Id(Ops.add(Convert.to_string(action), "_exec")),
            :Enabled,
            false
          )
        end
      end

      nil
    end

    def CheckExec(file, key)
      # Check the executable like done in audit package (see audit-1.7.7/src/auditd-config.c)
      ret = true
      # Second part of an error message: the value won't be changed because of previous error
      message = Builtins.sformat(_("Value of '%1' remains unchanged."), key)

      if !FileUtils.Exists(file)
        Report.Error(
          Ops.add(Builtins.sformat(_("%1 doesn't exist.\n"), file), message)
        )
        ret = false
      elsif !FileUtils.IsFile(file)
        Report.Error(
          Ops.add(
            Builtins.sformat(_("%1 is not a regular file.\n"), file),
            message
          )
        )
        ret = false
      elsif FileUtils.GetOwnerUserID(file) != 0
        Report.Error(
          Ops.add(Builtins.sformat(_("%1 not owned by root.\n"), file), message)
        )
        ret = false
      else
        # check permissions
        output = SCR.Execute(
          path(".target.bash_output"),
          "/usr/bin/ls -al ${file.shellescape}"
        )

        if Builtins.substring(Ops.get_string(output, "stdout", ""), 0, 10) != "-rwxr-x---"
          Report.Error(
            Ops.add(
              Builtins.sformat(
                _("File permissions of %1 NOT set to -rwxr-x---.\n"),
                file
              ),
              message
            )
          )
          ret = false
        end
      end

      ret
    end

    # Store all settings made in disk space dialog
    def StoreDiskspaceSettingsDialog(id, event)
      event = deep_copy(event)
      option = ""
      exec = ""

      Builtins.foreach(["space_left", "action_mail_acct", "admin_space_left"]) do |key|
        AuditLaf.SetAuditdOption(
          key,
          Convert.to_string(UI.QueryWidget(Id(key), :Value))
        )
      end

      Builtins.foreach(
        [
          "space_left_action",
          "admin_space_left_action",
          "disk_full_action",
          "disk_error_action"
        ]
      ) do |key|
        option = Convert.to_string(UI.QueryWidget(Id(key), :Value))
        if option == "EXEC"
          exec = Convert.to_string(
            UI.QueryWidget(Id(Ops.add(key, "_exec")), :Value)
          )
          if CheckExec(exec, key)
            AuditLaf.SetAuditdOption(key, Ops.add(Ops.add(option, " "), exec))
          end
        else
          AuditLaf.SetAuditdOption(key, option)
        end
      end

      AuditLaf.SetDataModified

      Builtins.y2milestone("Store disk space settings")

      nil
    end

    # Init rules dialog
    def InitRulesDialog(id)
      rules = ""
      combo_box_id = "disabled"

      if id == "restore" || id == "reset"
        rules = AuditLaf.GetInitialRules
      else
        rules = AuditLaf.GetRules
      end

      UI.ChangeWidget(Id("rules"), :Value, rules)
      rules_list = Builtins.splitstring(rules, "\n")

      Builtins.foreach(rules_list) do |rule|
        if Builtins.regexpmatch(rule, "^[ /t]*-e[ /t]*2")
          combo_box_id = "locked"
        elsif Builtins.regexpmatch(rule, "^[ /t]*-e[ /t]*1")
          combo_box_id = "enabled"
        elsif Builtins.regexpmatch(rule, "^[ /t]*-e[ /t]*0")
          combo_box_id = "disabled"
        end
      end
      UI.ChangeWidget(Id("audit_enabled"), :Value, combo_box_id)

      Builtins.y2milestone("Init rules dialog")

      nil
    end

    # Reset rules - called if button 'Restore and Reset' is pressed or if the user
    # aborts configuration after doing 'Check Syntax' (which changes the rules).
    def ResetRules
      if AuditLaf.RulesAlreadyLocked
        # Warning - the audit configuration is locked, reset impossible
        Report.Warning(
          _(
            "The rules are already locked, a reset is impossible.\n" +
              "\n" +
              "If you want to unlock, set the enabled flag accordingly and\n" +
              "finish the configuration. Afterwards a reboot is required."
          )
        )
      else
        Builtins.y2milestone("Calling auditctl -D")

        exit_code = SCR.Execute(path(".target.bash"), "/usr/sbin/auditctl -D")

        Builtins.y2milestone("Calling auditctl -R /etc/audit/audit.rules")

        if exit_code == 0
          exit_code = SCR.Execute(
            path(".target.bash"),
            "/usr/sbin/auditctl -R /etc/audit/audit.rules"
          )
        end

        if exit_code == 0
          # Report success
          Popup.Message(_("Rules successfully restored"))
          AuditLaf.SetRulesChanged(false)
        else
          # Report error - error during reset
          Report.Error(_("Cannot reset rules. Check /etc/audit/audit.rules."))
        end
      end

      nil
    end

    # Handle actions of rules dialog
    def HandleRulesDialog(id, event)
      event = deep_copy(event)
      action = Ops.get(event, "ID")
      Builtins.y2milestone("HandleRulesDialog got action: %1", action)

      if action == "audit_enabled"
        rule = ""
        rules_list = []

        value = Convert.to_string(UI.QueryWidget(Id("audit_enabled"), :Value))
        rules = Convert.to_string(UI.QueryWidget(Id("rules"), :Value))

        Builtins.y2milestone("Setting status to: %1", value)

        case value
          when "locked"
            rule = "-e 2"
          when "enabled"
            rule = "-e 1"
          when "disabled"
            rule = "-e 0"
        end

        if rules != nil && rules != ""
          rules_list = Builtins.splitstring(rules, "\n")
        end

        rule_found = false

        if rules_list != []
          new_rules = Builtins.maplist(rules_list) do |line|
            if Builtins.regexpmatch(line, "^[ /t]*-e")
              rule_found = true
              next rule
            else
              next line
            end
          end
          new_rules = Builtins.add(new_rules, rule) if !rule_found

          UI.ChangeWidget(
            Id("rules"),
            :Value,
            Builtins.mergestring(new_rules, "\n")
          )
        end
      elsif action == "restore"
        InitRulesDialog("restore")
      elsif action == "reset"
        InitRulesDialog("reset")

        ResetRules()
      elsif action == "test"
        go_on = true

        rules = Convert.to_string(UI.QueryWidget(Id("rules"), :Value))
        rules_list = Builtins.splitstring(rules, "\n")

        if AuditLaf.RulesAlreadyLocked
          Report.Warning(
            _(
              "The rules are already locked.\n" +
                "\n" +
                "A test is impossible because sending new rules\n" +
                "will cause an error.\n"
            )
          )
          go_on = false
        end

        Builtins.foreach(rules_list) do |rule|
          if Builtins.regexpmatch(rule, "^[ /t]*-e[ /t]*2")
            Report.Warning(
              _(
                "Lock is set in audit.rules (-e 2).\n" +
                  "\n" +
                  "It makes no sense to continue, because the rules will\n" +
                  "be locked until next boot.\n"
              )
            )
            go_on = false
          end
        end if go_on

        if go_on
          tmpfile = Ops.add(
            Convert.to_string(SCR.Read(path(".target.tmpdir"))),
            "/rules_test_file"
          )

          success = SCR.Write(path(".target.string"), tmpfile, rules)
          if success
            Builtins.y2milestone("Calling auditctl -R %1", tmpfile)

            output = SCR.Execute(
              path(".target.bash_output"),
              "/usr/sbin/auditctl -R #{tmpfile.shellescape}"
            )

            AuditLaf.SetRulesChanged(true)

            if Ops.get_integer(output, "exit", 0) != 0
              Report.Error(Ops.get_string(output, "stderr", ""))
            else
              Popup.Message(_("Success"))
            end
          else
            Report.Error(_("Cannot create tmp file for rules."))
          end
        end
      elsif action == "load"
        file_name = UI.AskForExistingFile(
          "/usr/share/doc/packages/audit",
          "*.rules",
          _("Select an example")
        )
        if file_name != nil
          example_rules = Convert.to_string(
            SCR.Read(path(".target.string"), file_name))
          UI.ChangeWidget(Id("rules"), :Value, example_rules)
          Builtins.y2milestone("Example rules loaded: %1", file_name)
        end
      end

      nil
    end

    # Store the rules edited in rules dialog
    def StoreRulesDialog(id, event)
      event = deep_copy(event)
      rules = Convert.to_string(UI.QueryWidget(Id("rules"), :Value))

      AuditLaf.SetRules(rules)

      AuditLaf.SetDataModified

      Builtins.y2debug("RULES: %1", rules)
      Builtins.y2milestone("Store rules dialog")

      nil
    end



    # Called if 'Abort' button is pressed in main dialog.
    # If the rules are changed by a syntax check the changes will be reseted.
    def Reset
      ResetRules() if AuditLaf.RulesChanged

      nil
    end

    def CheckSettings
      ret = :next
      AuditLaf.SetRulesLocked(false)

      rules = AuditLaf.GetRules
      rules_list = Builtins.splitstring(rules, "\n")

      Builtins.y2milestone("Checking rules...")

      Builtins.foreach(rules_list) do |rule|
        if Builtins.regexpmatch(rule, "^[ /t]*-e[ /t]*2")
          yes = Popup.AnyQuestion(
            _("Lock set"),
            _(
              "The audit configuration is locked (option -e 2).\n" +
                "This means the rules are locked until next boot!\n" +
                "If you really want this, make sure '-e 2' is the last entry\n" +
                "in the rules file. If not, either enable or disable auditing.\n" +
                "To check or change the rules, go back to the rules editor.\n"
            ),
            Label.ContinueButton,
            Label.BackButton,
            :focus_no
          )
          if yes
            ret = :next
          else
            ret = :back
            AuditLaf.SetRulesLocked(true)
          end
        end
      end

      ret
    end
  end
end
