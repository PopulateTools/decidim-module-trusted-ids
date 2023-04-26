# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :trusted_ids_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :trusted_ids).i18n_name }
    manifest_name { :trusted_ids }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
