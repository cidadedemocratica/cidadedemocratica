# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Cidadedemocratica::Application.config.secret_token = ENV['SECRET_TOKEN']
Cidadedemocratica::Application.config.secret_token ||= '7d874a42a9ea54b96c9141b01cd88c4f64c5ed88ba2e91a3d041ff04e398f614b8438bd09bccfa1cf5b78f558e483b7b48f359453bc07b9237d42ca45ab0572f'
