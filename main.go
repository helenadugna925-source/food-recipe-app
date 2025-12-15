package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/gin-contrib/cors"
    "golang.org/x/crypto/bcrypt"

    "recipe-auth/db"
    "recipe-auth/utils"
)

var jwtSecret = []byte("1234567890123456789012345678901234567890") // Must match Hasura JWT

func main() {
    // 1️⃣ Database connection
   // Connect to database
databaseURL := os.Getenv("DATABASE_URL")
if databaseURL == "" {
    databaseURL = "postgres://postgres:postgrespassword@localhost:5432/recipes_db?sslmode=disable"
}

log.Printf("Connecting to database: %s", databaseURL)

ctx := context.Background()
pool, err := db.Connect(ctx, databaseURL)
if err != nil {
    log.Fatalf("Failed to connect to database: %v", err)
}
defer pool.Close()

if err := pool.Ping(ctx); err != nil {
    log.Fatalf("Failed to ping database: %v", err)
}

log.Println("Successfully connected to database")


    // 2️⃣ Gin setup
    r := gin.New()
    r.Use(gin.Logger())
    r.Use(gin.Recovery())

    // 3️⃣ CORS
    r.Use(cors.New(cors.Config{
        AllowOrigins:     []string{"http://localhost:3000", "http://localhost:3001", "http://localhost:3002"},
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Authorization", "Content-Type"},
        AllowCredentials: true,
    }))

    // --------------------
    // Signup
    // --------------------
    r.POST("/signup", func(c *gin.Context) {
        var body struct {
            Name     string `json:"name"`
            Email    string `json:"email"`
            Password string `json:"password"`
        }
        if err := c.ShouldBindJSON(&body); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        if body.Name == "" || body.Email == "" || body.Password == "" {
            c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required fields"})
            return
        }

        // Check if user exists
        var exists bool
        queryCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
        defer cancel()
        err := pool.QueryRow(queryCtx, "SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)", body.Email).Scan(&exists)
        if err != nil {
            log.Printf("Database query error: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
            return
        }
        if exists {
            c.JSON(http.StatusBadRequest, gin.H{"error": "User already exists"})
            return
        }

        // Hash password
        hashedPassword, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
        if err != nil {
            log.Printf("Password hash error: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
            return
        }

        // Insert user
        var userID string
        err = pool.QueryRow(ctx,
            "INSERT INTO users (email, name, password_hash) VALUES ($1, $2, $3) RETURNING id",
            body.Email, body.Name, string(hashedPassword),
        ).Scan(&userID)
        if err != nil {
            log.Printf("Database insert error: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
            return
        }

        // Generate JWT
        token, err := utils.GenerateAccessToken(userID, body.Email)
        if err != nil {
            log.Printf("Token generation error: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
            return
        }

        c.JSON(http.StatusOK, gin.H{
            "token":   token,
            "user_id": userID,
            "email":   body.Email,
            "name":    body.Name,
        })
    })

    // --------------------
    // Login
    // --------------------
    r.POST("/login", func(c *gin.Context) {
        var body struct {
            Email    string `json:"email"`
            Password string `json:"password"`
        }
        if err := c.ShouldBindJSON(&body); err != nil {
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }

        if body.Email == "" || body.Password == "" {
            c.JSON(http.StatusBadRequest, gin.H{"error": "Missing email or password"})
            return
        }

        var userID, name, passwordHash string
        err := pool.QueryRow(ctx,
            "SELECT id, name, password_hash FROM users WHERE email=$1",
            body.Email,
        ).Scan(&userID, &name, &passwordHash)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
            return
        }

        if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(body.Password)); err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
            return
        }

        token, err := utils.GenerateAccessToken(userID, body.Email)
        if err != nil {
            log.Printf("Token generation error: %v", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
            return
        }

        c.JSON(http.StatusOK, gin.H{
            "token":   token,
            "user_id": userID,
            "email":   body.Email,
            "name":    name,
        })
    })

    log.Println("Auth service running on :8081")
    r.Run(":8081")
}
