require 'test_helper'

class PhotomailerTest < ActionMailer::TestCase
  tests Photomailer
  def test_new_photo
    @expected.subject = 'Photomailer#new_photo'
    @expected.body    = read_fixture('new_photo')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Photomailer.create_new_photo(@expected.date).encoded
  end

  def test_updated_photo
    @expected.subject = 'Photomailer#updated_photo'
    @expected.body    = read_fixture('updated_photo')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Photomailer.create_updated_photo(@expected.date).encoded
  end

end
