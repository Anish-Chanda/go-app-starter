# Tests user registration functionality including validation and error cases

# Test successful user signup
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "signup-test@example.com",
  "password": "secure123",
  "name": "Signup Test"
}

HTTP 201
[Asserts]
jsonpath "$.email" == "signup-test@example.com"
jsonpath "$.provider" == "local"
jsonpath "$.id" exists

# Test signup with duplicate email (reuse same email)
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "signup-test@example.com",
  "password": "another123",
  "name": "Duplicate Test"
}

HTTP 409
[Asserts]
body contains "email already exists"

# Test signup with empty email
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "",
  "password": "testpass",
  "name": "No Email"
}

HTTP 400
[Asserts]
body contains "email cannot be empty"

# Test signup with empty password
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "nopwd@example.com",
  "password": "",
  "name": "No Password"
}

HTTP 400
[Asserts]
body contains "password cannot be empty"

# Test signup with empty name
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "noname@example.com",
  "password": "testpass",
  "name": ""
}

HTTP 400
[Asserts]
body contains "name cannot be empty"