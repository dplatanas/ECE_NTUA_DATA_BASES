DROP SCHEMA if exists music_festival;
CREATE SCHEMA music_festival;
use music_festival;
-- Drop tables if they exist (to avoid foreign key conflicts)
DROP TABLE IF EXISTS Staff_Assignment;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Resale_Interest;
DROP TABLE IF EXISTS Resale_Queue;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS Performance;
DROP TABLE IF EXISTS performance_members;
DROP TABLE IF EXISTS Artist_Genres;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Artist_Group_Members;
DROP TABLE IF EXISTS Artist_Group;
DROP TABLE IF EXISTS Artist;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Stage_Equipment;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Stage;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Festival;

-- Creating our tables
CREATE TABLE location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    address TEXT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    city VARCHAR(50),
    country VARCHAR(50),
    continent VARCHAR(50)
);

CREATE TABLE festival (
    festival_id INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT,
    name VARCHAR(100),
    year INT NOT NULL CHECK (year >= 2000),
    duration_days INT CHECK (duration_days BETWEEN 1 AND 7),
    poster_image TEXT,
    description TEXT,
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    UNIQUE(year)
);

CREATE INDEX idx_festival_year ON festival(year);

CREATE TABLE stage (
    stage_id INT AUTO_INCREMENT PRIMARY KEY,
    festival_id INT,
    name VARCHAR(100) UNIQUE,
    description TEXT,
    capacity INT CHECK (capacity > 0),
    image TEXT,
    FOREIGN KEY (festival_id) REFERENCES festival(festival_id)
);

CREATE TABLE equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    description TEXT,
    image TEXT
);

