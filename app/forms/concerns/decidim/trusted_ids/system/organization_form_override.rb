# frozen_string_literal: true

module Decidim
  module TrustedIds
    module System
      module OrganizationFormOverride
        extend ActiveSupport::Concern

        included do
          jsonb_attribute :trusted_ids_census_config, TrustedIds.census_config_attributes + [[:tos, String], [:expiration_days, Integer]]
          attribute :census_expiration_apply_all_tenants, Virtus::Attribute::Boolean
          attribute :census_tos_apply_all_tenants, Virtus::Attribute::Boolean

          def trusted_ids_census_settings
            return trusted_ids_census_config if trusted_ids_census_config.is_a?(Hash)

            trusted_ids_census_config&.settings || {}
          end

          def default_expiration_days
            @default_expiration_days ||= Decidim::TrustedIds.verification_expiration_time.to_i / 86_400
          end

          def default_tos
            I18n.t("decidim.via_oberta.verifications.tos.content_html")
          end
        end
      end
    end
  end
end
