CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['S3_ACCESS_KEY'],
      :aws_secret_access_key  => ENV['S3_SECRET_KEY'],
      :region                 => ENV['S3_REGION'],
    }
    config.fog_directory  = ENV['S3_BUCKET']
    config.fog_public = false
  else
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Rails.application.credentials.dig(:aws, :access_key_id),
      :aws_secret_access_key  => Rails.application.credentials.dig(:aws, :secret_access_key),
      :region                 => 'us-east-1'
    }
    config.fog_directory  = 'mccovin-facebook'
    config.fog_public = false
  end
end
