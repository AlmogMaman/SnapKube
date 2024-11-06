CREATE TABLE user_screenshots (
    screenshot_id BIGINT UNIQUE PRIMARY KEY, 
    row_number SERIAL,     
    user_id INTEGER,                           
    username TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    page_url TEXT,
    width INTEGER,
    height INTEGER,
    file_format TEXT,
    file_size BIGINT,
    creation_time TIMESTAMP WITH TIME ZONE,
    modification_time TIMESTAMP WITH TIME ZONE
);
