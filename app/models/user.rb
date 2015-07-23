class User < ActiveRecord::Base
  has_many :reviews
  has_many :places

 # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :authentications
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

def self.from_omniauth(auth, user)
  where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
    user.password = Devise.friendly_token[0,20]
    user.name = auth.info.name   # assuming the user model has a name
    user.image = auth.info.image # assuming the user model has an image
    user.location = auth.info.location
    user.oauth_token = auth.credentials.token
    user.email = auth.uid+"@facebook.com"
    user.oauth_expires_at = Time.at(auth.credentials.expires_at)
    # user.params = serialize :auth
    user.save!
  end
end

def facebook
  @facebook ||= Koala::Facebook::API.new(oauth_token)
end

def first_name
 facebook.get_object("me?fields=first_name")["first_name"]
end

def friends
  facebook.get_object("me/friends")
end

# def location
#   facebook.get_object("me?fields=location")["location"]["name"]
# end




def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        binding.pry
        user.email = data["email"] if user.email.blank?
      end
    end
end
end
