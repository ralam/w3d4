# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  user_name  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  validates :user_name, presence: true

  has_many(
    :authored_polls,
    class_name: :Poll,
    foreign_key: :user_id,
    primary_key: :id
  )

  has_many(
    :responses,
    class_name: :Response,
    foreign_key: :user_id,
    primary_key: :id
  )

  def completed_polls
    responses_from_user = self
      .responses
      .select("responses.*")
      .joins(:responses)
    polls = self
      .polls
      .select("polls.*")
      .joins("questions q ON q.poll_id = p.id")
      .joins("answer_choices a ON a.question_id = q.id")
      .joins("LEFT JOIN responses_from_user r ON r.answer_id = a.id")
      .joins(:users)
      .having("COUNT(q.id) != COUNT(r.id)")
      .group("p.id")
    # Poll.find_by_sql(<<-SQL, id)
    #   SELECT p.*
    #   FROM polls p
    #   JOIN questions q ON q.poll_id = p.id
    #   JOIN answer_choices a ON a.question_id = q.id
    #   LEFT JOIN (
    #     SELECT
    #       responses.*
    #     FROM
    #       responses
    #     WHERE
    #       responses.user_id = ?
    #   ) ON responses.answer_id = a.id
    #   GROUP BY
    #     p.id
    #   HAVING
    #     COUNT(q.id) != COUNT(responses.id)
    # SQL
  end
end