CREATE TABLE stage_equipment (
    stage_id INT,
    equipment_id INT,
    quantity INT CHECK (quantity >= 0),
    PRIMARY KEY (stage_id, equipment_id),
    FOREIGN KEY (stage_id) REFERENCES stage(stage_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
);

--  Σκηνή και εξοπλισμός
CREATE INDEX idx_stage_equipment_stage ON stage_equipment(stage_id);
CREATE INDEX idx_stage_equipment_equipment ON stage_equipment(equipment_id);

CREATE TABLE event (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    festival_id INT,
    stage_id INT,
    event_date DATE,
    total_duration TIME CHECK (total_duration <= '12:00:00'),
    FOREIGN KEY (festival_id) REFERENCES festival(festival_id),
    FOREIGN KEY (stage_id) REFERENCES stage(stage_id)
);

CREATE TABLE artist (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    stage_name VARCHAR(100),
    dob DATE,
    website TEXT,
    instagram TEXT,
    photo TEXT
);

CREATE TABLE artist_group (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    formation_date DATE,
    website TEXT,
    photo TEXT
);

CREATE TABLE artist_group_members (
    group_id INT,
    artist_id INT,
    PRIMARY KEY (group_id, artist_id),
    FOREIGN KEY (group_id) REFERENCES artist_group(group_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

--  Συμμετοχές group
CREATE INDEX idx_group_members_artist ON artist_group_members(artist_id);
CREATE INDEX idx_group_members_group ON artist_group_members(group_id);


CREATE TABLE genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    subgenre VARCHAR(50)
);

CREATE TABLE artist_genres (
    artist_id INT,
    genre_id INT,
    PRIMARY KEY (artist_id, genre_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE INDEX idx_artist_genre_artist ON artist_genres(artist_id);
CREATE INDEX idx_artist_genre_genre ON artist_genres(genre_id);

CREATE TABLE performance (
    performance_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    start_time DATETIME,
    stage_id INT,
    duration TIME CHECK (duration <= '03:00:00'),
    type VARCHAR(50),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (stage_id) REFERENCES stage(stage_id)
);

CREATE TABLE performance_members (
    performance_members_id             INT AUTO_INCREMENT PRIMARY KEY,
    performance_id INT         NOT NULL,
    artist_id      INT         ,
    group_id       INT         NULL,
    -- ensure no duplicate assignment of the same artist OR group to a performance
    UNIQUE KEY uk_perf_member (performance_id, artist_id, group_id),
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id),
    FOREIGN KEY (artist_id)      REFERENCES artist(artist_id),
    FOREIGN KEY (group_id)       REFERENCES artist_group(group_id)
);

--  Εμφανίσεις ανά καλλιτέχνη και event
CREATE INDEX idx_performance_artist ON performance_members(artist_id);
CREATE INDEX idx_performance_event ON performance(event_id);


CREATE TABLE visitor (
    visitor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30),
    age INT CHECK (age > 0)
);

CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    visitor_id INT,
    ticket_category VARCHAR(20) NOT NULL,
    price DECIMAL(8,2),
    purchase_date DATE,
    payment_method VARCHAR(20) NOT NULL,
    ean_code VARCHAR(13) UNIQUE,
    activated BOOLEAN DEFAULT FALSE,
    is_resale BOOLEAN DEFAULT FALSE,
    UNIQUE (visitor_id, event_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(visitor_id),
    CONSTRAINT chk_ticket_category CHECK (ticket_category IN ('general', 'VIP', 'backstage')),
    CONSTRAINT chk_payment_method CHECK (payment_method IN ('credit_card', 'debit_card', 'bank_transfer'))
);

CREATE TABLE resale_queue (
    resale_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    listed_by INT,
    event_id INT,
    ticket_category VARCHAR(20) NOT NULL,
    listed_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY (listed_by) REFERENCES visitor(visitor_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    CONSTRAINT chk_resale_ticket_category CHECK (ticket_category IN ('general', 'VIP', 'backstage'))
    -- CHECK ((SELECT activated FROM Ticket WHERE Ticket.ticket_id = Resale_Queue.ticket_id) = FALSE)
);

CREATE TABLE resale_interest (
    interest_id INT AUTO_INCREMENT PRIMARY KEY,
    interested_visitor_id INT,
    event_id INT,
    ticket_category VARCHAR(20) NOT NULL,
    expressed_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (interested_visitor_id) REFERENCES visitor(visitor_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    CHECK (ticket_category IN ('general', 'VIP', 'backstage'))
);

--  Εισιτήρια ανά επισκέπτη ή event
CREATE INDEX idx_ticket_visitor ON ticket(visitor_id);
CREATE INDEX idx_ticket_event ON ticket(event_id);

CREATE TABLE review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    visitor_id INT,
    performance_id INT,
    interpretation SMALLINT CHECK (interpretation BETWEEN 1 AND 5),
    lights_sound SMALLINT CHECK (lights_sound BETWEEN 1 AND 5),
    stage_presence SMALLINT CHECK (stage_presence BETWEEN 1 AND 5),
    organization SMALLINT CHECK (organization BETWEEN 1 AND 5),
    overall_impression SMALLINT CHECK (overall_impression BETWEEN 1 AND 5),
    UNIQUE (visitor_id, performance_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor(visitor_id),
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id)
);

--  Αξιολογήσεις
CREATE INDEX idx_review_performance ON review(performance_id);
CREATE INDEX idx_review_visitor ON review(visitor_id);


CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    age INT CHECK (age > 0),
    staff_role VARCHAR(20) NOT NULL,
    experience_level VARCHAR(20) NOT NULL,
    CONSTRAINT chk_staff_role CHECK (staff_role IN ('technician', 'security', 'support')),
    CONSTRAINT chk_experience_level CHECK (experience_level IN ('intern', 'junior', 'average', 'experienced', 'senior'))
);

CREATE TABLE staff_assignment (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT,
    event_id INT,
    assignment_date DATE,
    staff_role VARCHAR(20) NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (event_id) REFERENCES event(event_id),
    CONSTRAINT chk_assignment_role CHECK (staff_role IN ('technician', 'security', 'support'))
);

--  Προσωπικό ανά event και ρόλο
CREATE INDEX idx_staff_assignment_event ON staff_assignment(event_id);
CREATE INDEX idx_staff_assignment_staff ON staff_assignment(staff_id);
CREATE INDEX idx_staff_assignment_date ON staff_assignment(assignment_date);

-- And now the Triggers!
DELIMITER $$

-- Overlapping performance on the same stage and date
CREATE TRIGGER chk_performance_no_overlap_insert
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
  DECLARE cnt INT;
  DECLARE v_stage INT;
  DECLARE v_date DATE;

  -- Finding the stage and date of the new performance
  SELECT stage_id, event_date
    INTO v_stage, v_date
    FROM Event
   WHERE event_id = NEW.event_id;

  -- Find how many existing performances overlap
  SELECT COUNT(*) INTO cnt
    FROM performance p
    JOIN Event ev ON p.event_id = ev.event_id
   WHERE ev.stage_id    = v_stage
     AND ev.event_date  = v_date
     AND TIME_TO_SEC(NEW.start_time) < TIME_TO_SEC(p.start_time)  + TIME_TO_SEC(p.duration)
     AND TIME_TO_SEC(p.start_time) < TIME_TO_SEC(NEW.start_time)  + TIME_TO_SEC(NEW.duration);

  IF cnt > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Overlapping performance on the same stage and date';
  END IF;
END$$

-- No more than 3 years in a row
-- BEFORE INSERT trigger
CREATE TRIGGER chk_no_4yrs_in_row_insert
BEFORE INSERT ON performance_members
FOR EACH ROW
BEGIN
  DECLARE v_year INT;

  -- Find the event year
  SELECT YEAR(e.event_date)
    INTO v_year
    FROM performance p
    JOIN event e ON p.event_id = e.event_id
   WHERE p.performance_id = NEW.performance_id;

  -- For individual artist
  IF NEW.artist_id IS NOT NULL THEN
    IF (
      SELECT COUNT(DISTINCT YEAR(e2.event_date))
        FROM performance_members pm2
        JOIN performance p2 ON pm2.performance_id = p2.performance_id
        JOIN event e2        ON p2.event_id         = e2.event_id
       WHERE pm2.artist_id = NEW.artist_id
         AND YEAR(e2.event_date) IN (v_year-1, v_year-2, v_year-3)
    ) = 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An artist has already participated for 3 years in a row';
    END IF;

  -- For group
  ELSEIF NEW.group_id IS NOT NULL THEN
    IF (
      SELECT COUNT(DISTINCT YEAR(e2.event_date))
        FROM performance_members pm2
        JOIN performance p2 ON pm2.performance_id = p2.performance_id
        JOIN event e2        ON p2.event_id         = e2.event_id
       WHERE pm2.group_id = NEW.group_id
         AND YEAR(e2.event_date) IN (v_year-1, v_year-2, v_year-3)
    ) = 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A group has already participated for 3 years in a row';
    END IF;
  END IF;
END$$

-- BEFORE UPDATE trigger (in case someone reassigns an existing row)
CREATE TRIGGER chk_no_4yrs_in_row_update
BEFORE UPDATE ON performance_members
FOR EACH ROW
BEGIN
  DECLARE v_year INT;

  SELECT YEAR(e.event_date)
    INTO v_year
    FROM performance p
    JOIN event e ON p.event_id = e.event_id
   WHERE p.performance_id = NEW.performance_id;

-- For individual artist
  IF NEW.artist_id IS NOT NULL THEN
    IF (
      SELECT COUNT(DISTINCT YEAR(e2.event_date))
        FROM performance_members pm2
        JOIN performance p2 ON pm2.performance_id = p2.performance_id
        JOIN event e2        ON p2.event_id         = e2.event_id
       WHERE pm2.artist_id = NEW.artist_id
         AND (pm2.performance_members_id <> OLD.performance_members_id)
         AND YEAR(e2.event_date) IN (v_year-1, v_year-2, v_year-3)
    ) = 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An artist has already participated for 3 years in a row';
    END IF;

-- For group
  ELSEIF NEW.group_id IS NOT NULL THEN
    IF (
      SELECT COUNT(DISTINCT YEAR(e2.event_date))
        FROM performance_members pm2
        JOIN performance p2 ON pm2.performance_id = p2.performance_id
        JOIN event e2        ON p2.event_id         = e2.event_id
       WHERE pm2.group_id = NEW.group_id
         AND (pm2.performance_members_id <> OLD.performance_members_id)
         AND YEAR(e2.event_date) IN (v_year-1, v_year-2, v_year-3)
    ) = 3 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A group has already participated for 3 years in a row';
    END IF;
  END IF;
END$$

-- Artist in only one performance at a time
-- BEFORE INSERT
CREATE TRIGGER chk_no_artist_overlap_insert
BEFORE INSERT ON performance_members
FOR EACH ROW
BEGIN
  DECLARE v_start DATETIME;
  DECLARE v_duration TIME;
  DECLARE v_end DATETIME;
  DECLARE v_conflicts INT;


    -- get the start and duration of the performance they're being assigned to
	SELECT p.start_time, p.duration
      INTO v_start, v_duration
      FROM performance p
     WHERE p.performance_id = NEW.performance_id;

    SET v_end = ADDTIME(v_start, v_duration);

    -- count any other performance for the same artist that overlaps in time
    SELECT COUNT(*) 
      INTO v_conflicts
      FROM performance_members pm2
      JOIN performance p2
        ON pm2.performance_id = p2.performance_id
     WHERE pm2.artist_id = NEW.artist_id
       AND pm2.performance_id <> NEW.performance_id
       AND p2.start_time     < v_end
       AND ADDTIME(p2.start_time, p2.duration) > v_start;

    IF v_conflicts > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An artist has two overlapping performances';
    END IF;

END$$


-- BEFORE UPDATE
CREATE TRIGGER chk_no_artist_overlap_update
BEFORE UPDATE ON performance_members
FOR EACH ROW
BEGIN
  DECLARE v_start DATETIME;
  DECLARE v_duration TIME;
  DECLARE v_end DATETIME;
  DECLARE v_conflicts INT;


    -- get the start and duration of the (possibly new) performance
    SELECT p.start_time, p.duration
      INTO v_start, v_duration
      FROM performance p
     WHERE p.performance_id = NEW.performance_id;

    SET v_end = ADDTIME(v_start, v_duration);

    -- count any other performance for this artist that overlaps,
    -- excluding the very row being updated
    SELECT COUNT(*)
      INTO v_conflicts
      FROM performance_members pm2
      JOIN performance p2
        ON pm2.performance_id = p2.performance_id
     WHERE pm2.artist_id = NEW.artist_id
       AND pm2.performance_members_id <> OLD.performance_members_id
       AND p2.start_time     < v_end
       AND ADDTIME(p2.start_time, p2.duration) > v_start;

    IF v_conflicts > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An artist has two overlapping performances';
    END IF;

END$$

-- VIP tickets need to be <= 10% of total capacity for an event
CREATE 
TRIGGER trg_ticket_vip_insert
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
  -- 1) Declare variables
  DECLARE cap        INT DEFAULT 0;
  DECLARE vip_count  INT DEFAULT 0;
  DECLARE max_vip    INT DEFAULT 0;

  -- 2) Only enforce on VIP tickets
  IF NEW.ticket_category = 'VIP' THEN

    -- 2a) Find the stage capacity for this event
    SELECT s.capacity
      INTO cap
    FROM event ev
    JOIN stage s ON ev.stage_id = s.stage_id
    WHERE ev.event_id = NEW.event_id;

    -- 2b) Compute the 10% VIP limit
    SET max_vip = FLOOR(cap * 0.10);

    -- 2c) Count existing VIP tickets
    SELECT COUNT(*)
      INTO vip_count
    FROM ticket t
    WHERE t.event_id        = NEW.event_id
      AND t.ticket_category = 'VIP';

    -- 2d) If issuing this one would exceed the cap, abort
    IF vip_count + 1 > max_vip THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 
          'Cannot issue VIP ticket: would exceed 10% of stage capacity.';
    END IF;

  END IF;
