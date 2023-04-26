# frozen_string_literal: true

# # frozen_string_literal: true

# module Decidim
#   module TrustedIds
#     # This is the engine that runs on the public interface of `TrustedIds`.
#     class AdminEngine < ::Rails::Engine
#       isolate_namespace Decidim::TrustedIds::Admin

#       paths["db/migrate"] = nil
#       paths["lib/tasks"] = nil

#       routes do
#         # Add admin engine routes here
#         # resources :trusted_ids do
#         #   collection do
#         #     resources :exports, only: [:create]
#         #   end
#         # end
#         # root to: "trusted_ids#index"
#       end

#       def load_seed
#         nil
#       end
#     end
#   end
# end
