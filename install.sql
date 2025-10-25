CREATE TABLE IF NOT EXISTS nino_duty_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(50),
    identifier VARCHAR(50),
    department VARCHAR(10),
    duty_start DATETIME DEFAULT CURRENT_TIMESTAMP,
    duty_end DATETIME NULL,
    duty_time_secs INT NULL
);