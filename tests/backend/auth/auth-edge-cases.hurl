# Tests various error conditions and edge cases for authentication

# Setup: Create a test user for negative testing
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "edge-test@example.com",
  "password": "edgepass123",
  "name": "Edge Test User"
}

HTTP 201

# Test login with non-existent user
POST http://localhost:8080/auth/local/login
Content-Type: application/json
{
  "user": "nonexistent@example.com",
  "passwd": "somepassword"
}

HTTP 403
[Asserts]
jsonpath "$.error" == "incorrect user or password"

# Test login with wrong password
POST http://localhost:8080/auth/local/login
Content-Type: application/json
{
  "user": "edge-test@example.com",
  "passwd": "wrongpassword"
}

HTTP 403
[Asserts]
jsonpath "$.error" == "incorrect user or password"

# Test login with empty credentials
POST http://localhost:8080/auth/local/login
Content-Type: application/json
{
  "user": "",
  "passwd": ""
}

HTTP 500

# Test accessing auth endpoints that don't exist
GET http://localhost:8080/auth/nonexistent

HTTP 400

# Test signup with name that exceeds VARCHAR(255) limit
POST http://localhost:8080/auth/local/signup
Content-Type: application/json
{
  "email": "longname@example.com",
  "password": "testpass",
  "name": "ThisIsAVeryLongNameThatExceedsThe255CharacterLimitForTheNameFieldInTheDatabaseSchemaAndShouldBeRejectedByTheValidationLogicToPreventDatabaseErrorsThisIsAVeryLongNameThatExceedsThe255CharacterLimitForTheNameFieldInTheDatabaseSchemaAndShouldBeRejectedByTheValidationLogicToPreventDatabaseErrorsThisIsAVeryLongName"
}

HTTP 400
[Asserts]
body contains "name must be less than 255 characters"