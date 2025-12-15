package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"recipe-auth/utils"
)

type Handler struct {
	db *pgxpool.Pool
}

func NewHandler(db *pgxpool.Pool) *Handler {
	return &Handler{db: db}
}

type signupReq struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type authResp struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	UserID       string `json:"user_id"`
	Email        string `json:"email"`
	Name         string `json:"name"`
}

func (h *Handler) SignUp(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var req signupReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid body", http.StatusBadRequest)
		return
	}
	if req.Email == "" || req.Password == "" || req.Name == "" {
		http.Error(w, "missing fields", http.StatusBadRequest)
		return
	}

	// check if user exists
	var exists bool
	err := h.db.QueryRow(ctx, "SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)", req.Email).Scan(&exists)
	if err != nil {
		http.Error(w, "db error", http.StatusInternalServerError)
		return
	}
	if exists {
		http.Error(w, "email already registered", http.StatusConflict)
		return
	}

	pwHash, err := utils.HashPassword(req.Password)
	if err != nil {
		http.Error(w, "hash error", http.StatusInternalServerError)
		return
	}

	// insert user and return id
	var userID string
	err = h.db.QueryRow(ctx,
		`INSERT INTO users (email, username, password_hash, display_name, created_at)
         VALUES ($1, $2, $3, $4, now()) RETURNING id`,
		req.Email, req.Name, pwHash, req.Name).Scan(&userID)
	if err != nil {
		http.Error(w, fmt.Sprintf("insert error: %v", err), http.StatusInternalServerError)
		return
	}

	accessToken, err := utils.GenerateAccessToken(userID, req.Email)
	if err != nil {
		http.Error(w, "token error", http.StatusInternalServerError)
		return
	}
	refreshToken := uuid.NewString()
	rtExpiryDays := 30
	if v := os.Getenv("REFRESH_TOKEN_EXP_DAYS"); v != "" {
		// skip custom parse to keep example short
	}

	_, err = h.db.Exec(ctx, `INSERT INTO refresh_tokens (user_id, token, expires_at, created_at) VALUES ($1, $2, $3, now())`,
		userID, refreshToken, time.Now().AddDate(0, 0, rtExpiryDays))
	if err != nil {
		http.Error(w, "refresh token store error", http.StatusInternalServerError)
		return
	}

	resp := authResp{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		UserID:       userID,
		Email:        req.Email,
		Name:         req.Name,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

type signinReq struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *Handler) SignIn(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var req signinReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid body", http.StatusBadRequest)
		return
	}
	if req.Email == "" || req.Password == "" {
		http.Error(w, "missing fields", http.StatusBadRequest)
		return
	}

	var userID, pwHash, username string
	err := h.db.QueryRow(ctx, "SELECT id, password_hash, username FROM users WHERE email=$1", req.Email).
		Scan(&userID, &pwHash, &username)
	if err != nil {
		http.Error(w, "invalid credentials", http.StatusUnauthorized)
		return
	}

	if err := utils.CheckPasswordHash(pwHash, req.Password); err != nil {
		http.Error(w, "invalid credentials", http.StatusUnauthorized)
		return
	}

	accessToken, err := utils.GenerateAccessToken(userID, req.Email)
	if err != nil {
		http.Error(w, "token error", http.StatusInternalServerError)
		return
	}
	refreshToken := uuid.NewString()
	rtExpiryDays := 30

	_, err = h.db.Exec(ctx, `INSERT INTO refresh_tokens (user_id, token, expires_at, created_at)
                                 VALUES ($1, $2, $3, now())`, userID, refreshToken, time.Now().AddDate(0, 0, rtExpiryDays))
	if err != nil {
		http.Error(w, "refresh token store error", http.StatusInternalServerError)
		return
	}

	resp := authResp{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		UserID:       userID,
		Email:        req.Email,
		Name:         username,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

type refreshReq struct {
	RefreshToken string `json:"refresh_token"`
}

// RefreshToken checks refresh_tokens table and issues a new access token
func (h *Handler) RefreshToken(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	var req refreshReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid body", http.StatusBadRequest)
		return
	}
	if req.RefreshToken == "" {
		http.Error(w, "missing refresh token", http.StatusBadRequest)
		return
	}

	var userID string
	var expiresAt time.Time
	err := h.db.QueryRow(ctx, "SELECT user_id, expires_at FROM refresh_tokens WHERE token=$1", req.RefreshToken).Scan(&userID, &expiresAt)
	if err != nil {
		http.Error(w, "invalid refresh token", http.StatusUnauthorized)
		return
	}
	if time.Now().After(expiresAt) {
		http.Error(w, "refresh token expired", http.StatusUnauthorized)
		return
	}

	// get user email
	var email string
	err = h.db.QueryRow(ctx, "SELECT email FROM users WHERE id=$1", userID).Scan(&email)
	if err != nil {
		http.Error(w, "user not found", http.StatusInternalServerError)
		return
	}

	accessToken, err := utils.GenerateAccessToken(userID, email)
	if err != nil {
		http.Error(w, "token error", http.StatusInternalServerError)
		return
	}

	resp := map[string]string{"access_token": accessToken}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
