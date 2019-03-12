class PerformDenpyo < ApplicationRecord
  belongs_to :user
  belongs_to :perform_detail
  belongs_to :performance
end