END $$

-- The bellow triggers where meant to tackle the resale queue
-- But we have changed our approach to procedures to solve this problem
/*
CREATE TRIGGER ticket_for_sale
AFTER UPDATE ON ticket
FOR EACH ROW
BEGIN
	IF NEW.visitor_id IS NULL AND OLD.visitor_id IS NOT NULL AND OLD.activated = TRUE THEN
		INSERT INTO resale_queue(ticket_id,event_id,listed_by,ticket_category)
		VALUES(OLD.ticket_id,OLD.event_id,OLD.visitor_id,OLD.ticket_category);
	END IF;
END $$

CREATE TRIGGER match_queue_to_interested
AFTER INSERT ON resale_queue
FOR EACH ROW
BEGIN 
	DECLARE buyer_id INT;
	DECLARE interest_buyer_id INT;
	SELECT interest_id, interested_visitor_id
		INTO interest_buyer_id, buyer_id  
	FROM resale_interest ri
	WHERE ri.event_id = NEW.event_id AND ri.ticket_category=NEW.ticket_category
	ORDER BY expressed_on 
	LIMIT 1;

	IF buyer_id IS NOT NULL THEN
		UPDATE ticket
		SET visitor_id = buyer_id,
		    payment_date = NOW()
		WHERE ticket_id = NEW.ticket_id;
		
		DELETE FROM resale_queue 
		WHERE ticket_id = NEW.ticket_id;
		
		DELETE FROM resale_interest
		WHERE interest_id =interest_buyer_id;
	END IF;
END $$

CREATE TRIGGER match_interest_to_queue
AFTER INSERT ON resale_interest
FOR EACH ROW
BEGIN 
	DECLARE seller_id INT;
	DECLARE resale_seller_id INT;
	DECLARE ticket INT;
	SELECT resale_id, listed_by, ticket_id
		INTO resale_seller_id, seller_id, ticket  
	FROM resale_queue q
	WHERE q.event_id = NEW.event_id AND q.ticket_category=NEW.ticket_category
	ORDER BY listed_on 
	LIMIT 1;

	IF seller_id IS NOT NULL THEN 
		UPDATE ticket
		SET visitor_id = NEW.interested_visitor_id,
		    purchase_date = NOW()
		WHERE ticket_id = ticket;
		
		DELETE FROM resale_queue 
		WHERE resale_id = resale_seller_id;
		
		DELETE FROM resale_interest
		WHERE interest_id =NEW.interest_id;
	END IF;
END $$
*/

