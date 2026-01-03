# Tests login, session management, and authenticated endpoints

# Setup: Create a test user first
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "flow-unique@example.com",
  "password": "authpass123",
  "name": "Auth Test User"
}

HTTP 201

# Test login with correct credentials
POST http://localhost:8080/auth/local/login
Content-Type: application/json
{
  "user": "flow-unique@example.com",
  "passwd": "authpass123"
}

HTTP 200
[Captures]
xsrf_token: cookie "XSRF-TOKEN"
[Asserts]
# Verify name is the display name from DB (not the email)
jsonpath "$.name" == "Auth Test User"
jsonpath "$.name" != "flow-unique@example.com"
# Verify email is properly set
jsonpath "$.email" == "flow-unique@example.com"
# Verify ID follows OAuth2 pattern (local_<hash>)
jsonpath "$.id" exists
jsonpath "$.id" matches "^local_[a-f0-9]+$"
# Verify ClaimsUpdater added database UUID
jsonpath "$.attrs.uid" exists
jsonpath "$.attrs.uid" matches "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
# Verify ClaimsUpdater added provider attribute
jsonpath "$.attrs.provider" == "local"
cookie "JWT" exists
cookie "XSRF-TOKEN" exists

# Test auth status when logged in (with XSRF token)
GET http://localhost:8080/auth/status
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
jsonpath "$.status" == "logged in"
jsonpath "$.user" == "Auth Test User"

# Test accessing user profile when logged in
GET http://localhost:8080/auth/user
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
# Verify ClaimsUpdater set name to display name (not email)
jsonpath "$.name" == "Auth Test User"
jsonpath "$.name" != "flow-unique@example.com"
# Verify email is normalized and set correctly
jsonpath "$.email" == "flow-unique@example.com"
# Verify ID format
jsonpath "$.id" exists
jsonpath "$.id" matches "^local_[a-f0-9]+$"
# Verify ClaimsUpdater added database UUID attribute
jsonpath "$.attrs.uid" exists
jsonpath "$.attrs.uid" matches "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
# Verify ClaimsUpdater added provider attribute for frontend
jsonpath "$.attrs.provider" == "local"

# Test auth list endpoint
GET http://localhost:8080/auth/list
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
jsonpath "$[0]" == "local"

# Test logout
GET http://localhost:8080/auth/logout
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
header "Set-Cookie" contains "JWT=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0"

# Test auth status after logout
GET http://localhost:8080/auth/status

HTTP 200
[Asserts]
jsonpath "$.status" == "not logged in"