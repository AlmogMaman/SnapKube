CREATE TABLE IF NOT EXISTS screenshots (
    id SERIAL PRIMARY KEY,
    url TEXT NOT NULL,
    filepath TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'completed',
    image_data TEXT NOT NULL
);

CREATE INDEX idx_created_at ON screenshots(created_at); 