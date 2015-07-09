# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  poll_id    :integer          not null
#  text       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Question < ActiveRecord::Base
  validates :poll_id, :text, presence: true

  has_many(
    :answer_choices,
    class_name: :AnswerChoice,
    foreign_key: :question_id,
    primary_key: :id
  )

  belongs_to(
    :poll,
    class_name: :Poll,
    foreign_key: :question_id,
    primary_key: :id
  )

  has_many(
    :responses,
    through: :answer_choices,
    source: :responses
  )
end
