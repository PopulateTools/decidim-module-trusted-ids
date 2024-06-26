# frozen_string_literal: true

require "decidim/trusted_ids/verifications"
require "decidim/trusted_ids/engine"

module Decidim
  module TrustedIds
    include ActiveSupport::Configurable

    def self.omniauth_env(key, default = nil)
      ENV.fetch("#{TrustedIds.omniauth_provider.upcase}_#{key}", default)
    end

    def self.to_bool(val)
      ActiveRecord::Type::Boolean.new.deserialize(val.to_s.downcase)
    end

    def self.omniauth_metadata_attributes
      valid_keys = ENV.keys.filter { |key| key.starts_with?("#{TrustedIds.omniauth_provider.upcase}_METADATA_") }
      return nil if valid_keys.blank?

      valid_keys.to_h do |key|
        [key.gsub("#{TrustedIds.omniauth_provider.upcase}_METADATA_", "").downcase.to_sym, ENV[key].split.map(&:to_sym)]
      end
    end

    # The name of the omniauth provider, must be registered in Decidim.
    # Leave it empty to disable omniauth authentication.
    config_accessor :omniauth_provider do
      ENV.fetch("OMNIAUTH_PROVIDER", "valid")
    end

    # From the data obtained we extract metadata to be saved as part of the authorization
    # This data can later be used by the census_authorization handler as to call the webservice
    # A hash with keys and how to find it inside hash comming from the OAuth
    config_accessor :authorization_metadata do
      TrustedIds.omniauth_metadata_attributes || {
        expires_at: [:credentials, :expires_at],
        identifier_type: [:extra, :identifier_type],
        method: [:extra, :method],
        assurance_level: [:extra, :assurance_level]
      }
    end

    # setup a hash with :client_id, :client_secret and :site to enable omniauth authentication
    config_accessor :omniauth do
      {
        enabled: TrustedIds.to_bool(ENV.fetch("OMNIAUTH_ENABLED_BY_DEFAULT", TrustedIds.omniauth_env("CLIENT_ID").present?)),
        client_id: TrustedIds.omniauth_env("CLIENT_ID"),
        client_secret: TrustedIds.omniauth_env("CLIENT_SECRET"),
        site: TrustedIds.omniauth_env("SITE", "https://identitats.aoc.cat"),
        icon_path: TrustedIds.omniauth_env("ICON", "media/images/#{TrustedIds.omniauth_provider.downcase}-icon.png"),
        scope: TrustedIds.omniauth_env("SCOPE", "autenticacio_usuari")
      }
    end

    # which of the former attributes can not set a the /system configuration, there are all the same for all tenants
    config_accessor :omniauth_global_attributes do
      ENV.fetch("OMNIAUTH_GLOBAL_ATTRIBUTES", "site icon_path scope").split.map(&:to_sym)
    end

    # wheter to use a custom login screen or the default one
    config_accessor :custom_login_screen do
      TrustedIds.to_bool(ENV.fetch("CUSTOM_LOGIN_SCREEN", true))
    end

    # how long the verification will be valid, defaults to 90 days
    # if empty or nil, the verification will never expire
    config_accessor :verification_expiration_time do
      ENV.fetch("VERIFICATION_EXPIRATION_TIME", 90).to_i.days
    end

    # if false, no notifications will be send to users when automatic verifications are performed
    config_accessor :send_verification_notifications do
      ENV.has_key?("SEND_VERIFICATION_NOTIFICATIONS") ? TrustedIds.to_bool(ENV.fetch("SEND_VERIFICATION_NOTIFICATIONS")) : true
    end

    # Linked authorization method that will automatically verify users after getting a valid TrustedIds verification
    config_accessor :census_authorization do
      {
        handler: ENV.has_key?("CENSUS_AUTHORIZATION_HANDLER") ? ENV.fetch("CENSUS_AUTHORIZATION_HANDLER").to_sym : :via_oberta_handler,
        form: ENV.fetch("CENSUS_AUTHORIZATION_FORM", "Decidim::ViaOberta::Verifications::ViaObertaHandler"),
        env: ENV.fetch("CENSUS_AUTHORIZATION_ENV", "production"),
        api_url: ENV.fetch("CENSUS_AUTHORIZATION_API_URL", nil),
        # These setting will be added in the organization form at /system as tenant configurable parameters
        system_attributes: ENV.fetch("CENSUS_AUTHORIZATION_SYSTEM_ATTRIBUTES", "nif ine municipal_code province_code organization_name").split
      }
    end

    def self.census_config_attributes
      return [] if TrustedIds.census_authorization[:handler].blank?
      return [] if TrustedIds.census_authorization[:system_attributes].blank?
      return [] unless TrustedIds.census_authorization[:system_attributes].is_a?(Array)

      TrustedIds.census_authorization[:system_attributes].map do |prop|
        [prop.to_sym, String]
      end
    end

    def self.custom_login_screen?
      Decidim::TrustedIds.omniauth_provider.present? && Decidim::TrustedIds.custom_login_screen.present?
    end
  end
end
