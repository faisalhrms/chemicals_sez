Rails.application.config.filter_parameters += [
  :passw, :password_confirmation, :email, :secret, :token, :_key,
  :crypt, :salt, :certificate, :otp, :ssn, :authorization
]
