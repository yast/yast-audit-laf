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

# File:	include/audit-laf/dialogs.ycp
# Package:	Configuration of Linux Auditing
# Summary:	Dialogs definitions
# Authors:	Gabriele Mohr <gs@suse.de>
#
module Yast
  module AuditLafDialogsInclude
    def initialize_audit_laf_dialogs(include_target)
      textdomain "audit-laf"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "AuditLaf"

      Yast.include include_target, "audit-laf/helps.rb"

      @mbox_x = 1
      @mbox_y = Convert.convert(0.5, :from => "float", :to => "integer")

      @actions_list = [
        Item(Id("IGNORE"), "IGNORE"),
        Item(Id("SYSLOG"), "SYSLOG", true),
        Item(Id("SUSPEND"), "SUSPEND"),
        Item(Id("SINGLE"), "SINGLE"),
        Item(Id("HALT"), "HALT"),
        Item(Id("EXEC"), "EXEC"),
        Item(Id("EMAIL"), "EMAIL")
      ]

      @error_actions_list = [
        Item(Id("IGNORE"), "IGNORE"),
        Item(Id("SYSLOG"), "SYSLOG", true),
        Item(Id("SUSPEND"), "SUSPEND"),
        Item(Id("SINGLE"), "SINGLE"),
        Item(Id("HALT"), "HALT"),
        Item(Id("EXEC"), "EXEC")
      ]
    end

    def LogfileSettingsDialogContent
      MarginBox(
        @mbox_x,
        @mbox_y,
        VBox(
          VStretch(),
          Frame(
            # Frame label
            _("General Settings"),
            VBox(
              VSquash(
                HBox(
                  # InputField label
                  InputField(Id("log_file"), Opt(:hstretch), _("&Log File")),
                  HSpacing(2.0),
                  VBox(
                    VSpacing(),
                    # PushButton label
                    Bottom(PushButton(Id("select_file"), _("Select Fi&le")))
                  )
                )
              ),
              VBox(
                # ComboBox label - select format of logging
                HBox(
                  HWeight(
                    1,
                    ComboBox(
                      Id("log_format"),
                      _("&Format"),
                      [Item(Id("RAW"), "RAW", true), Item(Id("NOLOG"), "NOLOG")]
                    )
                  ),
                  HSpacing(2.0),
                  HWeight(1, Empty())
                ),
                HBox(
                  # ComboBox label - select how to flush data on disk
                  HWeight(
                    1,
                    ComboBox(
                      Id("flush"),
                      _("Fl&ush"),
                      [
                        Item(Id("NONE"), "NONE"),
                        Item(Id("INCREMENTAL"), "INCREMENTAL", true),
                        Item(Id("DATA"), "DATA"),
                        Item(Id("SYNC"), "SYNC")
                      ]
                    )
                  ),
                  HSpacing(2.0),
                  # InputField label - enter how many records to write before flush data to disk
                  HWeight(
                    1,
                    IntField(
                      Id("freq"),
                      Opt(:hstretch),
                      _("Fre&quency (Number of Records)"),
                      0,
                      10000,
                      20
                    )
                  )
                )
              )
            )
          ),
          VStretch(),
          Frame(
            # Frame label - data regarding size of log file and action to perform
            _("Size and Action"),
            HBox(
              # InputField label
              HWeight(
                1,
                InputField(Id("max_log_file"), _("Ma&x File Size (MB)"))
              ),
              HSpacing(2.0),
              # ComboBox label
              HWeight(
                1,
                ComboBox(
                  Id("max_log_file_action"),
                  _("M&aximum File Size Action"),
                  [
                    Item(Id("IGNORE"), "IGNORE"),
                    Item(Id("SYSLOG"), "SYSLOG", true),
                    Item(Id("SUSPEND"), "SUSPEND"),
                    Item(Id("ROTATE"), "ROTATE"),
                    Item(Id("KEEP_LOGS"), "KEEP_LOGS")
                  ]
                )
              ),
              HSpacing(2.0),
              # InputField label
              HWeight(
                1,
                IntField(
                  Id("num_logs"),
                  Opt(:hstretch),
                  _("&Number of Log Files"),
                  0,
                  99,
                  4
                )
              )
            )
          ),
          VStretch(),
          Frame(
            # Frame label - data regarding how to write computer names to the log file
            _("Computer Names"),
            HBox(
              # ComboBox label
              HWeight(
                1,
                ComboBox(
                  Id("name_format"),
                  Opt(:notify),
                  _("&Computer Name Format"),
                  [
                    Item(Id("NONE"), "NONE"),
                    Item(Id("HOSTNAME"), "HOSTNAME", true),
                    Item(Id("FQD"), "FQD"),
                    Item(Id("USER"), "USER")
                  ]
                )
              ),
              HSpacing(2.0),
              # InputField label
              HWeight(1, InputField(Id("name"), _("User Defined Name")))
            )
          ),
          VStretch()
        )
      )
    end

    def DispatcherDialogContent
      MarginBox(
        @mbox_x,
        @mbox_y,
        VBox(
          VSpacing(2.0),
          Frame(
            # Frame label - settings of the dispatcher program
            _("Dispatcher Settings"),
            VBox(
              VSquash(
                HBox(
                  # InputField label
                  InputField(
                    Id("dispatcher"),
                    Opt(:hstretch),
                    _("Dispatcher Program")
                  ),
                  HSpacing(2.0),
                  VBox(
                    VSpacing(),
                    # PushButton label
                    Bottom(PushButton(Id("select_disp"), _("Select Fi&le")))
                  )
                )
              ),
              # ComboBox label - communication between the audit daemon and the dispatcher program
              Left(
                ComboBox(
                  Id("disp_qos"),
                  _("C&ommunication"),
                  [
                    Item(Id("lossy"), "lossy", true),
                    Item(Id("lossless"), "lossless")
                  ]
                )
              )
            )
          ),
          VStretch()
        )
      )
    end

    def DiskspaceSettingsDialogContent
      MarginBox(
        @mbox_x,
        @mbox_y,
        VBox(
          VStretch(),
          Frame(
            # Frame label - keep it short!
            _("Value and Action for Space Is Starting to Run Low"),
            HBox(
              # InputField label - space on disk is starting to run low if the entered value is reached
              HWeight(
                1,
                InputField(Id("space_left"), _("&Space Left on Disk (MB)"))
              ),
              HSpacing(2.0),
              HWeight(
                1,
                ComboBox(
                  Id("space_left_action"),
                  Opt(:notify),
                  # ComboBox label - select an action which is performed if space on disk is low
                  _("&Action"),
                  @actions_list
                )
              ),
              HSpacing(1.0),
              # InputField label - enter the path to a script (which will be executed)
              HWeight(
                1,
                InputField(Id("space_left_action_exec"), _("Path to Script"))
              )
            )
          ),
          VStretch(),
          Frame(
            # Frame label - keep it short!
            _("Value and Action for Space Is Running Low"),
            HBox(
              # InputField label - space on disk is running low if the entered value is reached
              HWeight(
                1,
                InputField(Id("admin_space_left"), _("&Admin Space Left (MB) "))
              ),
              HSpacing(2.0),
              HWeight(
                1,
                ComboBox(
                  Id("admin_space_left_action"),
                  Opt(:notify),
                  # ComboBox label - select an action which is performed if space on disk is running low
                  _("Ac&tion"),
                  @actions_list
                )
              ),
              HSpacing(1.0),
              # InputField label - enter the path to a script (which will be executed)
              HWeight(
                1,
                InputField(
                  Id("admin_space_left_action_exec"),
                  _("Path to Script")
                )
              )
            )
          ),
          VStretch(),
          InputField(Id("action_mail_acct"), _("Action Mail Account")),
          VStretch(),
          Frame(
            # Frame label - keep it short!
            _("Action on Error or Disk Full"),
            VBox(
              HBox(
                HWeight(
                  1,
                  ComboBox(
                    Id("disk_full_action"),
                    Opt(:notify),
                    # ComboBox label - select an action which is performed if disk is full
                    _("Disk &Full Action"),
                    @error_actions_list
                  )
                ),
                HSpacing(2.0),
                # InputField label - enter the path to a script (which will be executed)
                HWeight(
                  1,
                  InputField(Id("disk_full_action_exec"), _("Path to Script"))
                )
              ),
              HBox(
                HWeight(
                  1,
                  ComboBox(
                    Id("disk_error_action"),
                    Opt(:notify),
                    # ComboBox label - select an action which is performed on error
                    _("Disk &Error Action"),
                    @error_actions_list
                  )
                ),
                HSpacing(2.0),
                # InputField label - enter the path to a script (which will be executed)
                HWeight(
                  1,
                  InputField(Id("disk_error_action_exec"), _("Path to Script"))
                )
              )
            )
          ),
          VStretch()
        )
      )
    end

    def RulesDialogContent
      MarginBox(
        @mbox_x,
        @mbox_y,
        VBox(
          VSpacing(0.2),
          VWeight(
            20,
            VBox(
              # label of a combo box with the possibilitiy to enable/disable auditing or lock the rules
              Left(
                ComboBox(
                  Id("audit_enabled"),
                  Opt(:notify),
                  _("&Set Enabled Flag"),
                  # combo box item
                  [
                    Item(Id("enabled"), _("Auditing enabled"), true),
                    # combo box item
                    Item(Id("disabled"), _("Auditing disabled")),
                    # combo box item
                    Item(Id("locked"), _("Rules are locked (until next boot)"))
                  ]
                )
              ),
              VStretch()
            )
          ),
          VSpacing(0.2),
          VWeight(
            90,
            VBox(
              # Label - describes what can be done in the editor
              Left(Label(_("Edit the rules for the audit subsystem here:"))),
              MultiLineEdit(Id("rules"), Opt(:vstretch), "&audit.rules")
            )
          ),
          VWeight(
            10,
            # label of a push button (please keep it short)
            HBox(
              PushButton(Id("test"), _("&Check Syntax")),
              HSpacing(2.0),
              # label of push button  (please keep it short)
              PushButton(Id("restore"), _("&Restore 'audit.rules'")),
              HSpacing(2.0),
              # label of push button  (please keep it short)
              PushButton(Id("reset"), _("R&estore and Reset")),
              HSpacing(2.0),
              # label of a push button
              PushButton(Id("load"), _("&Load "))
            )
          )
        )
      )
    end
  end
end
