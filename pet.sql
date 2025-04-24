-- 1. Create the Database
CREATE DATABASE IF NOT EXISTS VirtualPetDB;
USE VirtualPetDB;

-- 2. Create Tables with improved naming conventions and constraints
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_email (email)  -- Index for email lookups
);

CREATE TABLE pets (
    pet_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(50),
    age INT CHECK (age >= 0),
    happiness_level INT NOT NULL DEFAULT 50,
    CONSTRAINT chk_happiness CHECK (happiness_level BETWEEN 0 AND 100),
    health_status VARCHAR(50) DEFAULT 'Healthy',
    user_id INT NOT NULL,  -- Added NOT NULL constraint
    FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    INDEX idx_pet_user (user_id)  -- Index for user lookups
);

CREATE TABLE foods (
    food_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    nutrition_value INT CHECK (nutrition_value > 0)
);

CREATE TABLE activities (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    effect_on_happiness INT,  -- Modified constraint to allow negative values
    CONSTRAINT chk_effect CHECK (effect_on_happiness BETWEEN -100 AND 100)
);

CREATE TABLE pet_food_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,  -- Added NOT NULL constraint
    food_id INT NOT NULL,  -- Added NOT NULL constraint
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES foods (food_id) ON DELETE CASCADE,
    INDEX idx_pet_food_log_pet (pet_id),  -- Index for pet lookups
    INDEX idx_pet_food_log_food (food_id)  -- Index for food lookups
);

CREATE TABLE pet_activity_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,  -- Added NOT NULL constraint
    activity_id INT NOT NULL,  -- Added NOT NULL constraint
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activities(activity_id) ON DELETE CASCADE,
    INDEX idx_pet_activity_log_pet (pet_id),  -- Index for pet lookups
    INDEX idx_pet_activity_log_activity (activity_id)  -- Index for activity lookups
);

-- 3. New Entities Added with improved naming
CREATE TABLE veterinarians (
    vet_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    contact_info VARCHAR(100)
);

CREATE TABLE health_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,  -- Added NOT NULL constraint
    vet_id INT,
    checkup_date DATE NOT NULL,  -- Added NOT NULL constraint
    diagnosis TEXT,
    treatment TEXT,
    FOREIGN KEY (pet_id) REFERENCES pets(pet_id) ON DELETE CASCADE,
    FOREIGN KEY (vet_id) REFERENCES veterinarians (vet_id) ON DELETE SET NULL,
    INDEX idx_health_record_pet (pet_id),  -- Index for pet lookups
    INDEX idx_health_record_vet (vet_id)  -- Index for vet lookups
);

-- 4. Insert Sample Data with updated table names
-- Users
INSERT INTO users (name, email, password) VALUES 
('Alice', 'alice@example.com', 'password123'),
('Bob', 'bob@example.com', 'securepass456'),
('Charlie', 'charlie@example.com', 'petlover789'),
('Diana', 'diana@example.com', 'doglover123'),
('Ethan', 'ethan@example.com', 'catperson456'),
('Fiona', 'fiona@example.com', 'birdfriend789'),
('George', 'george@example.com', 'reptilefan123');

-- Pets
INSERT INTO pets (name, species, breed, age, happiness_level, health_status, user_id) VALUES 
('Buddy', 'Dog', 'Golden Retriever', 3, 80, 'Healthy', 1),
('Whiskers', 'Cat', 'Siamese', 2, 70, 'Healthy', 2),
('Max', 'Dog', 'Labrador', 5, 90, 'Very Healthy', 3),
('Luna', 'Cat', 'Persian', 1, 65, 'Healthy', 4),
('Rocky', 'Dog', 'Bulldog', 4, 75, 'Slightly Overweight', 5),
('Milo', 'Cat', 'Maine Coon', 2, 85, 'Healthy', 6),
('Coco', 'Bird', 'Parrot', 10, 60, 'Needs Checkup', 7),
('Spike', 'Reptile', 'Bearded Dragon', 3, 40, 'Healthy', 7),  -- Fixed user_id reference
('Bella', 'Dog', 'Poodle', 2, 95, 'Very Healthy', 3),
('Oliver', 'Cat', 'Tabby', 4, 70, 'Healthy', 4);

-- Food Items
INSERT INTO foods (name, type, nutrition_value) VALUES 
('Dog Food', 'Dry', 50),
('Cat Food', 'Wet', 40),
('Premium Dog Food', 'Dry', 70),
('Organic Cat Food', 'Wet', 60),
('Bird Seeds', 'Dry', 30),
('Reptile Pellets', 'Dry', 35),
('Dog Treats', 'Snack', 15),
('Cat Treats', 'Snack', 10),
('Fish Flakes', 'Dry', 25),
('Premium Wet Dog Food', 'Wet', 65);

