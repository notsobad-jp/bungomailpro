class ChannelProfile < ApplicationRecord
  belongs_to :channel, foreign_key: :id
end
