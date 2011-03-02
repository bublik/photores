require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_user_activate
    @expected.subject = 'Mailer#user_activate'
    @expected.body    = read_fixture('user_activate')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Mailer.create_user_activate(@expected.date).encoded
  end

  def test_notice
    @expected.subject = 'Mailer#notice'
    @expected.body    = read_fixture('notice')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Mailer.create_notice(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