-- Checks to make sure that only visitors with activated tickets 
-- can review the corresponding perforomance
CREATE TRIGGER check_ticket_review
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
	DECLARE activated_ BOOLEAN;
	SELECT t.activated INTO activated_
	FROM ticket t
	JOIN performance p ON p.event_id = t.event_id
	WHERE p.performance_id = NEW.performance_id	
	AND t.visitor_id = NEW.visitor_id
	LIMIT 1;

	if activated_ = FALSE THEN 
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Ticket not activated, visitor cannot review';
	END IF;
END$$

-- Enforce both support (2%) and security (5%)
-- BEFORE INSERT
CREATE TRIGGER trg_staff_assignment_before_insert
BEFORE INSERT ON staff_assignment
FOR EACH ROW
BEGIN
  DECLARE total_visitors    INT;
  DECLARE needed            INT;
  DECLARE current_count     INT;

  -- count how many tickets already sold
  SELECT COUNT(*) INTO total_visitors
    FROM ticket
   WHERE event_id = NEW.event_id;

  -- if this is a support hire, check 2%
  IF NEW.staff_role = 'support' THEN
    SET needed = CEIL((total_visitors) * 0.02);

    SELECT COUNT(*) INTO current_count
      FROM staff_assignment
     WHERE event_id   = NEW.event_id
       AND staff_role = 'support';

    -- include this new hire
    SET current_count = current_count + 1;

    IF current_count < needed THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Must have ≥2% support staff';
    END IF;
  END IF;

  -- if this is a security hire, check 5%
  IF NEW.staff_role = 'security' THEN
    SET needed = CEIL((total_visitors) * 0.05);

    SELECT COUNT(*) INTO current_count
      FROM staff_assignment
     WHERE event_id   = NEW.event_id
       AND staff_role = 'security';

    SET current_count = current_count + 1;

    IF current_count < needed THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Must have ≥5% security staff';
    END IF;
  END IF;
