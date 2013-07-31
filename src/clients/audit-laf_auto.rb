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

# File:	clients/audit-laf_auto.ycp
# Package:	Configuration of audit-laf
# Summary:	Client for autoinstallation
# Authors:	Gabriele Mohr <gs@suse.de>
#
# $Id: audit-laf_auto.ycp 41350 2007-10-10 16:59:00Z dfiser $
#
# This is a client for autoinstallation. It takes its arguments,
# goes through the configuration and return the setting.
# Does not do any changes to the configuration.

# @param function to execute
# @param map/list of audit-laf settings
# @return [Hash] edited settings, Summary or boolean on success depending on called function
# @example map mm = $[ "FAIL_DELAY" : "77" ];
# @example map ret = WFM::CallFunction ("audit-laf_auto", [ "Summary", mm ]);
module Yast
  class AuditLafAutoClient < Client
    def main
      Yast.import "UI"

      textdomain "audit-laf"

      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("AuditLaf auto started")

      Yast.import "AuditLaf"
      Yast.include self, "audit-laf/wizards.rb"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      # Create a summary
      if @func == "Summary"
        @ret = AuditLaf.Summary
      # Reset configuration
      elsif @func == "Reset"
        AuditLaf.Import({})
        @ret = {}
      # Change configuration (run AutoSequence)
      elsif @func == "Change"
        @ret = AuditLafAutoSequence()
      # Import configuration
      elsif @func == "Import"
        @ret = AuditLaf.Import(@param)
      # Return actual state
      elsif @func == "Export"
        @ret = AuditLaf.Export
      # Return needed packages
      elsif @func == "Packages"
        @ret = AuditLaf.AutoPackages
      # Read current state
      elsif @func == "Read"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        @ret = AuditLaf.Read
        Progress.set(@progress_orig)
      # Write givven settings
      elsif @func == "Write"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        AuditLaf.SetWriteOnly(true)
        @ret = AuditLaf.Write
        Progress.set(@progress_orig)
      # did configuration changed
      # return boolean
      elsif @func == "GetModified"
        @ret = AuditLaf.Modified
      # set configuration as changed
      # return boolean
      elsif @func == "SetModified"
        AuditLaf.SetModified(true)
        @ret = true
      else
        Builtins.y2error("Unknown function: %1", @func)
        @ret = false
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("AuditLaf auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::AuditLafAutoClient.new.main
