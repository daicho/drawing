require 'uri'
require 'base64'
require 'openssl'

s = "BAh7CkkiD3Nlc3Npb25faWQGOgZFVEkiRTk4OWJkYWQzNGM3YzBiYWU1NDMy%0AMzg1NDJjMTg0N2IwZGRiNWUwNjU4Yzk4Y2NlMzhmNmIxNjFhN2U1ZmEzZTcG%0AOwBGSSIJY3NyZgY7AEZJIjFDWWZMR2ZuNkVGVXZGTXZNRy9FRmxyeXZOMFpj%0AU25MSUc4cHQ0RXQxaUtFPQY7AEZJIg10cmFja2luZwY7AEZ7BkkiFEhUVFBf%0AVVNFUl9BR0VOVAY7AFRJIi05ZGQ3ZmRhNmNhYmNhYjBjNGI1Yzk2OGEyZTJm%0AOTkzOGU3ODA0YzUwBjsARkkiD2xvZ2luX2ZsYWcGOwBGVEkiDXRlc3RkYXRh%0ABjsARkkiFklzIHRoaXMgYSBob2xkdXA%2FBjsAVA%3D%3D%0A--910183a5a37366a49cb56c8179107a84624c1de6"

sb64, digest = URI.decode(s).split("--")
t = Marshal.load(Base64.decode64(sb64))
t["testdata"] = "It's a science experiment!"

a = Base64.encode64(Marshal.dump(t))
b = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, "abcdefghij0123456789", a)
c = URI.escape(a + "--" + b)
puts c