END$$


-- BEFORE DELETE
-- Prevent removing support/security if it would drop you below threshold
CREATE TRIGGER trg_staff_assignment_before_delete
BEFORE DELETE ON staff_assignment
FOR EACH ROW
BEGIN
  DECLARE total_visitors    INT;
  DECLARE needed            INT;
  DECLARE remaining_count   INT;

  -- count current tickets
  SELECT COUNT(*) INTO total_visitors
    FROM ticket
   WHERE event_id = OLD.event_id;

  -- support removal
  IF OLD.staff_role = 'support' THEN
    SET needed = CEIL((total_visitors) * 0.02);

    SELECT COUNT(*) INTO remaining_count
      FROM staff_assignment
     WHERE event_id   = OLD.event_id
       AND staff_role = 'support';

    -- subtract the one being removed
    SET remaining_count = remaining_count - 1;

    IF remaining_count < needed THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot unassign support: would drop below 2%';
    END IF;
  END IF;

  -- security removal
  IF OLD.staff_role = 'security' THEN
    SET needed = CEIL((total_visitors) * 0.05);

    SELECT COUNT(*) INTO remaining_count
      FROM staff_assignment
     WHERE event_id   = OLD.event_id
       AND staff_role = 'security';

    SET remaining_count = remaining_count - 1;

    IF remaining_count < needed THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot unassign security: would drop below 5%';
    END IF;
  END IF;
