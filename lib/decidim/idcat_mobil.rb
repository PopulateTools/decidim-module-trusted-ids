# frozen_string_literal: true

require "decidim/admin"
require "decidim/verifications"

require "decidim/trusted_ids/on_omniauth_registration_listener"
require "decidim/trusted_ids/engine"

module Decidim
  # This namespace holds the logic of the `TrustedIds` component. This component
  # allows users to create trusted_ids in a participatory space.
  module TrustedIds
  end
end
