
-- ============================================================
-- TP2 : Système de Gestion Hospitalière
-- Auteur : [Etudiante : BELOUAHAR Sofia]
-- Description :
-- Ce projet consiste à concevoir et implémenter une base de données
-- complète pour la gestion d’un hôpital.
-- Le système permet de gérer :
--   • Les spécialités médicales
--   • Les médecins
--   • Les patients
--   • Les consultations
--   • Les prescriptions
--   • Les médicaments
-- Il inclut également des requêtes SQL d’analyse et de reporting.
-- ============================================================


-- ============================================
-- PARTIE 0: Création de la base de données hospital_db
-- ============================================

CREATE DATABASE IF NOT EXISTS hospital_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hospital_db;



-- ============================================
-- PARTIE 1: CREATION DES TABLES
-- ============================================



-- 1. Table: specialties
-- Stocke les différentes spécialités médicales disponibles

CREATE TABLE specialties (
    specialty_id       INT            NOT NULL AUTO_INCREMENT,
    specialty_name     VARCHAR(100)   NOT NULL,
    description        TEXT,
    consultation_fee   DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (specialty_id),
    UNIQUE KEY uq_specialty_name (specialty_name)
);

-- 2. Table: doctors
-- Contient les informations des médecins de l’hôpital

CREATE TABLE doctors (
    doctor_id      INT            NOT NULL AUTO_INCREMENT,
    last_name      VARCHAR(50)    NOT NULL,
    first_name     VARCHAR(50)    NOT NULL,
    email          VARCHAR(100)   NOT NULL,
    phone          VARCHAR(20),
    specialty_id   INT            NOT NULL,
    license_number VARCHAR(20)    NOT NULL,
    hire_date      DATE,
    office         VARCHAR(100),
    active         BOOLEAN        DEFAULT TRUE,
    PRIMARY KEY (doctor_id),
    UNIQUE KEY uq_doctor_email   (email),
    UNIQUE KEY uq_license_number (license_number),
    CONSTRAINT fk_doctor_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES specialties (specialty_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 3. Table: patients
-- Stocke les informations administratives et médicales des patients

CREATE TABLE patients (
    patient_id        INT          NOT NULL AUTO_INCREMENT,
    file_number       VARCHAR(20)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    first_name        VARCHAR(50)  NOT NULL,
    date_of_birth     DATE         NOT NULL,
    gender            ENUM('M','F') NOT NULL,
    blood_type        VARCHAR(5),
    email             VARCHAR(100),
    phone             VARCHAR(20)  NOT NULL,
    address           TEXT,
    city              VARCHAR(50),
    province          VARCHAR(50),
    registration_date DATE         DEFAULT (CURRENT_DATE),
    insurance         VARCHAR(100),
    insurance_number  VARCHAR(50),
    allergies         TEXT,
    medical_history   TEXT,
    PRIMARY KEY (patient_id),
    UNIQUE KEY uq_file_number (file_number)
);

-- 4. Table: consultations
-- Représente les rendez-vous médicaux entre un patient et un médecin

CREATE TABLE consultations (
    consultation_id   INT             NOT NULL AUTO_INCREMENT,
    patient_id        INT             NOT NULL,
    doctor_id         INT             NOT NULL,
    consultation_date DATETIME        NOT NULL,
    reason            TEXT            NOT NULL,
    diagnosis         TEXT,
    observations      TEXT,
    blood_pressure    VARCHAR(20),
    temperature       DECIMAL(4, 2),
    weight            DECIMAL(5, 2),
    height            DECIMAL(5, 2),
    status            ENUM('Scheduled','In Progress','Completed','Cancelled')
                      DEFAULT 'Scheduled',
    amount            DECIMAL(10, 2),
    paid              BOOLEAN         DEFAULT FALSE,
    PRIMARY KEY (consultation_id),
    CONSTRAINT fk_consult_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_consult_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors (doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 5. Table: medications
-- Gère les médicaments disponibles en pharmacie

CREATE TABLE medications (
    medication_id          INT            NOT NULL AUTO_INCREMENT,
    medication_code        VARCHAR(20)    NOT NULL,
    commercial_name        VARCHAR(150)   NOT NULL,
    generic_name           VARCHAR(150),
    form                   VARCHAR(50),
    dosage                 VARCHAR(50),
    manufacturer           VARCHAR(100),
    unit_price             DECIMAL(10, 2) NOT NULL,
    available_stock        INT            DEFAULT 0,
    minimum_stock          INT            DEFAULT 10,
    expiration_date        DATE,
    prescription_required  BOOLEAN        DEFAULT TRUE,
    reimbursable           BOOLEAN        DEFAULT FALSE,
    PRIMARY KEY (medication_id),
    UNIQUE KEY uq_medication_code (medication_code)
);

-- 6. Table: prescriptions
-- Représente une ordonnance liée à une consultation

CREATE TABLE prescriptions (
    prescription_id       INT       NOT NULL AUTO_INCREMENT,
    consultation_id       INT       NOT NULL,
    prescription_date     DATETIME  DEFAULT CURRENT_TIMESTAMP,
    treatment_duration    INT,
    general_instructions  TEXT,
    PRIMARY KEY (prescription_id),
    CONSTRAINT fk_prescription_consult
        FOREIGN KEY (consultation_id)
        REFERENCES consultations (consultation_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 7. Table: prescription_details
-- Détaille les médicaments prescrits dans une ordonnance

CREATE TABLE prescription_details (
    detail_id             INT            NOT NULL AUTO_INCREMENT,
    prescription_id       INT            NOT NULL,
    medication_id         INT            NOT NULL,
    quantity              INT            NOT NULL,
    dosage_instructions   VARCHAR(200)   NOT NULL,
    duration              INT            NOT NULL,
    total_price           DECIMAL(10, 2),
    PRIMARY KEY (detail_id),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT fk_detail_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions (prescription_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detail_medication
        FOREIGN KEY (medication_id)
        REFERENCES medications (medication_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ============================================
-- PARTIE 2: Index pour optimiser les performances des recherches :
-- ============================================

CREATE INDEX idx_patient_name          ON patients       (last_name, first_name);
CREATE INDEX idx_consult_date          ON consultations  (consultation_date);
CREATE INDEX idx_consult_patient       ON consultations  (patient_id);
CREATE INDEX idx_consult_doctor        ON consultations  (doctor_id);
CREATE INDEX idx_medication_name       ON medications    (commercial_name);
CREATE INDEX idx_prescription_consult  ON prescriptions  (consultation_id);

-- ============================================
-- PARTIE 3: Insertion de données de test
-- ============================================

-- Specialties (6)
INSERT INTO specialties (specialty_name, description, consultation_fee) VALUES
('General Medicine',  'Primary care and common illness management.',              2000.00),
('Cardiology',        'Heart and cardiovascular system diseases.',                5000.00),
('Pediatrics',        'Medical care for infants, children and adolescents.',      3000.00),
('Dermatology',       'Skin, hair and nail conditions.',                          3500.00),
('Orthopedics',       'Musculoskeletal system disorders and injuries.',           4000.00),
('Gynecology',        'Female reproductive health and prenatal care.',            4500.00);

-- Doctors (6)
INSERT INTO doctors (last_name, first_name, email, phone, specialty_id, license_number, hire_date, office, active) VALUES
('Boudiaf',   'Salim',    'salim.boudiaf@hopital.dz',   '0550101001', 1, 'MED-ALG-0011', '2010-03-01', 'Room 101', TRUE),
('Kaci',      'Leila',    'leila.kaci@hopital.dz',      '0550101002', 2, 'MED-ALG-0022', '2008-06-15', 'Room 202', TRUE),
('Remili',    'Youcef',   'youcef.remili@hopital.dz',   '0550101003', 3, 'MED-ALG-0033', '2015-09-01', 'Room 310', TRUE),
('Amara',     'Samira',   'samira.amara@hopital.dz',    '0550101004', 4, 'MED-ALG-0044', '2012-01-20', 'Room 415', TRUE),
('Ouali',     'Karim',    'karim.ouali@hopital.dz',     '0550101005', 5, 'MED-ALG-0055', '2009-11-05', 'Room 520', TRUE),
('Belhadj',   'Nora',     'nora.belhadj@hopital.dz',    '0550101006', 6, 'MED-ALG-0066', '2011-04-10', 'Room 618', TRUE);

-- Patients (8)
INSERT INTO patients (file_number, last_name, first_name, date_of_birth, gender, blood_type,
    email, phone, address, city, province, registration_date,
    insurance, insurance_number, allergies, medical_history) VALUES
('PAT-001', 'Meziani',   'Riad',      '1985-07-14', 'M', 'A+',
    'riad.meziani@gmail.com',   '0660201001', '12 Rue Ben Boulaid',    'Alger',     'Alger',
    '2023-01-10', 'CNAS',    'CNAS-001122', NULL,
    'Hypertension diagnosed 2020'),
('PAT-002', 'Taleb',     'Nadia',     '1992-03-28', 'F', 'O+',
    'nadia.taleb@gmail.com',    '0660201002', '5 Avenue de l''ALN',    'Oran',      'Oran',
    '2023-03-15', 'CASNOS', 'CAS-334455', 'Penicillin',
    'Asthma since childhood'),
('PAT-003', 'Cherif',    'Kamel',     '1975-11-02', 'M', 'B+',
    'kamel.cherif@gmail.com',   '0660201003', '34 Bd Zighout Youcef',  'Constantine','Constantine',
    '2023-05-20', 'CNAS',    'CNAS-556677', 'Aspirin',
    'Diabetes type 2 since 2018'),
('PAT-004', 'Hadj',      'Meriem',    '2010-08-19', 'F', 'AB+',
    'm.hadj@gmail.com',         '0660201004', '9 Rue Larbi Ben Mhidi', 'Alger',     'Alger',
    '2023-06-01', 'CNAS',    'CNAS-778899', NULL,
    'Mild anemia'),
('PAT-005', 'Ghouali',   'Khalil',    '1998-01-30', 'M', 'O-',
    'khalil.ghouali@gmail.com', '0660201005', '22 Cité des Orangers',  'Blida',     'Blida',
    '2024-01-08', 'CASNOS', 'CAS-990011', 'Sulfonamides',
    'Sports injury knee 2022'),
('PAT-006', 'Ferhat',    'Sonia',     '1965-04-05', 'F', 'A-',
    'sonia.ferhat@gmail.com',   '0660201006', '7 Rue Hassiba Ben Bouali','Alger',   'Alger',
    '2024-02-14', NULL,       NULL,          NULL,
    'Osteoporosis diagnosed 2019'),
('PAT-007', 'Boudjelal', 'Ismail',    '1950-12-25', 'M', 'B-',
    NULL,                       '0660201007', '3 Allée des Roses',     'Sétif',     'Sétif',
    '2024-03-05', 'CNAS',    'CNAS-112233', 'Iodine, Latex',
    'Coronary artery disease, pacemaker implanted 2015'),
('PAT-008', 'Aissaoui',  'Fatiha',    '2018-06-10', 'F', 'A+',
    NULL,                       '0660201008', '18 Cité Universitaire', 'Alger',     'Alger',
    '2025-01-20', 'CNAS',    'CNAS-445566', NULL,
    'Premature birth history');

-- Consultations (8)
INSERT INTO consultations (patient_id, doctor_id, consultation_date, reason, diagnosis,
    observations, blood_pressure, temperature, weight, height, status, amount, paid) VALUES
(1, 1, '2025-01-05 09:00:00', 'Headache and fatigue',
    'Hypertension episode', 'Patient reports dizziness for 3 days',
    '150/95', 37.20, 82.00, 175.00, 'Completed', 2000.00, TRUE),
(2, 2, '2025-01-12 10:30:00', 'Chest pain and shortness of breath',
    'Mild cardiac arrhythmia', 'ECG shows irregular rhythm',
    '130/85', 37.00, 65.00, 163.00, 'Completed', 5000.00, TRUE),
(3, 1, '2025-01-20 11:00:00', 'Routine check-up for diabetes',
    'Controlled type 2 diabetes', 'Blood sugar levels acceptable',
    '125/80', 36.80, 90.00, 178.00, 'Completed', 2000.00, FALSE),
(4, 3, '2025-02-03 08:30:00', 'Recurrent ear infections',
    'Otitis media', 'Mild fever and ear pain reported by parents',
    '100/65', 38.10, 32.00, 140.00, 'Completed', 3000.00, TRUE),
(5, 5, '2025-02-10 14:00:00', 'Knee pain after sports',
    'Grade II ligament sprain', 'Swelling on the right knee',
    '120/78', 36.60, 75.00, 180.00, 'Completed', 4000.00, FALSE),
(6, 5, '2025-02-18 09:30:00', 'Back pain and joint stiffness',
    'Lumbar osteoarthritis', 'Reduced mobility in lumbar region',
    '135/88', 36.90, 68.00, 162.00, 'Completed', 4000.00, TRUE),
(7, 2, '2025-02-25 11:00:00', 'Palpitations and dizziness',
    'Pacemaker check — functioning normally', 'Pacemaker device checked',
    '128/82', 36.70, 73.00, 170.00, 'Completed', 5000.00, TRUE),
(1, 4, '2025-03-10 10:00:00', 'Skin rash on arms',
    'Contact dermatitis', 'Allergic reaction to detergent',
    '145/92', 37.10, 82.00, 175.00, 'Scheduled', 3500.00, FALSE);

-- Medications (10)
INSERT INTO medications (medication_code, commercial_name, generic_name, form, dosage,
    manufacturer, unit_price, available_stock, minimum_stock,
    expiration_date, prescription_required, reimbursable) VALUES
('MED-001', 'Amlor 5mg',         'Amlodipine',          'Tablet',    '5mg',
    'Pfizer Algeria',     350.00,  80,  20, '2026-06-30', TRUE,  TRUE),
('MED-002', 'Aspégic 500',       'Aspirin',              'Sachet',    '500mg',
    'Sanofi Algeria',     120.00, 200,  30, '2026-12-31', FALSE, FALSE),
('MED-003', 'Augmentin 1g',      'Amoxicillin/Clavulanate','Tablet', '1g',
    'GSK Algeria',        480.00,  45,  20, '2025-09-30', TRUE,  TRUE),
('MED-004', 'Voltaren 50mg',     'Diclofenac',           'Tablet',    '50mg',
    'Novartis Algeria',   280.00,  60,  15, '2026-03-31', FALSE, FALSE),
('MED-005', 'Metformine 850',    'Metformin',            'Tablet',    '850mg',
    'Biopharm',           95.00,  150,  25, '2027-01-31', TRUE,  TRUE),
('MED-006', 'Cortancyl 20mg',    'Prednisone',           'Tablet',    '20mg',
    'Sanofi Algeria',    310.00,   30,  15, '2025-07-31', TRUE,  FALSE),
('MED-007', 'Ventoline',         'Salbutamol',           'Inhaler',   '100mcg/dose',
    'GSK Algeria',       650.00,   25,  10, '2025-10-31', TRUE,  TRUE),
('MED-008', 'Bisoprolol 5mg',    'Bisoprolol',           'Tablet',    '5mg',
    'Servier Algeria',   290.00,   70,  20, '2026-08-31', TRUE,  TRUE),
('MED-009', 'Caladryl Lotion',   'Calamine/Diphenhydramine','Lotion', '1%/1%',
    'Johnson Algeria',   420.00,    8,  10, '2025-11-30', FALSE, FALSE),
('MED-010', 'Calcium D3 Sandoz', 'Calcium/Vitamin D3',  'Sachet',    '1000mg/880IU',
    'Sandoz Algeria',    380.00,   12,  15, '2026-05-31', FALSE, TRUE);

-- Prescriptions (7) — linked to completed consultations 1-7
INSERT INTO prescriptions (consultation_id, prescription_date, treatment_duration, general_instructions) VALUES
(1, '2025-01-05 09:30:00',  30,  'Take medication with water. Avoid salty food. Monitor blood pressure daily.'),
(2, '2025-01-12 11:00:00',  60,  'Rest required. Avoid caffeine and alcohol. Return if palpitations worsen.'),
(3, '2025-01-20 11:45:00',  90,  'Continue diabetic diet. Exercise 30 minutes daily. Blood test in 3 months.'),
(4, '2025-02-03 09:00:00',  10,  'Complete the full antibiotic course. Keep ear dry.'),
(5, '2025-02-10 14:45:00',  21,  'RICE method: Rest, Ice, Compression, Elevation. No sports for 3 weeks.'),
(6, '2025-02-18 10:00:00',  30,  'Physical therapy twice a week. Avoid heavy lifting.'),
(7, '2025-02-25 11:30:00',  90,  'Continue all cardiac medications. Monthly ECG monitoring required.');

-- Prescription Details (12+)
INSERT INTO prescription_details (prescription_id, medication_id, quantity, dosage_instructions, duration, total_price) VALUES
-- Rx 1: Hypertension (Amlor + Aspégic)
(1, 1, 1, '1 tablet each morning with water',                   30, 350.00),
(1, 2, 1, '1 sachet per day dissolved in water — low dose',     30, 120.00),
-- Rx 2: Arrhythmia (Bisoprolol + Aspégic)
(2, 8, 2, '1 tablet morning and evening',                       60, 580.00),
(2, 2, 2, '1 sachet per day for antiplatelet effect',           60, 240.00),
-- Rx 3: Diabetes (Metformine)
(3, 5, 3, '1 tablet morning, noon and evening with meals',      90, 285.00),
-- Rx 4: Otitis (Augmentin)
(4, 3, 1, '1 tablet every 8 hours — take with food',            10, 480.00),
-- Rx 5: Knee sprain (Voltaren + Aspégic)
(5, 4, 2, '1 tablet twice daily after meals — max 7 days',      14, 560.00),
(5, 2, 1, '1 sachet per day for inflammation control',          14, 120.00),
-- Rx 6: Osteoarthritis (Voltaren + Calcium D3 + Cortancyl)
(6, 4, 1, '1 tablet twice daily after meals',                   30, 280.00),
(6, 10, 1, '1 sachet per day dissolved in water',               30, 380.00),
(6, 6, 1, '1 tablet each morning — do not stop abruptly',       15, 310.00),
-- Rx 7: Cardiac follow-up (Bisoprolol + Amlor + Aspégic)
(7, 8, 3, '1 tablet morning and evening',                       90, 870.00),
(7, 1, 3, '1 tablet each morning',                              90, 1050.00),
(7, 2, 3, '1 sachet per day',                                   90, 360.00);

-- ============================================
-- PARTIE 4: 30 REQUÊTES SQL
-- ============================================

-- ========== PARTIE 1: REQUÊTES SIMPLES (Q1-Q5) ==========

-- Q1. List all patients with their main information
SELECT
    file_number,
    CONCAT(last_name, ' ', first_name) AS full_name,
    date_of_birth,
    phone,
    city
FROM patients
ORDER BY last_name, first_name;

-- Q2. Display all doctors with their specialty
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    s.specialty_name,
    d.office,
    d.active
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id
ORDER BY s.specialty_name, d.last_name;

-- Q3. Find all medications with price less than 500 DA
SELECT
    medication_code,
    commercial_name,
    unit_price,
    available_stock
FROM medications
WHERE unit_price < 500.00
ORDER BY unit_price;

-- Q4. List consultations from January 2025
SELECT
    c.consultation_date,
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    c.status
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors  d ON c.doctor_id  = d.doctor_id
WHERE YEAR(c.consultation_date)  = 2025
  AND MONTH(c.consultation_date) = 1
ORDER BY c.consultation_date;

-- Q5. Display medications where stock is below minimum stock
SELECT
    commercial_name,
    available_stock,
    minimum_stock,
    (available_stock - minimum_stock) AS difference
FROM medications
WHERE available_stock < minimum_stock
ORDER BY difference;

-- ========== PARTIE 2: REQUÊTES AVEC JOINTURES (Q6-Q10) ==========

-- Q6. Display all consultations with patient and doctor names
SELECT
    c.consultation_date,
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    c.diagnosis,
    c.amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors  d ON c.doctor_id  = d.doctor_id
ORDER BY c.consultation_date DESC;

-- Q7. List all prescriptions with medication details
SELECT
    pr.prescription_date,
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    m.commercial_name                       AS medication_name,
    pd.quantity,
    pd.dosage_instructions
FROM prescription_details pd
JOIN prescriptions  pr ON pd.prescription_id  = pr.prescription_id
JOIN consultations  c  ON pr.consultation_id  = c.consultation_id
JOIN patients       p  ON c.patient_id        = p.patient_id
JOIN medications    m  ON pd.medication_id    = m.medication_id
ORDER BY pr.prescription_date, p.last_name;

-- Q8. Display patients with their last consultation date
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    MAX(c.consultation_date)               AS last_consultation_date,
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name
FROM patients       p
JOIN consultations  c ON p.patient_id  = c.patient_id
JOIN doctors        d ON c.doctor_id   = d.doctor_id
WHERE c.consultation_date = (
    SELECT MAX(c2.consultation_date)
    FROM consultations c2
    WHERE c2.patient_id = p.patient_id
)
GROUP BY p.patient_id, p.last_name, p.first_name, d.last_name, d.first_name
ORDER BY last_consultation_date DESC;

-- Q9. List doctors and the number of consultations performed
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    COUNT(c.consultation_id)               AS consultation_count
FROM doctors       d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name
ORDER BY consultation_count DESC;

-- Q10. Display revenue by medical specialty
SELECT
    s.specialty_name,
    COALESCE(SUM(c.amount), 0)    AS total_revenue,
    COUNT(c.consultation_id)       AS consultation_count
FROM specialties  s
LEFT JOIN doctors d ON s.specialty_id = d.specialty_id
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id, s.specialty_name
ORDER BY total_revenue DESC;

-- ========== PARTIE 3: FONCTIONS D’AGRÉGATION (Q11-Q15) ==========

-- Q11. Calculate total prescription amount per patient
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    ROUND(SUM(pd.total_price), 2)          AS total_prescription_cost
FROM patients          p
JOIN consultations     c  ON p.patient_id        = c.patient_id
JOIN prescriptions     pr ON c.consultation_id   = pr.consultation_id
JOIN prescription_details pd ON pr.prescription_id = pd.prescription_id
GROUP BY p.patient_id, p.last_name, p.first_name
ORDER BY total_prescription_cost DESC;

-- Q12. Count the number of consultations per doctor
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    COUNT(c.consultation_id)               AS consultation_count
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name
ORDER BY consultation_count DESC;

-- Q13. Calculate total stock value of pharmacy
SELECT
    COUNT(*)                                       AS total_medications,
    ROUND(SUM(unit_price * available_stock), 2)   AS total_stock_value
FROM medications;

-- Q14. Find average consultation price per specialty
SELECT
    s.specialty_name,
    ROUND(AVG(c.amount), 2) AS average_price
FROM specialties   s
JOIN doctors        d ON s.specialty_id = d.specialty_id
JOIN consultations  c ON d.doctor_id    = c.doctor_id
GROUP BY s.specialty_id, s.specialty_name
ORDER BY average_price DESC;

-- Q15. Count number of patients by blood type
SELECT
    blood_type,
    COUNT(*) AS patient_count
FROM patients
WHERE blood_type IS NOT NULL
GROUP BY blood_type
ORDER BY patient_count DESC;

-- ========== PARTIE 4: REQUÊTES AVANCÉES (Q16-Q20) ==========

-- Q16. Find the top 5 most prescribed medications
SELECT
    m.commercial_name              AS medication_name,
    COUNT(pd.detail_id)            AS times_prescribed,
    SUM(pd.quantity)               AS total_quantity
FROM medications         m
JOIN prescription_details pd ON m.medication_id = pd.medication_id
GROUP BY m.medication_id, m.commercial_name
ORDER BY times_prescribed DESC, total_quantity DESC
LIMIT 5;

-- Q17. List patients who have never had a consultation
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    p.registration_date
FROM patients p
LEFT JOIN consultations c ON p.patient_id = c.patient_id
WHERE c.consultation_id IS NULL
ORDER BY p.last_name;

-- Q18. Display doctors who performed more than 2 consultations
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    s.specialty_name                        AS specialty,
    COUNT(c.consultation_id)                AS consultation_count
FROM doctors       d
JOIN specialties   s ON d.specialty_id = s.specialty_id
JOIN consultations c ON d.doctor_id    = c.doctor_id
GROUP BY d.doctor_id, d.last_name, d.first_name, s.specialty_name
HAVING COUNT(c.consultation_id) > 2
ORDER BY consultation_count DESC;

-- Q19. Find unpaid consultations with total amount
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    c.consultation_date,
    c.amount,
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors  d ON c.doctor_id  = d.doctor_id
WHERE c.paid = FALSE
ORDER BY c.consultation_date;

-- Q20. List medications expiring in less than 6 months from today
SELECT
    commercial_name                                       AS medication_name,
    expiration_date,
    DATEDIFF(expiration_date, CURRENT_DATE)              AS days_until_expiration
FROM medications
WHERE expiration_date IS NOT NULL
  AND expiration_date > CURRENT_DATE
  AND expiration_date <= DATE_ADD(CURRENT_DATE, INTERVAL 6 MONTH)
ORDER BY expiration_date;

-- ========== PARTIE 5: SOUS-REQUÊTES (Q21-Q25) ==========

-- Q21. Find patients who consulted more than the average number of consultations
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    COUNT(c.consultation_id)               AS consultation_count,
    ROUND((SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM consultations GROUP BY patient_id
    ) AS sub), 2)                          AS average_count
FROM patients      p
JOIN consultations c ON p.patient_id = c.patient_id
GROUP BY p.patient_id, p.last_name, p.first_name
HAVING COUNT(c.consultation_id) > (
    SELECT AVG(cnt)
    FROM (SELECT COUNT(*) AS cnt FROM consultations GROUP BY patient_id) AS sub
)
ORDER BY consultation_count DESC;

-- Q22. List medications more expensive than the average price
SELECT
    commercial_name                         AS medication_name,
    unit_price,
    ROUND((SELECT AVG(unit_price) FROM medications), 2) AS average_price
FROM medications
WHERE unit_price > (SELECT AVG(unit_price) FROM medications)
ORDER BY unit_price DESC;

-- Q23. Display doctors from the most requested specialty
-- (specialty with the highest number of consultations)
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    s.specialty_name,
    (SELECT COUNT(*) FROM consultations c2
     JOIN doctors d2 ON c2.doctor_id = d2.doctor_id
     WHERE d2.specialty_id = s.specialty_id)  AS specialty_consultation_count
FROM doctors     d
JOIN specialties s ON d.specialty_id = s.specialty_id
WHERE s.specialty_id = (
    SELECT d3.specialty_id
    FROM consultations c3
    JOIN doctors d3 ON c3.doctor_id = d3.doctor_id
    GROUP BY d3.specialty_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
ORDER BY d.last_name;

-- Q24. Find consultations with amount higher than the average
SELECT
    c.consultation_date,
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    c.amount,
    ROUND((SELECT AVG(amount) FROM consultations), 2) AS average_amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
WHERE c.amount > (SELECT AVG(amount) FROM consultations)
ORDER BY c.amount DESC;

-- Q25. List allergic patients who received at least one prescription
SELECT
    CONCAT(p.last_name, ' ', p.first_name) AS patient_name,
    p.allergies,
    COUNT(DISTINCT pr.prescription_id)     AS prescription_count
FROM patients      p
JOIN consultations c  ON p.patient_id      = c.patient_id
JOIN prescriptions pr ON c.consultation_id = pr.consultation_id
WHERE p.allergies IS NOT NULL
GROUP BY p.patient_id, p.last_name, p.first_name, p.allergies
ORDER BY prescription_count DESC;

-- ========== PART 6: BUSINESS ANALYSIS (Q26-Q30) ==========

-- Q26. Calculate total revenue per doctor (paid consultations only)
SELECT
    CONCAT(d.last_name, ' ', d.first_name) AS doctor_name,
    COUNT(c.consultation_id)               AS total_consultations,
    ROUND(SUM(c.amount), 2)                AS total_revenue
FROM doctors       d
JOIN consultations c ON d.doctor_id = c.doctor_id
WHERE c.paid = TRUE
GROUP BY d.doctor_id, d.last_name, d.first_name
ORDER BY total_revenue DESC;

-- Q27. Display top 3 most profitable specialties
SELECT
    RANK() OVER (ORDER BY SUM(c.amount) DESC) AS `rank`,
    s.specialty_name,
    ROUND(SUM(c.amount), 2)                   AS total_revenue
FROM specialties   s
JOIN doctors        d ON s.specialty_id = d.specialty_id
JOIN consultations  c ON d.doctor_id    = c.doctor_id
GROUP BY s.specialty_id, s.specialty_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Q28. List medications to restock (stock < minimum)
SELECT
    commercial_name                          AS medication_name,
    available_stock                          AS current_stock,
    minimum_stock,
    (minimum_stock - available_stock)        AS quantity_needed
FROM medications
WHERE available_stock < minimum_stock
ORDER BY quantity_needed DESC;

-- Q29. Calculate average number of medications per prescription
SELECT
    ROUND(AVG(meds_per_rx), 2) AS average_medications_per_prescription
FROM (
    SELECT prescription_id, COUNT(*) AS meds_per_rx
    FROM prescription_details
    GROUP BY prescription_id
) AS sub;

-- Q30. Generate patient demographics report by age group (0-18, 19-40, 41-60, 60+)
SELECT
    age_group,
    COUNT(*)                                              AS patient_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)   AS percentage
FROM (
    SELECT
        CASE
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 0  AND 18 THEN '0-18'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 19 AND 40 THEN '19-40'
            WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 41 AND 60 THEN '41-60'
            ELSE '60+'
        END AS age_group
    FROM patients
) AS age_data
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN '0-18'  THEN 1
        WHEN '19-40' THEN 2
        WHEN '41-60' THEN 3
        ELSE 4
    END;

