require "test_helper"

class UserTest < ActiveSupport::TestCase

    def setup
        @user = User.new(name: "Raymond Example", email: "rimonomega@example.com",
                         password: "foobar", password_confirmation: "foobar")
    end

    test "should be valid" do
        assert @user.valid?
    end

    test "name should be present" do
        @user.name = "         "
        assert_not @user.valid?
    end

    test "email should be present" do
        @user.email = ""
        assert_not @user.valid?
    end

    test "name should not be too long" do
        @user.name = "a" * 51
        assert_not @user.valid?
    end

    test "email should not be too long" do
        @user.email = "a" * 244 + "@example.com"
        assert_not @user.valid?
    end

    test "email validation should accept valid addresses" do
        valid_addresses = %w[user@example.com USER@foor.COM A_US-ER@foo.bar.org first.last@foo.jp alic+bob@baz.cn]
        valid_addresses.each do |valid_address|
            @user.email = valid_address
            assert @user.valid?, "#{valid_address.inspect} should be valid"
        end
    end

    test "email validation should reject invalid addresses" do
        invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        invalid_addresses.each do |invalid_address|
            @user.email = invalid_address
            assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
        end
    end

    test "email addresses should be unique" do
        duplicate_user = @user.dup
        @user.save
        assert_not duplicate_user.valid?
    end

    test "email addresses should be saved as lower-case" do
        mixed_case_email = "Foo@ExAMPle.CoM"
        @user.email = mixed_case_email
        @user.save
        assert_equal mixed_case_email.downcase, @user.reload.email
    end

    test "password should be present (non-blank)" do
        @user.password = @user.password_confirmation = " " * 6
        assert_not @user.valid?
    end

    test "authenticated? should return false for a user with nil digest" do
        assert_not @user.authenticated?(:remember,'')
    end

    test "associated microposts should be destroyed" do
        @user.save
        @user.microposts.create!(content: "Lorem ipsum")
        assert_difference 'Micropost.count', -1 do
            @user.destroy
        end
    end

    test "should follow and unfollow a user" do
        raymond = users(:raymond)
        yasmin = users(:yasmin)
        assert_not raymond.following?(yasmin)
        raymond.follow(yasmin)
        assert raymond.following?(yasmin)
        assert yasmin.followers.include?(raymond)
        raymond.unfollow(yasmin)
        assert_not raymond.following?(yasmin)
        # Users can not follow themselves.
        raymond.follow(raymond)
        assert_not raymond.following?(raymond)
    end


    test "feed should have the right posts" do
        raymond = users(:raymond)
        yasmin = users(:yasmin)
        rojeh = users(:rojeh)
        # Posts from followed user
        rojeh.microposts.each do |post_following|
            assert raymond.feed.include?(post_following)
        end
        # Self-posts for user with followers
        raymond.microposts.each do |post_self|
            assert raymond.feed.include?(post_self)
        end
        # Self-posts for user with no followers
        yasmin.microposts.each do |post_self|
            assert yasmin.feed.include?(post_self)
        end
        # Posts from unfollowed user
        yasmin.microposts.each do |post_unfollowed|
            assert_not raymond.feed.include?(post_unfollowed)
        end
    end

end
