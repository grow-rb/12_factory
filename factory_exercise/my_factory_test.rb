require 'minitest/autorun'
require_relative 'my_factory'

class User
  attr_accessor :id, :name, :admin, :full_name, :email, :posts
end

class Post
  attr_accessor :user_id, :body
end

class MyMyFactoryTest < MiniTest::Test
  MyFactory.define do
    sequence(:email) {|i| "email#{i}@example.com" }

    factory :user do
      sequence(:id, 1) {|i| i }
      name { 'name' }
      admin { false }

      trait :admin do
        admin { true }
      end

      factory :user_with_full_name do
        full_name { 'John Doe' }
      end
    end

    factory :post do
      sequence(:body) {|i| "Body:#{i}"}
    end

    factory :user_with_some_posts, class_name: 'User' do
      after_create do |user|
        user.posts = 3.times.map { MyFactory.create(:post, user_id: user.id) }
      end
    end
  end

  def test_user_factory
    user = MyFactory.create :user
    assert_equal 'name', user.name
    assert_equal false, user.admin
  end

  def test_user_factory_with_trait_and_params
    user = MyFactory.create :user, :admin, name: 'arg'
    assert_equal 'arg', user.name
    assert_equal true, user.admin
  end

  def test_nested_factory
    user_with_full_name = MyFactory.create :user_with_full_name
    assert_equal 'User', user_with_full_name.class.name
    assert_equal 'John Doe', user_with_full_name.full_name
  end

  def test_global_sequence
    assert_equal 'email0@example.com', MyFactory.generate(:email)
    assert_equal 'email1@example.com', MyFactory.generate(:email)
  end

  def test_callback
    user_with_some_posts = MyFactory.create :user_with_some_posts
    assert_equal 3, user_with_some_posts.posts.size
  end
end
