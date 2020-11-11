# frozen_string_literal: true

module PostService
  # 記事投稿のCRUDに関するサービス
  class PostCrudService
    include CommonService
    include MasterConstants
    include PostInfo
    include UserConstants
    include UserService

    # 新規作成する記事投稿の取得
    def self.get_create_post(title, url, category, open_flg, role, user_id)
      # idの発行
      post_id = GenerateService.generate_token(10)
      new_post = Post.new(
        _id: post_id,
        user_id: user_id,
        title: title,
        url: url,
        category: category,
        open_flg: open_flg,
        post_role: role,
        ogp: HtmlScrapingService.get_ogp_info_from_url(url)
      )
      new_post if new_post.valid?
    end

    # 記事投稿内容の編集
    def self.edit_post(post_id, title, url, category, open_flg, user_id)
      post_collection = Post.get_post_collection
      ogp = HtmlScrapingService.get_ogp_info_from_url(url)
      post_collection.update_one(
        { '$and' => [{ '_id' => post_id }, { 'user_id' => user_id }] },
        { '$set' => {
          'title' => title,
          'url' => url,
          'category' => category,
          'open_flg' => open_flg,
          'ogp' => if ogp.nil?
                     nil
                   else
                     {
                       'site_name' => ogp.site_name,
                       'description' => ogp.description,
                       'image_url' => ogp.image_url
                     }
                   end
        } }
      )
    end

    # 記事投稿内容の削除
    def self.delete_post(post_id, user_id)
      post_find_result = Post.where(_id: post_id, user_id: user_id)
      unless post_find_result.empty?
        post_find_result.delete
        PostManagementService.delete_post_whistle_by_post_id(post_id)
      end
    end

    # 自身の記事投稿内容の参照
    def self.get_own_post(post_id, user_id)
      post_find_result = Post.where(_id: post_id, user_id: user_id).only(
        :_id,
        :title,
        :category,
        :url,
        :open_flg
      )
      if post_find_result.empty?
        nil
      else
        post = post_find_result[0]
        {
          post_id: post.id,
          title: post.title,
          category: post.category,
          url: post.url,
          open_flg: post.open_flg
        }
      end
    end

    # ユーザを指定した記事一覧の取得
    def self.get_user_posts(own_user_id, refer_user_id, limit, post_category)
      user_info = UserProfileService.get_own_basic_info(refer_user_id)
      if user_info.nil? || user_info.status != STATUS_ACTIVE
        nil
      else
        post_collection = Post.get_post_collection
        # カテゴリー条件
        category_match = if POST_CATEGORY_LIST.detect { |p| p[:key] == post_category }.nil?
                           { '$match' => { 'category' => { '$exists' => true } } }
                         else
                           { '$match' => { 'category' => post_category } }
                         end
        # 自身の記事一覧
        if own_user_id == refer_user_id
          post_collection.aggregate(
            [
              { '$match' => { 'user_id' => refer_user_id } },
              category_match,
              { '$project' => {
                _id: 1,
                title: 1,
                category: 1,
                url: 1,
                ogp: 1,
                open_flg: 1,
                created_at: 1,
                access_count: { '$cond' => [{
                  '$not' => ['$post_access_users']
                }, 0, { "$size": '$post_access_users' }] }
              } },
              { '$sort' => { 'created_at' => -1 } },
              { '$limit' => limit }
            ]
          ).to_a.map do |p|
            {
              post_id: p[:_id],
              title: p[:title],
              category: p[:category],
              url: p[:url],
              open_flg: p[:open_flg],
              ogp: p[:ogp],
              created_at: p[:created_at],
              access_count: p[:access_count]
            }
          end
        else
          post_collection.aggregate(
            [
              { '$match' => { 'user_id' => refer_user_id } },
              category_match,
              { '$match' => { 'open_flg' => true } },
              { '$project' => {
                _id: 1,
                title: 1,
                category: 1,
                url: 1,
                ogp: 1,
                created_at: 1,
                access_count: { '$cond' => [{
                  '$not' => ['$post_access_users']
                }, 0, { "$size": '$post_access_users' }] }
              } },
              { '$sort' => { 'created_at' => -1 } },
              { '$limit' => limit }
            ]
          ).to_a.map do |p|
            {
              post_id: p[:_id],
              title: p[:title],
              category: p[:category],
              url: p[:url],
              ogp: p[:ogp],
              created_at: p[:created_at],
              access_count: p[:access_count]
            }
          end
        end
      end
    end

    # 管理者記事一覧の取得
    def self.get_admin_user_posts(limit, post_category)
      post_collection = Post.get_post_collection
      # カテゴリー条件
      category_match = if POST_CATEGORY_LIST.detect { |p| p[:key] == post_category }.nil?
                         { '$match' => { 'category' => { '$exists' => true } } }
                       else
                         { '$match' => { 'category' => post_category } }
                       end
      post_collection.aggregate(
        [
          { '$match' => { 'post_role' => ROLE_ADMIN } },
          category_match,
          { '$match' => { 'open_flg' => true } },
          { '$project' => {
            _id: 1,
            title: 1,
            category: 1,
            url: 1,
            ogp: 1,
            created_at: 1,
            access_count: { '$cond' => [{
              '$not' => ['$post_access_users']
            }, 0, { "$size": '$post_access_users' }] }
          } },
          { '$sort' => { 'created_at' => -1 } },
          { '$limit' => limit }
        ]
      ).to_a.map do |p|
        {
          post_id: p[:_id],
          title: p[:title],
          category: p[:category],
          url: p[:url],
          ogp: p[:ogp],
          created_at: p[:created_at],
          access_count: p[:access_count]
        }
      end
    end

    # 全ユーザ記事一覧の取得
    def self.get_all_users_posts(limit, post_category)
      before30day = DateService.get_plus_now_day(-30)
      post_collection = Post.get_post_collection
      # カテゴリー条件
      category_match = if POST_CATEGORY_LIST.detect { |p| p[:key] == post_category }.nil?
                         { '$match' => { 'category' => { '$exists' => true } } }
                       else
                         { '$match' => { 'category' => post_category } }
                       end
      post_collection.aggregate(
        [
          { '$match' => { 'post_role' => ROLE_USER } },
          category_match,
          { '$match' => { 'open_flg' => true } },
          { "$lookup": {
            "from": 'user_info_users',
            "localField": 'user_id',
            "foreignField": '_id',
            "as": 'user_info'
          } },
          { '$match' => { 'user_info.status' => STATUS_ACTIVE } },
          { '$project' => {
            _id: 1,
            title: 1,
            category: 1,
            url: 1,
            ogp: 1,
            created_at: 1,
            access_count: { '$cond' => [{
              '$not' => ['$post_access_users']
            }, 0, { "$size": '$post_access_users' }] },
            monthly_access_count: { '$cond' => [{
              '$not' => ['$post_access_users']
            }, 0, { "$size": { '$filter' => {
              'input' => '$post_access_users',
              'as' => 'post_access_user',
              'cond' => { '$gte' => ['$$post_access_user.access_at', before30day] }
            } } }] },
            "user_info._id": 1,
            'user_info.profile.name': 1,
            'user_info.profile.image_url': 1
          } },
          { '$sort' => { 'monthly_access_count' => -1, 'created_at' => -1 } },
          { '$limit' => limit }
        ]
      ).to_a.map do |p|
        user_info = p[:user_info][0]
        profile = user_info[:profile]
        {
          post_id: p[:_id],
          title: p[:title],
          category: p[:category],
          url: p[:url],
          ogp: p[:ogp],
          created_at: p[:created_at],
          access_count: p[:access_count],
          user_id: user_info[:_id],
          user_name: !profile.nil? ? profile[:name] : nil,
          user_image_url: !profile.nil? ? profile[:image_url] : nil
        }
      end
    end
  end
end
