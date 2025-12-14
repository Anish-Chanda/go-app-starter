CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- enum for auth_provider
CREATE TYPE auth_provider AS ENUM ('local', 'google', 'github');

-- users table
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text,
    email VARCHAR(254) UNIQUE NOT NULL, -- Max length for email as per RFC 5321
    password_hash text, -- nullable for OAuth users
    auth_provider auth_provider NOT NULL DEFAULT 'local',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Contraints
    -- If auth_provider = 'local', password_hash must be set
    CONSTRAINT users_local_auth_requires_password CHECK (
        auth_provider <> 'local'
        OR password_hash IS NOT NULL
    )
);

-- index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);