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

# File:	include/audit-laf/wizards.ycp
# Package:	Configuration of Linux Auditing
# Summary:	Wizards definitions
# Authors:	Gabriele Mohr <gs@suse.de>
#
module Yast
  module AuditLafWizardsInclude
    def initialize_audit_laf_wizards(include_target)
      Yast.import "UI"

      textdomain "audit-laf"

      Yast.import "Sequencer"
      Yast.import "Wizard"
      Yast.import "CWM"
      Yast.import "CWMTab"

      Yast.include include_target, "audit-laf/complex.rb"
      Yast.include include_target, "audit-laf/dialogs.rb"
    end

    # Main workflow of the LAF Auditing configuration
    # @return sequence result
    def MainSequence
      widgets = {
        "log"   => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "logfile_settings", ""),
          "custom_widget" => LogfileSettingsDialogContent(),
          "handle"        => fun_ref(
            method(:HandleLogfileSettingsDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitLogfileSettingsDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreLogfileSettingsDialog),
            "void (string, map)"
          )
        },
        "disp"  => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "dispatcher", ""),
          "custom_widget" => DispatcherDialogContent(),
          "handle"        => fun_ref(
            method(:HandleDispatcherDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(
            method(:InitDispatcherDialog),
            "void (string)"
          ),
          "store"         => fun_ref(
            method(:StoreDispatcherDialog),
            "void (string, map)"
          )
        },
        "disk"  => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "diskspace_settings", ""),
          "custom_widget" => DiskspaceSettingsDialogContent(),
          "init"          => fun_ref(
            method(:InitDiskspaceSettingsDialog),
            "void (string)"
          ),
          "handle"        => fun_ref(
            method(:HandleDiskspaceSettingsDialog),
            "symbol (string, map)"
          ),
          "store"         => fun_ref(
            method(:StoreDiskspaceSettingsDialog),
            "void (string, map)"
          )
        },
        "rules" => {
          "widget"        => :custom,
          "help"          => Ops.get_string(@HELPS, "audit_rules", ""),
          "custom_widget" => RulesDialogContent(),
          "handle"        => fun_ref(
            method(:HandleRulesDialog),
            "symbol (string, map)"
          ),
          "init"          => fun_ref(method(:InitRulesDialog), "void (string)"),
          "store"         => fun_ref(
            method(:StoreRulesDialog),
            "void (string, map)"
          )
        }
      }

      tabs = {
        "logfile_settings"   => {
          # Header of tab in tab widget
          "header"       => _("&Log File"),
          "widget_names" => ["log"],
          "contents"     => LogfileSettingsDialogContent()
        },
        "dispatcher"         => {
          # Header of tab in tab widget
          "header"       => _("&Dispatcher"),
          "widget_names" => ["disp"],
          "contents"     => DispatcherDialogContent()
        },
        "diskspace_settings" => {
          # Header of tab in tab widget
          "header"       => _("Disk &Space"),
          "widget_names" => ["disk"],
          "contents"     => DiskspaceSettingsDialogContent()
        },
        "audit_rules"        => {
          # Header of tab in tab widget
          # (auditctl is a program which sends the rules to the audit subsystem)
          "header"       => _(
            "&Rules for 'auditctl'"
          ),
          "widget_names" => ["rules"],
          "contents"     => RulesDialogContent()
        }
      }

      ini_tab = ""

      if AuditLaf.RulesLocked
        ini_tab = "audit_rules"
      else
        ini_tab = "logfile_settings"
      end

      wd = {
        "tab" => CWMTab.CreateWidget(
          {
            "tab_order"    => [
              "logfile_settings",
              "dispatcher",
              "diskspace_settings",
              "audit_rules"
            ],
            "tabs"         => tabs,
            "widget_descr" => widgets,
            "initial_tab"  => ini_tab
          }
        )
      }

      contents = VBox("tab")

      w = CWM.CreateWidgets(
        ["tab"],
        Convert.convert(
          wd,
          :from => "map <string, any>",
          :to   => "map <string, map <string, any>>"
        )
      )

      # Initialization dialog caption
      caption = _("Configuration of Linux Audit Framework (LAF)")
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.FinishButton
      )
      Wizard.DisableBackButton
      Wizard.SetDesktopTitleAndIcon("org.opensuse.yast.AuditLAF")

      CWM.Run(w, { :abort => fun_ref(method(:ReallyAbort), "boolean ()") })
    end

    # Whole configuration of LAF Auditing
    # @return sequence result
    def AuditLafSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "check" => lambda { CheckSettings() },
        "reset" => lambda { Reset() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => "reset", :next => "check" },
        "check"    => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of LAF Auditing but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def AuditLafAutoSequence
      # Initialization dialog caption
      caption = _("Configuration of Linux Audit Framework (LAF)")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = MainSequence()

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
