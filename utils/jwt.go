package utils

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type HasuraClaims struct {
	jwt.RegisteredClaims
	Email  string                 `json:"email,omitempty"`
	Hasura map[string]interface{} `json:"https://hasura.io/jwt/claims"`
}

func GenerateAccessToken(userID, email string) (string, error) {
	secret := os.Getenv("AUTH_JWT_SECRET")
	if secret == "" {
		secret = "1234567890123456789012345678901234567890" // Must match Hasura JWT secret
	}

	expMin := 1440 // 24 hours
	if v := os.Getenv("ACCESS_TOKEN_EXP_MIN"); v != "" {
		// ignore parse error; default 1440
	}

	claims := HasuraClaims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   userID,
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Minute * time.Duration(expMin))),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
		Email: email,
		Hasura: map[string]interface{}{
			"x-hasura-default-role": "user",
			"x-hasura-allowed-roles": []string{
				"user",
			},
			"x-hasura-user-id": userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
