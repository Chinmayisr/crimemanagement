-- ============================================================
--  CRIME MANAGEMENT SYSTEM — MySQL Schema & Seed Data
--  Run this file ONCE before starting the Spring Boot app
-- ============================================================

CREATE DATABASE IF NOT EXISTS crime_management_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE crime_management_db;

-- ─── Drop tables in reverse dependency order ───────────────
DROP TABLE IF EXISTS criminal_case;
DROP TABLE IF EXISTS criminal_crime;
DROP TABLE IF EXISTS crime_victim;
DROP TABLE IF EXISTS evidence;
DROP TABLE IF EXISTS crimes;
DROP TABLE IF EXISTS cases;
DROP TABLE IF EXISTS victims;
DROP TABLE IF EXISTS criminals;
DROP TABLE IF EXISTS police_officers;

-- ─── 1. police_officers ────────────────────────────────────
CREATE TABLE police_officers (
    officer_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    rank            VARCHAR(50),
    badge_number    VARCHAR(50) UNIQUE,
    contact_number  VARCHAR(20)
);

-- ─── 2. criminals ──────────────────────────────────────────
CREATE TABLE criminals (
    criminal_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    age             INT CHECK (age > 0),
    gender          ENUM('Male','Female','Other'),
    address         TEXT,
    crime_history   TEXT
);

-- ─── 3. victims ────────────────────────────────────────────
CREATE TABLE victims (
    victim_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    age             INT CHECK (age > 0),
    gender          ENUM('Male','Female','Other'),
    contact_info    VARCHAR(150)
);

-- ─── 4. cases ──────────────────────────────────────────────
CREATE TABLE cases (
    case_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    case_status     ENUM('OPEN','CLOSED','PENDING','UNDER_INVESTIGATION') DEFAULT 'OPEN',
    filing_date     DATE,
    closing_date    DATE,
    officer_id      BIGINT,
    CONSTRAINT fk_case_officer FOREIGN KEY (officer_id) REFERENCES police_officers(officer_id) ON DELETE SET NULL
);

-- ─── 5. crimes ─────────────────────────────────────────────
CREATE TABLE crimes (
    crime_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    crime_type      VARCHAR(100) NOT NULL,
    date            DATE,
    location        VARCHAR(200),
    description     TEXT,
    case_id         BIGINT,
    CONSTRAINT fk_crime_case FOREIGN KEY (case_id) REFERENCES cases(case_id) ON DELETE SET NULL
);

-- ─── 6. evidence ───────────────────────────────────────────
CREATE TABLE evidence (
    evidence_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    type            VARCHAR(100) NOT NULL,
    description     TEXT,
    collected_date  DATE,
    case_id         BIGINT,
    CONSTRAINT fk_evidence_case FOREIGN KEY (case_id) REFERENCES cases(case_id) ON DELETE CASCADE
);

-- ─── Junction: criminal ↔ crime  (M:N  "commits") ──────────
CREATE TABLE criminal_crime (
    criminal_id     BIGINT NOT NULL,
    crime_id        BIGINT NOT NULL,
    PRIMARY KEY (criminal_id, crime_id),
    CONSTRAINT fk_cc_criminal FOREIGN KEY (criminal_id) REFERENCES criminals(criminal_id) ON DELETE CASCADE,
    CONSTRAINT fk_cc_crime    FOREIGN KEY (crime_id)    REFERENCES crimes(crime_id)    ON DELETE CASCADE
);

-- ─── Junction: crime ↔ victim  (M:N  "involves") ───────────
CREATE TABLE crime_victim (
    crime_id        BIGINT NOT NULL,
    victim_id       BIGINT NOT NULL,
    PRIMARY KEY (crime_id, victim_id),
    CONSTRAINT fk_cv_crime  FOREIGN KEY (crime_id)  REFERENCES crimes(crime_id)  ON DELETE CASCADE,
    CONSTRAINT fk_cv_victim FOREIGN KEY (victim_id) REFERENCES victims(victim_id) ON DELETE CASCADE
);

-- ─── Junction: criminal ↔ case  (M:N  "linked_to") ─────────
CREATE TABLE criminal_case (
    criminal_id     BIGINT NOT NULL,
    case_id         BIGINT NOT NULL,
    PRIMARY KEY (criminal_id, case_id),
    CONSTRAINT fk_ccase_criminal FOREIGN KEY (criminal_id) REFERENCES criminals(criminal_id) ON DELETE CASCADE,
    CONSTRAINT fk_ccase_case     FOREIGN KEY (case_id)     REFERENCES cases(case_id)         ON DELETE CASCADE
);

-- ============================================================
--  SEED DATA
-- ============================================================

-- Police Officers
INSERT INTO police_officers (name, rank, badge_number, contact_number) VALUES
('Rajesh Kumar',    'Inspector',       'HYD-001', '9876543210'),
('Priya Sharma',    'Sub-Inspector',   'HYD-002', '9876543211'),
('Arjun Mehta',     'Deputy SP',       'HYD-003', '9876543212'),
('Sunita Reddy',    'Constable',       'HYD-004', '9876543213'),
('Vikram Singh',    'Inspector',       'HYD-005', '9876543214');

