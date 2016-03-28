# Aws.config = AshFrame.config_for(:aws).symbolize_keys

# module TransientBug
#   module_function
#   # S3 client. Technically we probably only need a single bucket instance, but
#   # this can always change later on.
#   def s3
#     @@s3 ||= Aws::S3::Client.new region: 'us-east-1'
#   end
# end