END$$


-- BEFORE UPDATE
-- Prevent demoting support/security if it would violate thresholds
CREATE TRIGGER trg_staff_assignment_before_update
BEFORE UPDATE ON staff_assignment
FOR EACH ROW
BEGIN
  DECLARE total_visitors    INT;
  DECLARE needed            INT;
  DECLARE remaining_count   INT;

  -- only care if you're changing someone *from* support or security
  IF (OLD.staff_role = 'support' AND NEW.staff_role <> 'support')
   OR (OLD.staff_role = 'security' AND NEW.staff_role <> 'security') THEN

    SELECT COUNT(*) INTO total_visitors
      FROM ticket
     WHERE event_id = OLD.event_id;

    IF OLD.staff_role = 'support' THEN
      SET needed = CEIL((total_visitors) * 0.02);
      SELECT COUNT(*) INTO remaining_count
        FROM staff_assignment
       WHERE event_id   = OLD.event_id
         AND staff_role = 'support';
      SET remaining_count = remaining_count - 1;
      IF remaining_count < needed THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Cannot demote support: would drop below 2%';
      END IF;
    END IF;

    IF OLD.staff_role = 'security' THEN
      SET needed = CEIL((total_visitors) * 0.05);
      SELECT COUNT(*) INTO remaining_count
        FROM staff_assignment
       WHERE event_id   = OLD.event_id
         AND staff_role = 'security';
      SET remaining_count = remaining_count - 1;
      IF remaining_count < needed THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Cannot demote security: would drop below 5%';
      END IF;
    END IF;

  END IF;
END$$

-- Checking the breaks for continues performances
-- BEFORE INSERT
CREATE TRIGGER trg_performance_break_insert
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
    DECLARE prev_end DATETIME;
    DECLARE next_start DATETIME;
    DECLARE new_end DATETIME;

    -- Compute new performance end time
    SET new_end = ADDTIME(NEW.start_time, NEW.duration);

    -- Find the immediately preceding performance
    SELECT ADDTIME(start_time, duration)
      INTO prev_end
    FROM performance
    WHERE event_id = NEW.event_id
      AND stage_id = NEW.stage_id
      AND start_time < NEW.start_time
    ORDER BY start_time DESC
    LIMIT 1;

    -- If a preceding performance exists, check the break
    IF prev_end IS NOT NULL THEN
      IF TIMESTAMPDIFF(MINUTE, prev_end, NEW.start_time) < 5
         OR TIMESTAMPDIFF(MINUTE, prev_end, NEW.start_time) > 30 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes';
      END IF;
    END IF;

    -- Find the immediately following performance
    SELECT start_time
      INTO next_start
    FROM performance
    WHERE event_id = NEW.event_id
      AND stage_id = NEW.stage_id
      AND start_time > NEW.start_time
    ORDER BY start_time ASC
    LIMIT 1;

    -- If a following performance exists, check the break
    IF next_start IS NOT NULL THEN
      IF TIMESTAMPDIFF(MINUTE, new_end, next_start) < 5
         OR TIMESTAMPDIFF(MINUTE, new_end, next_start) > 30 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes';
      END IF;
    END IF;
END;
$$

-- BEFORE UPDATE
CREATE TRIGGER trg_performance_break_update
BEFORE UPDATE ON performance
FOR EACH ROW
BEGIN
    DECLARE prev_end DATETIME;
    DECLARE next_start DATETIME;
    DECLARE new_end DATETIME;

    -- Compute updated performance end time
    SET new_end = ADDTIME(NEW.start_time, NEW.duration);

    -- Same logic for preceding row, but exclude the row being updated
    SELECT ADDTIME(start_time, duration)
      INTO prev_end
    FROM performance
    WHERE event_id = NEW.event_id
      AND stage_id = NEW.stage_id
      AND start_time < NEW.start_time
      AND performance_id <> NEW.performance_id
    ORDER BY start_time DESC
    LIMIT 1;

    IF prev_end IS NOT NULL THEN
      IF TIMESTAMPDIFF(MINUTE, prev_end, NEW.start_time) < 5
         OR TIMESTAMPDIFF(MINUTE, prev_end, NEW.start_time) > 30 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes';
      END IF;
    END IF;

    -- Same logic for following row
    SELECT start_time
      INTO next_start
    FROM performance
    WHERE event_id = NEW.event_id
      AND stage_id = NEW.stage_id
      AND start_time > NEW.start_time
      AND performance_id <> NEW.performance_id
    ORDER BY start_time ASC
    LIMIT 1;

    IF next_start IS NOT NULL THEN
      IF TIMESTAMPDIFF(MINUTE, new_end, next_start) < 5
         OR TIMESTAMPDIFF(MINUTE, new_end, next_start) > 30 THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes';
      END IF;
    END IF;
