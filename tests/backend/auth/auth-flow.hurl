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
jsonpath "$.name" == "flow-unique@example.com"
jsonpath "$.id" exists
cookie "JWT" exists
cookie "XSRF-TOKEN" exists

# Test auth status when logged in (with XSRF token)
GET http://localhost:8080/auth/status
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
jsonpath "$.status" == "logged in"
jsonpath "$.user" == "flow-unique@example.com"

# Test accessing user profile when logged in
GET http://localhost:8080/auth/user
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
jsonpath "$.name" == "flow-unique@example.com"
jsonpath "$.id" exists

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