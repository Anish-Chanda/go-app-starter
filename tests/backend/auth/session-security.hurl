# Session Security Tests
# Setup: Create test user and login
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "security-test@example.com",
  "password": "securepass123",
  "name": "Security Test"
}

HTTP 201

# Login to get session
POST http://localhost:8080/auth/local/login
Content-Type: application/json
{
  "user": "security-test@example.com",
  "passwd": "securepass123"
}

HTTP 200
[Captures]
xsrf_token: cookie "XSRF-TOKEN"

# Test accessing protected endpoint WITHOUT XSRF token (should fail)
GET http://localhost:8080/auth/user

HTTP 401
[Asserts]
jsonpath "$.error" == "xsrf mismatch"

# Test accessing protected endpoint WITH correct XSRF token (should work)
GET http://localhost:8080/auth/user
X-Xsrf-Token: {{xsrf_token}}

HTTP 200
[Asserts]
jsonpath "$.name" == "security-test@example.com"

# Test accessing protected endpoint with WRONG XSRF token (should fail)
GET http://localhost:8080/auth/user
X-Xsrf-Token: invalid-token-12345

HTTP 401
[Asserts]
jsonpath "$.error" == "xsrf mismatch"