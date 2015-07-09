# == Schema Information
#
# Table name: responses
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  answer_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Response < ActiveRecord::Base
  validates :user_id, :answer_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :author_cannot_respond_to_own_poll

  belongs_to(
    :answer_choice,
    class_name: :AnswerChoice,
    foreign_key: :answer_id,
    primary_key: :id
  )

  belongs_to(
    :respondent,
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id
  )

  has_one :question, through: :answer_choice, source: :question

  def sibling_responses

    Question.find_by_id(
      AnswerChoice.where(id: self.answer_id).pluck(:question_id)
      )
      .responses
      .where
      .not(id: self.id)
  end

  def find_author
    Poll.where(id:
      Question.where(id:
        AnswerChoice.where(id: self.answer_id).pluck(:question_id)
      ).pluck(:poll_id)
    ).pluck(:author_id).first
  end

  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(user_id)
      errors[:user_id] << "respondent has already answered question!"
    end
  end

  def author_cannot_respond_to_own_poll
    if find_author == user_id
      errors[:user_id] << "author can't respond to own poll"
    end
  end
end
