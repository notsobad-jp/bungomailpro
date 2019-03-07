require 'test_helper'
class CommentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Gravatarへのリクエストmock
    stub_request(:get, %r{https://ja\.gravatar\.com/.*\.json}).to_return(status: 200, body: File.read('test/fixtures/files/gravatar.json'))
  end

  ########################################################################
  # index
  ########################################################################
  test 'access_index_when_guest' do
    sub = subscriptions(:user1_channel1)
    get subscription_comments_path(sub)
    assert_redirected_to login_path
  end

  test 'access_index_when_owner' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    get subscription_comments_path(sub)
    assert_response :success
  end

  test 'access_index_when_other' do
    sub = subscriptions(:user1_channel1)
    login_user(users(:user2))
    get subscription_comments_path(sub)
    assert_redirected_to pro_root_path
  end


  ########################################################################
  # new
  ########################################################################
  test 'access_new_when_guest' do
    sub = subscriptions(:user1_channel1)
    get new_subscription_comment_path(sub, book_id: books(:book1).id, index: 3)
    assert_redirected_to login_path
  end

  test 'access_new_when_owner' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    get new_subscription_comment_path(sub, book_id: books(:book1).id, index: 3)
    assert_response :success
  end

  test 'access_new_when_other' do
    sub = subscriptions(:user1_channel1)
    login_user(users(:user2))
    get new_subscription_comment_path(sub, book_id: books(:book1).id, index: 3)
    assert_redirected_to pro_root_path
  end


  ########################################################################
  # create
  ########################################################################
  test 'access_create_when_guest' do
    sub = subscriptions(:user1_channel1)
    post subscription_comments_path(sub, comment: {book_id: books(:book1).id, index: 3, text: 'コメント追加'})
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 3)
    assert_nil comment
    assert_redirected_to login_path
  end

  test 'access_create_when_owner' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    before_comment_count = Comment.all.count
    post subscription_comments_path(sub, comment: {book_id: books(:book1).id, index: 3, text: '重複コメント'})
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 3)
    after_comment_count = Comment.all.count

    assert comment
    comment.destroy

    assert_equal before_comment_count + 1, after_comment_count
    assert_redirected_to subscription_comments_path(sub)
  end

  test 'access_create_when_owner_with_duplicate_keys' do
    sub = subscriptions(:user1_channel1)
    login_user(sub.user)
    before_comment_count = Comment.all.count
    e = assert_raises ActiveRecord::RecordNotUnique do
      post subscription_comments_path(sub, comment: {book_id: books(:book1).id, index: 1, text: '重複コメント'})
    end
    assert e.message.include?("duplicate key value")
    after_comment_count = Comment.all.count
    assert_equal before_comment_count, after_comment_count
  end

  test 'access_create_when_other' do
    sub = subscriptions(:user1_channel1)
    login_user(users(:user2))
    before_comment_count = Comment.all.count
    post subscription_comments_path(sub, comment: {book_id: books(:book1).id, index: 1, text: '重複コメント'})
    after_comment_count = Comment.all.count
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 3)

    assert_nil comment
    assert_equal before_comment_count, after_comment_count
    assert_redirected_to pro_root_path
  end


  ########################################################################
  # edit
  ########################################################################
  test 'access_edit_when_guest' do
    comment = comments(:for_next_chapter)
    get edit_subscription_comment_path(comment.id, subscription_id: comment.subscription.id)
    assert_redirected_to login_path
  end

  test 'access_edit_when_owner' do
    comment = comments(:for_next_chapter)
    login_user(comment.subscription.user)
    get edit_subscription_comment_path(comment.id, subscription_id: comment.subscription.id)
    assert_response :success
  end

  test 'access_edit_when_other' do
    comment = comments(:for_next_chapter)
    login_user(users(:user2))
    get edit_subscription_comment_path(comment.id, subscription_id: comment.subscription.id)
    assert_redirected_to pro_root_path
  end


  ########################################################################
  # update
  ########################################################################
  test 'access_update_when_guest' do
    sub = subscriptions(:user1_channel1)
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)
    put subscription_comment_path(id: comment.id, subscription_id: sub.id), params: { comment: { text: 'コメント修正' } }

    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)
    refute_equal 'コメント修正', comment.text
    assert_redirected_to login_path
  end

  test 'access_update_when_owner' do
    sub = subscriptions(:user1_channel1)
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)
    login_user(sub.user)
    put subscription_comment_path(id: comment.id, subscription_id: sub.id), params: { comment: { text: 'コメント修正' } }

    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)
    assert_equal 'コメント修正', comment.text
  end

  test 'access_update_when_other' do
    sub = subscriptions(:user1_channel1)
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)
    login_user(users(:user2))
    put subscription_comment_path(id: comment.id, subscription_id: sub.id), params: { comment: { text: 'コメント修正' } }
    comment = Comment.find_by(subscription_id: sub.id, book_id: books(:book1).id, index: 1)

    refute_equal 'コメント修正', comment.text
    assert_redirected_to pro_root_path
  end
end