-- Activities
INSERT INTO activities (name, description, effect_on_happiness) VALUES 
('Playing Fetch', 'Throwing a ball for a dog to fetch.', 20),
('Scratching Post', 'A cat scratches a post to stay active.', 15),
('Walk in Park', 'Taking the dog for a walk in the park.', 25),
('Laser Pointer', 'Playing with cat using laser pointer.', 18),
('Bird Singing', 'Teaching bird to sing.', 15),
('Hide and Seek', 'Playing hide and seek with pet.', 22),
('Agility Training', 'Dog agility course training.', 30),
('Puzzle Feeder', 'Using puzzle feeder for mental stimulation.', 12),
('Cuddle Time', 'Spending quality cuddle time with pet.', 20),
('Bath Time', 'Giving pet a bath and grooming.', -10);

-- Pet Food Logs
INSERT INTO pet_food_logs (pet_id, food_id) VALUES 
(1, 1), (1, 7), -- Buddy eats Dog Food and Dog Treats
(2, 2), (2, 8), -- Whiskers eats Cat Food and Cat Treats
(3, 3), (3, 7), -- Max eats Premium Dog Food and Dog Treats
(4, 4), (4, 8), -- Luna eats Organic Cat Food and Cat Treats
(5, 3), -- Rocky eats Premium Dog Food
(6, 4), -- Milo eats Organic Cat Food
(7, 5), -- Coco eats Bird Seeds
(8, 6), -- Spike eats Reptile Pellets
(9, 1), (9, 7), -- Bella eats Dog Food and Dog Treats
(10, 2), (10, 8); -- Oliver eats Cat Food and Cat Treats

-- Pet Activity Logs
INSERT INTO pet_activity_logs (pet_id, activity_id) VALUES 
(1, 1), (1, 7), -- Buddy plays fetch and does agility
(2, 2), (2, 9), -- Whiskers uses scratching post and cuddles
(3, 3), (3, 7), -- Max walks and does agility
(4, 4), (4, 9), -- Luna plays with laser and cuddles
(5, 3), (5, 10), -- Rocky walks and has bath
(6, 4), (6, 6), -- Milo uses laser and hide and seek
(7, 5), -- Coco sings
(8, 8), -- Spike uses puzzle feeder
(9, 3), (9, 7), -- Bella walks and does agility
(10, 4), (10, 9); -- Oliver uses laser and cuddles

-- Veterinarians
INSERT INTO veterinarians (name, specialization, contact_info) VALUES 
('Dr. Smith', 'Canine Specialist', '9876543210'),
('Dr. Johnson', 'Feline Specialist', '8765432109'),
('Dr. Wilson', 'Avian Specialist', '7654321098'),
('Dr. Brown', 'Exotic Animals', '6543210987'),
('Dr. Davis', 'General Practice', '5432109876'),
('Dr. Miller', 'Dermatology', '4321098765');

-- Health Records
INSERT INTO health_records (pet_id, vet_id, checkup_date, diagnosis, treatment) VALUES 
(1, 1, '2025-03-01', 'Routine Checkup', 'No issues, general care advised.'),
(2, 2, '2025-03-05', 'Minor skin infection', 'Prescribed antibiotics.'),
(3, 1, '2025-03-10', 'Annual checkup', 'Vaccines updated'),
(4, 2, '2025-03-12', 'Eye irritation', 'Eye drops prescribed'),
(5, 3, '2025-03-15', 'Weight management', 'Diet plan created'),
(6, 2, '2025-03-18', 'Dental check', 'Teeth cleaning recommended'),
(7, 4, '2025-03-20', 'Feather plucking', 'Behavioral therapy suggested'),
(8, 4, '2025-03-22', 'Skin shedding', 'Normal process observed'),
(9, 1, '2025-03-25', 'Ear infection', 'Antibiotics prescribed'),
(10, 2, '2025-03-28', 'Annual checkup', 'Everything normal');

-- 5. Optimized Queries
-- Get all pets with their owners
SELECT 
    p.name AS pet_name, 
    p.species, 
    p.breed, 
    p.age, 
    p.happiness_level, 
    u.name AS owner_name
FROM pets p
JOIN users u ON p.user_id = u.user_id;

-- Get all pet activities with effects
SELECT 
    p.name AS pet_name, 
    a.name AS activity_name, 
    a.effect_on_happiness, 
    l.date
FROM pet_activity_logs l
JOIN pets p ON l.pet_id = p.pet_id
JOIN activities a ON l.activity_id = a.activity_id
ORDER BY l.date DESC;

-- Get all health records with vet info
SELECT 
    p.name AS pet_name, 
    v.name AS veterinarian_name, 
    h.checkup_date, 
    h.diagnosis, 
    h.treatment
FROM health_records h
JOIN pets p ON h.pet_id = p.pet_id
JOIN veterinarians v ON h.vet_id = v.vet_id
ORDER BY h.checkup_date DESC;