END;
$$

-- Procedures and event to implement the resale queue
CREATE PROCEDURE check_resale_ticket()
BEGIN
	INSERT INTO resale_queue(ticket_id, listed_by, event_id, ticket_category, listed_ON)
	SELECT t.ticket_id, t.visitor_id, t.event_id, t.ticket_category, NOW()
	FROM ticket t
	WHERE t.activated = FALSE AND t.is_resale = TRUE;

	UPDATE ticket
	SET visitor_id = NULL, purchase_date = NULL, is_resale = FALSE 
	WHERE activated = FALSE AND is_resale = TRUE;	
END $$

CREATE PROCEDURE match_all_interested_to_resale_tickets()
BEGIN
    -- Δημιουργία προσωρινού πίνακα για τα matches
    DROP TEMPORARY TABLE IF EXISTS temp_all_matches;
    CREATE TEMPORARY TABLE temp_all_matches (
        ticket_id INT,
        interest_id INT,
        event_id INT,
        PRIMARY KEY (ticket_id, interest_id)
    );

    -- Εισαγωγή ζευγών με βάση event_id και ticket_category και ίδιες "σειρές"
    INSERT INTO temp_all_matches (ticket_id, interest_id, event_id)
    SELECT 
        rq.ticket_id,
        ri.interest_id,
        rq.event_id
    FROM (
        -- Αρίθμηση εισιτηρίων ανά event & κατηγορία με βάση πρόσφατη ημερομηνία ανάρτησης
        SELECT 
            rq.ticket_id, 
            rq.event_id,
            rq.listed_on,
            t.ticket_category,
            ROW_NUMBER() OVER (
                PARTITION BY rq.event_id, t.ticket_category 
                ORDER BY rq.listed_on DESC
            ) AS ticket_rank
        FROM resale_queue rq
        JOIN ticket t ON rq.ticket_id = t.ticket_id
        WHERE t.activated = FALSE -- Δεν έχει ενεργοποιηθεί
    ) rq
    JOIN (
        -- Αρίθμηση ενδιαφερόμενων ανά event & κατηγορία με βάση παλαιότητα
        SELECT 
            ri.interest_id, 
            ri.event_id,
            ri.expressed_on,
            ri.ticket_category,
            ROW_NUMBER() OVER (
                PARTITION BY ri.event_id, ri.ticket_category 
                ORDER BY ri.expressed_on ASC
            ) AS interest_rank
        FROM resale_interest ri
    ) ri ON rq.event_id = ri.event_id 
        AND rq.ticket_category = ri.ticket_category
    WHERE rq.ticket_rank = ri.interest_rank;

    -- Ενημέρωση των matched εισιτηρίων
    UPDATE ticket t
    JOIN temp_all_matches tm ON t.ticket_id = tm.ticket_id
    JOIN resale_interest ri ON tm.interest_id = ri.interest_id
    SET t.visitor_id = ri.interested_visitor_id,
        t.purchase_date = NOW(),
        t.is_resale = FALSE;

    -- Διαγραφή των ταιριασμένων από τις ουρές
    DELETE FROM resale_queue WHERE ticket_id IN (SELECT ticket_id FROM temp_all_matches);
    DELETE FROM resale_interest WHERE interest_id IN (SELECT interest_id FROM temp_all_matches);

    -- Καθαρισμός
    DROP TEMPORARY TABLE IF EXISTS temp_all_matches;
END $$

DELIMITER ;

SET GLOBAL event_scheduler = ON;
CREATE EVENT check_resale_ticket_event
ON SCHEDULE EVERY 30 SECOND
DO
  CALL check_resale_ticket();

CREATE EVENT match_resale_event
ON SCHEDULE EVERY 30 SECOND
DO
  CALL match_all_interested_to_resale_tickets();