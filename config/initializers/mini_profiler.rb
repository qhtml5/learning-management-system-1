# Whether or not you want to log the queries about the schema of your tables.
# Default is 'false', 'true' in rails development.
Rack::MiniProfiler.config.skip_schema_queries = false
 
# Have Mini Profiler start in hidden mode - display with short cut. Defaulted to
# 'Alt+P'
Rack::MiniProfiler.config.start_hidden = true
 
# If whant to use on production, comment this.
if Rails.env.production?
  Rack::MiniProfiler.config.auto_inject = false
end