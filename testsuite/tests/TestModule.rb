# encoding: utf-8

module Yast
  class TestModuleClient < Client
    def main
      # testedfiles: TestModule.ycp

      Yast.include self, "testsuite.rb"
      TESTSUITE_INIT([], nil)

      Yast.import "AuditLaf"

      DUMP("AuditLaf::Modified")
      TEST(lambda { AuditLaf.Modified }, [], nil)

      nil
    end
  end
end

Yast::TestModuleClient.new.main
