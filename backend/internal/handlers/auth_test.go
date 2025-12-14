package handlers

import (
	"strings"
	"testing"
)

func TestHashPassword(t *testing.T) {
	tests := []struct {
		name     string
		password string
		wantErr  bool
	}{
		{
			name:     "valid password",
			password: "testPassword123",
			wantErr:  false,
		},
		{
			name:     "empty password",
			password: "",
			wantErr:  false, // hashPassword should handle empty strings
		},
		{
			name:     "long password",
			password: strings.Repeat("a", 1000),
			wantErr:  false,
		},
		{
			name:     "password with special characters",
			password: "test@#$%^&*()_+-={}[]|\\:;\"'<>?,./_",
			wantErr:  false,
		},
		{
			name:     "unicode password",
			password: "测试密码123",
			wantErr:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hash, err := hashPassword(tt.password)

			if (err != nil) != tt.wantErr {
				t.Errorf("hashPassword() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr {
				// Verify hash format
				if !strings.HasPrefix(hash, "$argon2id$") {
					t.Errorf("hashPassword() = %v, expected hash to start with $argon2id$", hash)
				}

				// Verify hash has correct number of fields
				fields := strings.Split(hash, "$")
				if len(fields) != 6 {
					t.Errorf("hashPassword() = %v, expected hash to have 6 fields, got %d", hash, len(fields))
				}

				// Verify hash is not empty
				if hash == "" {
					t.Errorf("hashPassword() returned empty hash")
				}
			}
		})
	}
}

func TestHashPasswordUniqueness(t *testing.T) {
	password := "testPassword123"

	hash1, err1 := hashPassword(password)
	if err1 != nil {
		t.Fatalf("hashPassword() error = %v", err1)
	}

	hash2, err2 := hashPassword(password)
	if err2 != nil {
		t.Fatalf("hashPassword() error = %v", err2)
	}

	// Hashes should be different due to different salts
	if hash1 == hash2 {
		t.Errorf("hashPassword() produced identical hashes for same password: %s", hash1)
	}
}

func TestVerifyPassword(t *testing.T) {
	// Generate a test hash first
	testPassword := "testPassword123"
	testHash, err := hashPassword(testPassword)
	if err != nil {
		t.Fatalf("Failed to generate test hash: %v", err)
	}

	tests := []struct {
		name     string
		password string
		encoded  string
		want     bool
		wantErr  bool
	}{
		{
			name:     "valid password and hash",
			password: testPassword,
			encoded:  testHash,
			want:     true,
			wantErr:  false,
		},
		{
			name:     "invalid password",
			password: "wrongPassword",
			encoded:  testHash,
			want:     false,
			wantErr:  false,
		},
		{
			name:     "empty password",
			password: "",
			encoded:  testHash,
			want:     false,
			wantErr:  false,
		},
		{
			name:     "invalid hash format - too few fields",
			password: testPassword,
			encoded:  "$argon2id$v=19$m=19456",
			want:     false,
			wantErr:  true,
		},
		{
			name:     "invalid hash format - wrong algorithm",
			password: testPassword,
			encoded:  "$bcrypt$v=19$m=19456,t=1,p=2$salt$hash",
			want:     false,
			wantErr:  true,
		},
		{
			name:     "invalid hash format - malformed params",
			password: testPassword,
			encoded:  "$argon2id$v=19$invalid$salt$hash",
			want:     false,
			wantErr:  true,
		},
		{
			name:     "invalid hash format - invalid base64 salt",
			password: testPassword,
			encoded:  "$argon2id$v=19$m=19456,t=1,p=2$!!!invalid!!!$hash",
			want:     false,
			wantErr:  true,
		},
		{
			name:     "invalid hash format - invalid base64 hash",
			password: testPassword,
			encoded:  "$argon2id$v=19$m=19456,t=1,p=2$c2FsdA$!!!invalid!!!",
			want:     false,
			wantErr:  true,
		},
		{
			name:     "empty encoded hash",
			password: testPassword,
			encoded:  "",
			want:     false,
			wantErr:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := verifyPassword(tt.password, tt.encoded)

			if (err != nil) != tt.wantErr {
				t.Errorf("verifyPassword() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if got != tt.want {
				t.Errorf("verifyPassword() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestVerifyPasswordWithDifferentPasswords(t *testing.T) {
	passwords := []string{
		"simplePassword",
		"complex@Password123!",
		"unicode测试密码",
		"",
		strings.Repeat("a", 500),
	}

	for _, password := range passwords {
		t.Run("password_"+password, func(t *testing.T) {
			hash, err := hashPassword(password)
			if err != nil {
				t.Fatalf("hashPassword() error = %v", err)
			}

			// Verify correct password
			valid, err := verifyPassword(password, hash)
			if err != nil {
				t.Errorf("verifyPassword() error = %v", err)
			}
			if !valid {
				t.Errorf("verifyPassword() = false, want true for correct password")
			}

			// Verify incorrect password
			wrongPassword := password + "wrong"
			valid, err = verifyPassword(wrongPassword, hash)
			if err != nil {
				t.Errorf("verifyPassword() error = %v", err)
			}
			if valid {
				t.Errorf("verifyPassword() = true, want false for incorrect password")
			}
		})
	}
}

func TestPasswordHashingConstants(t *testing.T) {
	// Test that the constants are as expected
	if argonTime != 1 {
		t.Errorf("argonTime = %v, want 1", argonTime)
	}
	if argonMemory != 19456 {
		t.Errorf("argonMemory = %v, want 19456", argonMemory)
	}
	if argonThreads != 2 {
		t.Errorf("argonThreads = %v, want 2", argonThreads)
	}
	if argonSaltLen != 16 {
		t.Errorf("argonSaltLen = %v, want 16", argonSaltLen)
	}
	if argonKeyLen != 32 {
		t.Errorf("argonKeyLen = %v, want 32", argonKeyLen)
	}
}

// Benchmark tests to ensure reasonable performance
func BenchmarkHashPassword(b *testing.B) {
	password := "testPassword123"

	for i := 0; i < b.N; i++ {
		_, err := hashPassword(password)
		if err != nil {
			b.Fatalf("hashPassword() error = %v", err)
		}
	}
}

func BenchmarkVerifyPassword(b *testing.B) {
	password := "testPassword123"
	hash, err := hashPassword(password)
	if err != nil {
		b.Fatalf("hashPassword() error = %v", err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := verifyPassword(password, hash)
		if err != nil {
			b.Fatalf("verifyPassword() error = %v", err)
		}
	}
}
