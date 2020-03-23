# Constants
module Monday
    MONDAY_PROTOCOL = "https".freeze
    MONDAY_DOMAIN = "monday.com".freeze
    MONDAY_API_URL = MONDAY_PROTOCOL+"://api."+MONDAY_DOMAIN+"/v2".freeze
    MONDAY_OAUTH_URL = MONDAY_PROTOCOL+"://auth."+MONDAY_DOMAIN+"/oauth2/authorize".freeze
    MONDAY_OAUTH_TOKEN_URL = MONDAY_PROTOCOL+"://auth."+MONDAY_DOMAIN+"/oauth2/token".freeze
end
