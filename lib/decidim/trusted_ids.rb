# frozen_string_literal: true

require "decidim/trusted_ids/on_omniauth_registration_listener"
require "decidim/trusted_ids/engine"

module Decidim
  module TrustedIds
    include ActiveSupport::Configurable

    # Public: This is the main configuration entry point for the TrustedIds
    config_accessor :omniauth_provider do
      "valid"
    end
  end
end
