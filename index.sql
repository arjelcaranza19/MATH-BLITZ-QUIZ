CREATE DATABASE math_blitz;
USE math_blitz;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    PASSWORD VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE game_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    score INT NOT NULL,
    accuracy INT NOT NULL,
    time_result INT NOT NULL,
    correct INT NOT NULL,
    wrong INT NOT NULL,
    rank CHAR(1) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
