module AttachmentManager
  extend ActiveSupport::Concern

  def avatar_thumbnail(size = '125')
    avatar.variant(resize: "#{size}x#{size}!").processed
  end

  def banner_thumbnail(sizeh = '750', sizew = '480')
    banner.variant(resize: "#{sizeh}x#{sizew}!").processed
  end

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(
        Rails.root.join(
          'app', 'assets', 'images', 'default_avatar.jpg'
        )
      ),
      filename: 'default_avatar.jpg',
      content_type: 'image/jpg'
    )
  end

  def add_default_banner
    return if banner.attached?

    banner.attach(
      io: File.open(
        Rails.root.join(
          'app', 'assets', 'images', 'default_banner.jpg'
        )
      ),
      filename: 'default_banner.jpg',
      content_type: 'image/jpg'
    )
  end
end
