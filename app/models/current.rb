class Current < ActiveSupport::CurrentAttributes
  thread_mattr_accessor :user
end
