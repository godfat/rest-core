
require 'rest-core'

module Rib; end
module Rib::RestCore
  Rib::Shell.use(self)
  def self.load
    Rib.shell.config[:binding] =
      ::RestCore::Universal.new.instance_eval{binding}
  end

  def prompt
    "rest-core#{super}"
  end
end
