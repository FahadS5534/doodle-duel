-- Doodle Duel Initial Schema Migration

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255),
    is_guest BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_url VARCHAR(500),
    level INT NOT NULL DEFAULT 1,
    xp INT NOT NULL DEFAULT 0,
    coins INT NOT NULL DEFAULT 1000,
    streak INT NOT NULL DEFAULT 1,
    games_played INT NOT NULL DEFAULT 0,
    games_won INT NOT NULL DEFAULT 0,
    best_score INT NOT NULL DEFAULT 0,
    correct_guesses INT NOT NULL DEFAULT 0,
    drawings_completed INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS game_rooms (
    id UUID PRIMARY KEY,
    room_code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    host_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    visibility VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',
    status VARCHAR(30) NOT NULL DEFAULT 'WAITING',
    max_players INT NOT NULL DEFAULT 8,
    total_rounds INT NOT NULL DEFAULT 4,
    draw_time_seconds INT NOT NULL DEFAULT 60,
    difficulty VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    category VARCHAR(50) NOT NULL DEFAULT 'GENERAL',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS room_memberships (
    id UUID PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'PLAYER',
    is_ready BOOLEAN NOT NULL DEFAULT FALSE,
    connection_status VARCHAR(20) NOT NULL DEFAULT 'CONNECTED',
    joined_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_room_user UNIQUE (room_id, user_id)
);

CREATE TABLE IF NOT EXISTS game_matches (
    id UUID PRIMARY KEY,
    room_id UUID NOT NULL REFERENCES game_rooms(id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS',
    current_round INT NOT NULL DEFAULT 1,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS game_rounds (
    id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES game_matches(id) ON DELETE CASCADE,
    round_number INT NOT NULL,
    drawer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    secret_word VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    hint VARCHAR(100),
    status VARCHAR(30) NOT NULL DEFAULT 'DRAWING',
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS guesses (
    id UUID PRIMARY KEY,
    round_id UUID NOT NULL REFERENCES game_rounds(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    submitted_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    points_awarded INT NOT NULL DEFAULT 0,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS match_player_results (
    id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES game_matches(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    final_score INT NOT NULL DEFAULT 0,
    rank_position INT NOT NULL DEFAULT 1,
    correct_guesses INT NOT NULL DEFAULT 0,
    rounds_drawn INT NOT NULL DEFAULT 0,
    xp_earned INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_match_player UNIQUE (match_id, player_id)
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_room_code ON game_rooms(room_code);
CREATE INDEX IF NOT EXISTS idx_room_status ON game_rooms(status);
CREATE INDEX IF NOT EXISTS idx_membership_room ON room_memberships(room_id);
CREATE INDEX IF NOT EXISTS idx_membership_user ON room_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_guesses_round ON guesses(round_id);
CREATE INDEX IF NOT EXISTS idx_player_results_match ON match_player_results(match_id);
CREATE INDEX IF NOT EXISTS idx_player_results_player ON match_player_results(player_id);
CREATE INDEX IF NOT EXISTS idx_users_xp ON users(xp DESC);
CREATE INDEX IF NOT EXISTS idx_users_score ON users(best_score DESC);
