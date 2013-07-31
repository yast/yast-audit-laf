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

# File:	modules/AuditLaf.ycp
# Package:	Configuration of audit-laf
# Summary:	AuditLaf settings, input and output functions
# Authors:	Gabriele Mohr <gs@suse.de>
#
#
# Representation of the configuration of audit-laf.
# Input and output routines.
require "yast"

module Yast
  class AuditLafClass < Module
    def main
      Yast.import "UI"
      textdomain "audit-laf"

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "Message"
      Yast.import "Popup"
      Yast.import "Mode"
      Yast.import "FileUtils"
      Yast.import "Service"
      Yast.import "Stage"
      Yast.import "Package"


      # Data was modified?
      @modified = false


      @proposal_valid = false

      # Filename (path) rules file
      @rules_file = "/etc/audit/audit.rules"

      # Filename (path) config file
      @config_file = "/etc/audit/auditd.conf"

      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

      # Option "Lock rules" is set (-e 2)
      @rules_locked = false

      # The rules have been changed (sent to 'autitctl' to check the syntax)
      @rules_changed = false

      #
      # Settings: Define all variables needed for the configuration of the audit daemon
      #

      # map of audit settings (from /etc/audit/auditd.conf)
      @SETTINGS = {}

      # default settings for /etc/audit/auditd.conf
      @DEFAULT_CONFIG = {
        "log_file"                => "/var/log/audit/audit.log",
        "log_format"              => "RAW",
        "priority_boost"          => "3",
        "flush"                   => "INCREMENTAL",
        "freq"                    => "20",
        "num_logs"                => "4",
        "dispatcher"              => "/sbin/audispd",
        "disp_qos"                => "lossy",
        "name_format"             => "NONE",
        "max_log_file"            => "5",
        "max_log_file_action"     => "ROTATE",
        "space_left"              => "75",
        "space_left_action"       => "SYSLOG",
        "action_mail_acct"        => "root",
        "admin_space_left"        => "50",
        "admin_space_left_action" => "SUSPEND",
        "disk_full_action"        => "SUSPEND",
        "disk_error_action"       => "SUSPEND"
      }

      # Save settings initially read from /etc/audit/auditd.conf to be able
      # to decide whether changes are made
      @INITIAL_SETTINGS = {}

      # Rules for the subsystem audit (passed via auditctl).
      # Initially read from /etc/audit/audit.rules and edited in
      # the rules editor.
      @RULES = ""

      # Save rules from /etc/audit/audit.rules to be able to restore it
      @INITIAL_RULES = ""
    end

    def SetRulesLocked(value)
      @rules_locked = value

      nil
    end

    def RulesLocked
      @rules_locked
    end

    def SetRulesChanged(value)
      @rules_changed = value

      nil
    end

    def RulesChanged
      @rules_changed
    end

    # Return rules file path
    def GetRulesFile
      @rules_file
    end

    def GetConfigFile
      @config_file
    end

    # Testing only
    def GetWatches
      [
        "exit,always watch=/etc/passwd perm=rwx",
        "entry,always watch=/etc/sysconfig/yast2 perm=rwx"
      ]
    end

    # Data was modified?
    # @return true if modified
    def Modified
      Builtins.y2milestone("modified=%1", @modified)
      @modified
    end

    # Mark as modified, for Autoyast.
    def SetModified(value)
      @modified = value

      nil
    end



    def ProposalValid
      @proposal_valid
    end

    def SetProposalValid(value)
      @proposal_valid = value

      nil
    end

    # @return true if module is marked as "write only" (don't start services etc...)
    def WriteOnly
      @write_only
    end

    # Set write_only flag (for autoinstalation).
    def SetWriteOnly(value)
      @write_only = value

      nil
    end

    #   Returns a confirmation popup dialog whether user wants to really abort.
    def Abort
      Popup.ReallyAbort(Modified())
    end

    # Checks whether an Abort button has been pressed.
    # If so, calls function to confirm the abort call.
    #
    # @return [Boolean] true if abort confirmed
    def PollAbort
      # Do not check UI when running in CommandLine mode
      return false if Mode.commandline

      return Abort() if UI.PollInput == :abort

      false
    end

    def RulesAlreadyLocked
      output = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), "LANG=POSIX auditctl -s")
      )
      Builtins.y2milestone("auditctl: %1", output)

      audit_status = Ops.get_string(output, "stdout", "")

      if Builtins.regexpmatch(audit_status, "^.*enabled=2.*")
        return true
      else
        return false
      end
    end

    def AuditStatus
      output = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), "LANG=POSIX auditctl -s")
      )
      Builtins.y2milestone("auditctl: %1", output)

      audit_status = Ops.get_string(output, "stdout", "")

      if Builtins.regexpmatch(audit_status, "^.*enabled=2.*")
        return _("The rules for auditctl are locked.")
      elsif Builtins.regexpmatch(audit_status, "^.*enabled=1.*")
        return _("Auditing enabled")
      else
        return _("Auditing disabled")
      end
    end

    #  Set data modified only if really has changed
    def SetDataModified
      if @INITIAL_SETTINGS != @SETTINGS || @INITIAL_RULES != @RULES
        @modified = true
      else
        @modified = false
      end

      nil
    end

    # Get value of given option from SEETINGS
    def GetAuditdOption(key)
      Ops.get(@SETTINGS, key, Ops.get(@DEFAULT_CONFIG, key, ""))
    end

    # Set option to given value in SETTINGS

    def SetAuditdOption(key, value)
      # Don't set empty values (seems that 'auditd' doesn't like it)
      if value != ""
        Ops.set(@SETTINGS, key, value)
        Builtins.y2milestone("Setting %1 to %2", key, value)
        return true
      else
        return false
      end
    end

    # Get the current rules
    def GetRules
      @RULES
    end

    def GetInitialRules
      @INITIAL_RULES
    end

    # Set rules
    def SetRules(rules)
      if rules != nil && rules != ""
        @RULES = rules
        return true
      else
        return false
      end
    end

    # Read rules from audit.rules
    def ReadAuditRules
      rules = Convert.to_string(SCR.Read(path(".target.string"), @rules_file))

      if rules != nil && rules != ""
        @RULES = rules
        # additionally save initial rules
        @INITIAL_RULES = rules
        return true
      else
        return false
      end
    end

    # Write rules to audit.rules
    def WriteAuditRules
      success = SCR.Write(path(".target.string"), @rules_file, @RULES)

      success
    end

    # Check whether package 'audit' is installed and install it if user agrees
    def CheckInstalledPackages
      ret = false

      # skip it during initial and second stage or when create AY profile
      return true if Stage.cont || Stage.initial || Mode.config
      Builtins.y2milestone("Check whether package 'audit' is installed")

      if !Package.InstallMsg(
          "audit",
          _(
            "<p>To continue the configuration of Linux Auditing, the package <b>%1</b> must be installed.</p>"
          ) +
            _("<p>Install it now?</p>")
        )
        Popup.Error(Message.CannotContinueWithoutPackagesInstalled)
      else
        ret = true
      end
      ret
    end

    # Read settings from auditd.conf
    # @return true on success
    def ReadAuditdSettings
      return false if !FileUtils.Exists(@config_file)

      optionsList = SCR.Dir(path(".auditd"))
      Builtins.y2milestone("List of options: %1", optionsList)

      # list all options set in auditd.conf
      Builtins.foreach(SCR.Dir(path(".auditd"))) do |key|
        # and read the value for each of them
        val = Convert.to_string(SCR.Read(Builtins.add(path(".auditd"), key)))
        Ops.set(@SETTINGS, key, val) if val != nil
      end

      # additionally save initial settings
      @INITIAL_SETTINGS = deep_copy(@SETTINGS)

      Builtins.y2milestone("%1 has been read: %2", @config_file, @SETTINGS)
      true
    end

    def CheckAuditdStatus
      auditd_stat = Service.Status("auditd")

      if auditd_stat != 0
        Report.Error(
          _(
            "Cannot start the audit daemon.\n" +
              "Please check /var/log/messages for auditd errors.\n" +
              "You can use the module 'System Log' from group\n" +
              "'Miscellaneous' in YaST Control Center."
          )
        )
        return false
      else
        return true
      end
    end

    # Read all auditd settings
    # @return true on success
    def Read
      success = true

      # AuditLaf read dialog caption
      caption = _("Initializing Audit Configuration")

      # Set the right number of stages
      steps = 3

      sl = 500
      Builtins.sleep(sl)

      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/4
          _("Check for installed packages"),
          # Progress stage 2/4
          _("Read the configuration of auditd"),
          # Progress stage 3/4
          _("Read the rules file"),
          # Progress stage 4/4
          _("Check status of auditd")
        ],
        [
          # Progress stage 1/4
          _("Checking for packages..."),
          # Progress step 2/4
          _("Reading the configuration..."),
          # Progress step 3/4
          _("Reading the rules file..."),
          # Progress step 4/4
          _("Checking status..."),
          Message.Finished
        ],
        ""
      )

      # read database
      return false if PollAbort()
      Progress.NextStage

      installed = CheckInstalledPackages()

      return false if !installed
      Builtins.sleep(sl)

      return false if PollAbort()
      Progress.NextStep

      success = ReadAuditdSettings()

      # Log the status of the audit system
      output = Convert.to_map(
        SCR.Execute(path(".target.bash_output"), "auditctl -s")
      )
      Builtins.y2milestone("auditctl: %1", output)

      # Report error
      Report.Error(_("Cannot read auditd.conf.")) if !success
      Builtins.sleep(sl)

      # read another database
      return false if PollAbort()
      Progress.NextStep

      success = ReadAuditRules()

      # Error message
      Report.Error(_("Cannot read audit.rules.")) if !success
      Builtins.sleep(sl)

      # read current settings
      return false if PollAbort()
      Progress.NextStage
      # Error message
      Report.Error(Message.CannotReadCurrentSettings) if false
      Builtins.sleep(sl)

      Progress.NextStage
      auditd_stat = Service.Status("auditd")
      Builtins.y2milestone(
        "Auditd running: %1",
        auditd_stat == 0 ? "yes" : "no"
      )

      apparmor_stat = Convert.to_integer(
        SCR.Execute(path(".target.bash"), "rcapparmor status")
      )

      Builtins.y2milestone(
        "Apparmor loaded: %1",
        apparmor_stat == 0 ? "yes" : "no"
      )

      if auditd_stat != 0
        message = _(
          "The audit daemon doesn't run.\nDo you want to start it now?"
        )

        if apparmor_stat == 0
          message = _(
            " The 'apparmor' kernel module is loaded.\n" +
              "The kernel uses a running audit daemon to log audit\n" +
              "events to /var/log/audit/audit.log (default). \n" +
              "Do you want to start the daemon now?"
          )
        end

        start = Popup.YesNoHeadline(_("Audit daemon not running."), message)
        if start
          exit_code = Service.RunInitScript("auditd", "start")
          if exit_code != 0
            go_on = Popup.ContinueCancelHeadline(
              _("Cannot start the audit daemon."),
              _(
                "The rules may be locked.\n" +
                  "Continue to check the rules. You can change\n" +
                  "the 'Enabled Flag', but to activate the change\n" +
                  "a reboot is required afterwards.\n"
              )
            )
            if go_on
              return true
            else
              return false
            end
          else
            CheckAuditdStatus()
            return true
          end
        end
      end

      return false if PollAbort()
      @modified = false
      true
    end

    # Write settings to auditd.conf
    # @return true on success
    def WriteAuditdSettings
      ret = true

      return false if !FileUtils.Exists(@config_file)

      # write all options to auditd.conf
      Builtins.foreach(@SETTINGS) do |key, value|
        # and write each value
        success = SCR.Write(Builtins.add(path(".auditd"), key), value)
        ret = false if !success
      end

      # This is very important
      # it flushes the cache, and stores the configuration on the disk
      SCR.Write(path(".auditd"), nil)

      if ret
        Builtins.y2milestone("%1 has been written: %2", @config_file, @SETTINGS)
      end

      ret
    end

    # Write all auditd settings
    # @return true on success
    def Write
      go_on = false
      ret = true

      # Auditd read dialog caption
      caption = _("Saving Audit Configuration")

      # set the right number of stages
      steps = 2

      sl = 500
      Builtins.sleep(sl)

      # Names of the stages
      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Write the settings"),
          # Progress stage 2/2
          _("Write the rules")
        ],
        [
          # Progress step 1/2
          _("Writing the settings..."),
          # Progress step 2/2
          _("Writing the rules..."),
          Message.Finished
        ],
        ""
      )

      # check first whether rules are already locked
      locked = RulesAlreadyLocked()

      Builtins.y2milestone(
        "Rules already locked: %1",
        locked ? "true" : "false"
      )

      if locked
        write_rules = Popup.YesNoHeadline(
          _("The rules are already locked."),
          _(
            "Do you want to change the 'Enabled Flag'?\n" +
              "If yes, the new rules will be written to /etc/audit/audit.rules.\n" +
              "Reboot the system afterwards for the change to take effect.\n"
          )
        )
        WriteAuditRules() if write_rules

        # don't try to restart the daemon - daemon will stop
        return false
      end

      # write settings
      return false if PollAbort()
      Progress.NextStage

      write_success = WriteAuditdSettings()

      if write_success
        # restart auditd
        exit_code = Service.RunInitScript("auditd", "restart")
        Builtins.y2milestone("'auditd restart' returned: %1", exit_code)

        if exit_code != 0
          # Error message
          Report.Error(_("Restart of the audit daemon failed."))
          ret = false
        else
          go_on = true
        end
      else
        # Error message
        Report.Error(_("Cannot write settings to auditd.conf."))
        ret = false
      end

      Builtins.sleep(sl)

      return false if PollAbort()

      Progress.NextStage

      if go_on
        write_success = WriteAuditRules()

        # Error message
        if write_success
          # call auditctl -R audit.rules
          Builtins.y2milestone("Calling auditctl -R /etc/audit/audit.rules")

          output = Convert.to_map(
            SCR.Execute(
              path(".target.bash_output"),
              "auditctl -R /etc/audit/audit.rules"
            )
          )

          if Ops.get_integer(output, "exit", 0) != 0
            Report.Error(
              Builtins.sformat(
                "%1\n%2",
                Ops.get_string(output, "stderr", ""),
                # Error message, rules cannot be set
                _("Start yast2-audit-laf again and check the rules.")
              )
            )
            ret = false
          end
        else
          Report.Error(_("Cannot write settings to auditd.rules."))
          ret = false
        end

        Builtins.sleep(sl)
      end

      # Finally check status of auditd (if restart has worked but daemon exited afterwards)
      ret = false if !CheckAuditdStatus()

      return false if PollAbort()

      Builtins.y2milestone("Auditd::Write() returns: %1", ret)
      ret
    end

    # Get all audit settings from the first parameter
    # (For use by autoinstallation.)
    # @param [Hash] settings The YCP structure to be imported.
    # @return [Boolean] True on success
    def Import(settings)
      settings = deep_copy(settings)
      @SETTINGS = Convert.convert(
        Ops.get(settings, "auditd", @DEFAULT_CONFIG),
        :from => "any",
        :to   => "map <string, string>"
      )
      @RULES = Ops.get_string(settings, "rules", "")

      SetModified(true)
      Builtins.y2milestone("Configuration has been imported")

      true
    end

    # Dump the auditd settings and the rules to a single map
    # (For use by autoinstallation.)
    # @return [Hash] Dumped settings (later acceptable by Import ())
    def Export
      { "auditd" => @SETTINGS, "rules" => @RULES }
    end

    # Create a textual summary and a list of unconfigured cards
    # @return summary of the current configuration
    def Summary
      summary = ""

      summary = Summary.AddLine(
        summary,
        Builtins.sformat("%1: %2", _("Log file"), GetAuditdOption("log_file"))
      )
      summary = Summary.AddLine(summary, AuditStatus())

      Builtins.y2milestone("Summary: %1", summary)

      # Configuration summary text for autoyast
      summary
    end

    # Create an overview table with all configured cards
    # @return table items
    def Overview
      # TODO FIXME: your code here...
      []
    end

    # Return packages needed to be installed and removed during
    # Autoinstallation to insure module has all needed software
    # installed.
    # @return [Hash] with 2 lists.
    def AutoPackages
      { "install" => ["audit"], "remove" => [] }
    end

    publish :function => :SetRulesLocked, :type => "void (boolean)"
    publish :function => :RulesLocked, :type => "boolean ()"
    publish :function => :SetRulesChanged, :type => "void (boolean)"
    publish :function => :RulesChanged, :type => "boolean ()"
    publish :function => :GetRulesFile, :type => "string ()"
    publish :function => :GetConfigFile, :type => "string ()"
    publish :function => :GetWatches, :type => "list <string> ()"
    publish :function => :Modified, :type => "boolean ()"
    publish :function => :SetModified, :type => "void (boolean)"
    publish :function => :ProposalValid, :type => "boolean ()"
    publish :function => :SetProposalValid, :type => "void (boolean)"
    publish :function => :WriteOnly, :type => "boolean ()"
    publish :function => :SetWriteOnly, :type => "void (boolean)"
    publish :function => :Abort, :type => "boolean ()"
    publish :function => :PollAbort, :type => "boolean ()"
    publish :function => :RulesAlreadyLocked, :type => "boolean ()"
    publish :function => :AuditStatus, :type => "string ()"
    publish :function => :SetDataModified, :type => "void ()"
    publish :function => :GetAuditdOption, :type => "string (string)"
    publish :function => :SetAuditdOption, :type => "boolean (string, string)"
    publish :function => :GetRules, :type => "string ()"
    publish :function => :GetInitialRules, :type => "string ()"
    publish :function => :SetRules, :type => "boolean (string)"
    publish :function => :CheckAuditdStatus, :type => "boolean ()"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :Import, :type => "boolean (map)"
    publish :function => :Export, :type => "map ()"
    publish :function => :Summary, :type => "string ()"
    publish :function => :Overview, :type => "list ()"
    publish :function => :AutoPackages, :type => "map ()"
  end

  AuditLaf = AuditLafClass.new
  AuditLaf.main
end
