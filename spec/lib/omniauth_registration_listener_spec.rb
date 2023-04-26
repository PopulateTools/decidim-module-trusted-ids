# frozen_string_literal: true

require "spec_helper"

module Decidim::TrustedIds
  describe OnOmniauthRegistrationListener do
    describe "when omniauth_registration event is notified" do
      let(:raw_data) { { email: "some@example.org" } }
      let(:data) do
        { provider: provider, raw_data: raw_data }
      end

      context "when it is an IdCat mòbil registration" do
        let(:provider) { "trusted_ids" }

        it "enqueues VerificationJob" do
          expect(Decidim::TrustedIds::VerificationJob).to receive(:perform_later)
            .with(raw_data)

          subject.on_omniauth_registration(raw_data)
        end
      end

      context "when it is not and IdCat mòbil registration" do
        let(:provider) { "decidim" }

        it "does not enqueues VerificationJob" do
          expect(Decidim::TrustedIds::VerificationJob).not_to receive(:perform_later)
        end
      end
    end
  end
end
