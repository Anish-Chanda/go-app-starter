# Test API health endpoint
GET http://localhost:8080/api/health

HTTP 200
[Asserts]
body == "OK"
# NOTE: you might have to change the abve if you customize the health endpoint response