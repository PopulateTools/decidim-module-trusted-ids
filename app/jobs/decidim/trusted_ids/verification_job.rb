# frozen_string_literal: true

module Decidim
  module TrustedIds
    class VerificationJob < ApplicationJob
      queue_as :default

      def perform(oauth_data)
        handler = retrieve_handler(oauth_data)
        Decidim::Verifications::AuthorizeUser.call(handler) do
          on(:ok) do
            notify_user(handler.user, :ok, handler)
          end

          on(:invalid) do
            notify_user(handler.user, :invalid, handler)
          end
        end
      end

      #-----------------------------------------------------------
      private

      #-----------------------------------------------------------

      # Retrieves handler from Verification workflows registry.
      def retrieve_handler(oauth_data)
        Decidim::AuthorizationHandler.handler_for("trusted_ids", oauth_data: oauth_data)
      end

      def notify_user(user, status, handler)
        notification_class = status == :ok ? Decidim::TrustedIds::VerificationSuccessNotification : Decidim::TrustedIds::VerificationInvalidNotification
        Decidim::EventsManager.publish(
          event: "decidim.verifications.trusted_ids.#{status}",
          event_class: notification_class,
          # resource: result,
          recipient_ids: [user.id],
          extra: {
            status: status,
            errors: handler.errors.full_messages
          }
        )
      end
    end
  end
end
