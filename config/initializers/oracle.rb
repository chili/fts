ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
  self.emulate_booleans_from_strings = false
end