DELIMITER //

CREATE TRIGGER prevent_negative_happiness
BEFORE UPDATE ON pets
FOR EACH ROW
BEGIN
    IF NEW.happiness_level < 0 THEN
        SET NEW.happiness_level = 0;
    ELSEIF NEW.happiness_level > 100 THEN
        SET NEW.happiness_level = 100;
    END IF;
END;
//

CREATE PROCEDURE feed_pet(IN p_pet_id INT, IN p_food_id INT)
BEGIN
    DECLARE food_effect INT;
    DECLARE exit_handler BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET exit_handler = TRUE;
        ROLLBACK;
        SELECT 'An error occurred during the feeding process.' AS message;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id) THEN
        SELECT CONCAT('Pet with ID ', p_pet_id, ' does not exist.') AS message;
        SET exit_handler = TRUE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM foods WHERE food_id = p_food_id) THEN
        SELECT CONCAT('Food with ID ', p_food_id, ' does not exist.') AS message;
        SET exit_handler = TRUE;
    END IF;

    IF exit_handler THEN
        ROLLBACK;
    ELSE
        SELECT nutrition_value INTO food_effect FROM foods WHERE food_id = p_food_id;

        UPDATE pets
        SET happiness_level = 
            CASE 
                WHEN happiness_level + food_effect > 100 THEN 100
                WHEN happiness_level + food_effect < 0 THEN 0
                ELSE happiness_level + food_effect
            END
        WHERE pet_id = p_pet_id;

        INSERT INTO pet_food_logs (pet_id, food_id) VALUES (p_pet_id, p_food_id);

        COMMIT;

        SELECT CONCAT('Successfully fed pet ID ', p_pet_id, ' with food ID ', p_food_id, '.') AS message;
    END IF;
END;
//

CREATE PROCEDURE play_with_pet(IN p_pet_id INT, IN p_activity_id INT)
BEGIN
    DECLARE happiness_effect INT;
    DECLARE exit_handler BOOLEAN DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET exit_handler = TRUE;
        ROLLBACK;
        SELECT 'An error occurred during the play activity.' AS message;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id) THEN
        SELECT CONCAT('Pet with ID ', p_pet_id, ' does not exist.') AS message;
        SET exit_handler = TRUE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM activities WHERE activity_id = p_activity_id) THEN
        SELECT CONCAT('Activity with ID ', p_activity_id, ' does not exist.') AS message;
        SET exit_handler = TRUE;
    END IF;

    IF exit_handler THEN
        ROLLBACK;
    ELSE
        SELECT effect_on_happiness INTO happiness_effect FROM activities WHERE activity_id = p_activity_id;

        UPDATE pets
        SET happiness_level = 
            CASE 
                WHEN happiness_level + happiness_effect > 100 THEN 100
                WHEN happiness_level + happiness_effect < 0 THEN 0
                ELSE happiness_level + happiness_effect
            END
        WHERE pet_id = p_pet_id;

        INSERT INTO pet_activity_logs (pet_id, activity_id) VALUES (p_pet_id, p_activity_id);

        COMMIT;

        SELECT CONCAT('Successfully played with pet ID ', p_pet_id, ' using activity ID ', p_activity_id, '.') AS message;
    END IF;
END;
//

CREATE PROCEDURE get_pet_status(IN p_pet_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id) THEN
        SELECT CONCAT('Pet with ID ', p_pet_id, ' does not exist.') AS message;
    ELSE
        SELECT 
            p.name AS pet_name,
            p.species,
            p.breed,
            p.age,
            p.happiness_level,
            p.health_status,
            u.name AS owner_name
        FROM pets p
        JOIN users u ON p.user_id = u.user_id
        WHERE p.pet_id = p_pet_id;

        SELECT 
            f.name AS food_name,
            f.type AS food_type,
            f.nutrition_value,
            l.date AS feeding_date
        FROM pet_food_logs l
        JOIN foods f ON l.food_id = f.food_id
        WHERE l.pet_id = p_pet_id
        ORDER BY l.date DESC
        LIMIT 5;

        SELECT 
            a.name AS activity_name,
            a.effect_on_happiness,
            l.date AS activity_date
        FROM pet_activity_logs l
        JOIN activities a ON l.activity_id = a.activity_id
        WHERE l.pet_id = p_pet_id
        ORDER BY l.date DESC
        LIMIT 5;

        SELECT 
            v.name AS veterinarian_name,
            v.specialization,
            h.checkup_date,
            h.diagnosis,
            h.treatment
        FROM health_records h
        JOIN veterinarians v ON h.vet_id = v.vet_id
        WHERE h.pet_id = p_pet_id
        ORDER BY h.checkup_date DESC
        LIMIT 3;
    END IF;
END;
//

DELIMITER ;