-- Criminals
INSERT INTO criminals (name, age, gender, address, crime_history) VALUES
('Ramesh Goud',     34, 'Male',   'Banjara Hills, Hyderabad', 'Robbery 2019, Assault 2021'),
('Suresh Naidu',    28, 'Male',   'Secunderabad, Hyderabad',  'Fraud 2020'),
('Lakshmi Devi',    45, 'Female', 'LB Nagar, Hyderabad',      'Forgery 2018'),
('Anil Yadav',      31, 'Male',   'Kukatpally, Hyderabad',    'Drug Trafficking 2022'),
('Manoj Tiwari',    39, 'Male',   'Ameerpet, Hyderabad',      'Cybercrime 2021, Fraud 2023');

-- Victims
INSERT INTO victims (name, age, gender, contact_info) VALUES
('Kavitha Rao',     29, 'Female', '9811111111'),
('Ravi Prasad',     42, 'Male',   '9822222222'),
('Ananya Singh',    25, 'Female', '9833333333'),
('Mohan Das',       55, 'Male',   '9844444444'),
('Deepa Nair',      38, 'Female', '9855555555');

-- Cases
INSERT INTO cases (case_status, filing_date, closing_date, officer_id) VALUES
('OPEN',               '2024-01-10', NULL,         1),
('CLOSED',             '2023-06-15', '2023-11-20', 2),
('UNDER_INVESTIGATION','2024-03-05', NULL,         3),
('PENDING',            '2024-02-20', NULL,         1),
('OPEN',               '2024-04-01', NULL,         5);

-- Crimes
INSERT INTO crimes (crime_type, date, location, description, case_id) VALUES
('Robbery',       '2024-01-08', 'Banjara Hills',    'Armed robbery at jewellery store',         1),
('Cybercrime',    '2024-03-01', 'Ameerpet',         'Online banking fraud targeting businesses', 3),
('Drug Trafficking','2024-02-18','Kukatpally',      'Narcotics seized near Kukatpally X-roads',  4),
('Assault',       '2023-06-10', 'Secunderabad',     'Physical assault outside restaurant',       2),
('Fraud',         '2024-03-28', 'Madhapur',         'Investment fraud worth ₹50 lakhs',          5);

-- Evidence
INSERT INTO evidence (type, description, collected_date, case_id) VALUES
('Physical',  'Stolen jewellery recovered from accused residence',  '2024-01-12', 1),
('Digital',   'CCTV footage from crime scene and nearby ATM',       '2024-01-09', 1),
('Digital',   'Server logs and transaction records',                '2024-03-03', 3),
('Physical',  '2 kg narcotics in sealed packets',                   '2024-02-19', 4),
('Forensic',  'Fingerprints lifted from getaway vehicle',           '2024-01-11', 1),
('Document',  'Forged cheques and investment brochures',            '2024-03-30', 5);

-- Criminal ↔ Crime (commits)
INSERT INTO criminal_crime VALUES
(1, 1), -- Ramesh committed Robbery
(5, 2), -- Manoj committed Cybercrime
(4, 3), -- Anil committed Drug Trafficking
(2, 4), -- Suresh committed Assault
(5, 5), -- Manoj committed Fraud
(3, 5); -- Lakshmi also in Fraud

-- Crime ↔ Victim (involves)
INSERT INTO crime_victim VALUES
(1, 1), -- Robbery  → Kavitha
(2, 3), -- Cybercrime → Ananya
(3, 4), -- Drugs → Mohan
(4, 2), -- Assault → Ravi
(5, 3), -- Fraud → Ananya
(5, 5); -- Fraud → Deepa

-- Criminal ↔ Case (linked_to)
INSERT INTO criminal_case VALUES
(1, 1), -- Ramesh linked to Case 1
(5, 3), -- Manoj linked to Case 3
(4, 4), -- Anil linked to Case 4
(2, 2), -- Suresh linked to Case 2
(5, 5), -- Manoj linked to Case 5
(3, 5); -- Lakshmi linked to Case 5

-- ─── Verify ────────────────────────────────────────────────
SELECT 'police_officers' AS tbl, COUNT(*) AS rows FROM police_officers
UNION ALL SELECT 'criminals', COUNT(*) FROM criminals
UNION ALL SELECT 'victims',   COUNT(*) FROM victims
UNION ALL SELECT 'cases',     COUNT(*) FROM cases
UNION ALL SELECT 'crimes',    COUNT(*) FROM crimes
UNION ALL SELECT 'evidence',  COUNT(*) FROM evidence
UNION ALL SELECT 'criminal_crime', COUNT(*) FROM criminal_crime
UNION ALL SELECT 'crime_victim',   COUNT(*) FROM crime_victim
UNION ALL SELECT 'criminal_case',  COUNT(*) FROM criminal_case;