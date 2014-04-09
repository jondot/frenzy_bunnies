module Helpers
  module Utils
    def symbolize(opts)
      opts.inject({}){|h,(k,v)| h.merge({ k.to_sym => v}) }
    end
  end
end
