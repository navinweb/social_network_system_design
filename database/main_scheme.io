Table users {
  id uuid [primary key, default: `gen_random_uuid()`]
  username varchar(30) [not null, unique]
  email varchar(255) [not null, unique]
  password_hash varchar(255) [not null]
  display_name varchar(50)
  bio text
  avatar_url varchar(255)
  followers_count integer [default: 0]
  following_count integer [default: 0]
  posts_count integer [default: 0]
  created_at timestamp [default: `now()`]
  
  indexes {
    username
    email
    created_at
  }
}

Table posts {
  id uuid [primary key, default: `gen_random_uuid()`]
  author_id uuid [not null, ref: > users.id]
  content text [not null]
  location_id uuid [null, ref: > locations.id]
  likes_count integer [default: 0]
  comments_count integer [default: 0]
  shares_count integer [default: 0]
  views_count integer [default: 0]
  created_at timestamp [default: `now()`]
  
  indexes {
    author_id
    location_id
    created_at
    (author_id, created_at) [name: 'idx_posts_author_time']
  }
}

Table post_media {
  id uuid [primary key, default: `gen_random_uuid()`]
  post_id uuid [not null, ref: > posts.id]
  url varchar(255) [not null]
  thumbnail_url varchar(255)
  width integer
  height integer
  size_bytes bigint
  created_at timestamp [default: `now()`]
  
  indexes {
    post_id
    (post_id)
  }
}

Table comments {
  id uuid [primary key, default: `gen_random_uuid()`]
  post_id uuid [not null, ref: > posts.id]
  author_id uuid [not null, ref: > users.id]
  parent_comment_id uuid [null, ref: > comments.id]
  content text [not null]
  likes_count integer [default: 0]
  replies_count integer [default: 0]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
  deleted_at timestamp [null]
  
  indexes {
    post_id
    author_id
    parent_comment_id
    (post_id, created_at) [name: 'idx_comments_post_time']
    (deleted_at, post_id) [name: 'idx_comments_active']
  }
}

Table locations {
  id uuid [primary key, default: `gen_random_uuid()`]
  name varchar(255) [not null]
  city varchar(100)
  country varchar(100)
  latitude decimal(10,8) [not null]
  longitude decimal(11,8) [not null]
  posts_count integer [default: 0]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
  
  indexes {
    (latitude, longitude) [name: 'idx_locations_coords', type: gist]
    posts_count
    name
  }
}

Table likes {
  id bigserial [primary key]
  user_id uuid [not null, ref: > users.id]
  target_id uuid [not null]
  created_at timestamp [default: `now()`]
  
  indexes {
    (user_id, target_id) [unique, name: 'idx_likes_unique']
    (target_id, created_at) [name: 'idx_likes_target']
    user_id
  }
}

Table follows {
  id bigserial [primary key]
  follower_id uuid [not null, ref: > users.id]
  following_id uuid [not null, ref: > users.id]
  created_at timestamp [default: `now()`]
  
  indexes {
    (follower_id, following_id) [unique, name: 'idx_follows_unique']
    follower_id
    following_id
    (following_id, created_at) [name: 'idx_follows_following_time']
  }
}

Table reports {
  id uuid [primary key, default: `gen_random_uuid()`]
  reporter_id uuid [not null, ref: > users.id]
  target_type varchar(20) [not null] // 'post', 'user', 'comment'
  target_id uuid [not null]
  reason varchar(50) [not null] // 'spam', 'harassment', etc.
  description text
  status varchar(20) [default: 'pending'] // 'pending', 'reviewed', 'resolved', 'rejected'
  moderator_id uuid [null, ref: > users.id]
  moderator_note text
  created_at timestamp [default: `now()`]
  reviewed_at timestamp
  
  indexes {
    reporter_id
    (target_type, target_id)
    status
    (status, created_at) [name: 'idx_reports_status_time']
  }
}

Table notifications {
  id uuid [primary key, default: `gen_random_uuid()`]
  user_id uuid [not null, ref: > users.id]
  type varchar(20) [not null] // 'like', 'comment', 'follow', 'mention'
  title varchar(255) [not null]
  message text
  is_read boolean [default: false]
  related_user_id uuid [null, ref: > users.id]
  related_post_id uuid [null, ref: > posts.id]
  created_at timestamp [default: `now()`]
  
  indexes {
    user_id
    (user_id, is_read, created_at) [name: 'idx_notifications_user_unread']
    type
    created_at
  }
}

Table notification_settings {
  user_id uuid [primary key, ref: > users.id]
  push_likes boolean [default: true]
  push_comments boolean [default: true]
  push_follows boolean [default: true]
  push_mentions boolean [default: true]
  email_likes boolean [default: false]
  email_comments boolean [default: true]
  email_follows boolean [default: true]
  email_mentions boolean [default: true]
  email_digest boolean [default: true]
  updated_at timestamp [default: `now()`]
}

Table sessions {
  id uuid [primary key, default: `gen_random_uuid()`]
  user_id uuid [not null, ref: > users.id]
  token_hash varchar(255) [not null, unique]
  device_info text
  ip_address inet
  expires_at timestamp [not null]
  created_at timestamp [default: `now()`]
  
  indexes {
    user_id
    token_hash
    expires_at
  }
}
