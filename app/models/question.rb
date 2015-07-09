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

  def results

    answers = self
      .answer_choices
      .select("answer_choices.*, COUNT(responses.id) AS count")
      .joins("LEFT JOIN responses ON answer_choices.id = responses.answer_id")
      .group("answer_choices.id")
    answers_and_counts = Hash.new { |h, k| h[k] = 0}

    answers.map do |answer|
      answers_and_counts[answer.text] = answer.count
    end

    answers_and_counts
  end
end
