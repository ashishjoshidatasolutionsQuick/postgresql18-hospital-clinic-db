-- ============================================================================
-- PROJECT: Hospital and Clinic Management Database (PostgreSQL 18)
-- AUTHOR: Ashish Joshi
-- ============================================================================

-- 1. SCHEMA SETUP
CREATE SCHEMA IF NOT EXISTS staff;
CREATE SCHEMA IF NOT EXISTS clinical;

-- 2. TABLE DEFINITIONS (DDL)
CREATE TABLE staff.doctors (
    doctor_id UUID PRIMARY KEY DEFAULT uuidv7(),
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(80) NOT NULL,
    consultation_fee NUMERIC(10, 2) NOT NULL CHECK (consultation_fee >= 0),
    experience_years INT NOT NULL CHECK (experience_years >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE clinical.patients (
    patient_id UUID PRIMARY KEY DEFAULT uuidv7(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    blood_group VARCHAR(10) NOT NULL CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-')),
    city VARCHAR(100) NOT NULL,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE clinical.appointments (
    appointment_id UUID PRIMARY KEY DEFAULT uuidv7(),
    patient_id UUID NOT NULL REFERENCES clinical.patients(patient_id) ON DELETE RESTRICT,
    doctor_id UUID NOT NULL REFERENCES staff.doctors(doctor_id) ON DELETE RESTRICT,
    appointment_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(40) NOT NULL CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    fee_charged NUMERIC(10, 2) NOT NULL CHECK (fee_charged >= 0)
);

CREATE TABLE clinical.prescriptions (
    prescription_id UUID PRIMARY KEY DEFAULT uuidv7(),
    appointment_id UUID NOT NULL REFERENCES clinical.appointments(appointment_id) ON DELETE RESTRICT,
    diagnosis VARCHAR(100) NOT NULL,
    medication VARCHAR(150) NOT NULL,
    follow_up_days INT CHECK (follow_up_days >= 0)
);

-- 3. OPERATIONAL ANALYTICS AND REPORTING QUERIES

-- Query 1: Active specialists in Cardiology or Neurology with 5-15 years experience
SELECT doctor_id, full_name, specialization, experience_years
FROM staff.doctors
WHERE specialization IN ('Cardiology', 'Neurology')
  AND experience_years BETWEEN 5 AND 15
  AND is_active = TRUE;

-- Query 2: Calculate patient age dynamically for Jaipur and Udaipur
SELECT full_name, city, date_of_birth, AGE(CURRENT_DATE, date_of_birth) AS patient_age
FROM clinical.patients
WHERE city IN ('Jaipur', 'Udaipur');

-- Query 3: Total consultation revenue and completed visits per specialization
SELECT 
    d.specialization,
    COUNT(a.appointment_id) AS completed_visits,
    SUM(a.fee_charged) AS total_revenue
FROM staff.doctors d
INNER JOIN clinical.appointments a ON d.doctor_id = a.doctor_id
WHERE a.status = 'completed'
GROUP BY d.specialization
ORDER BY total_revenue DESC;

-- Query 4: Identify unbooked doctors with zero appointments
SELECT 
    d.doctor_id,
    d.full_name,
    d.specialization
FROM staff.doctors d
LEFT JOIN clinical.appointments a ON d.doctor_id = a.doctor_id
WHERE a.appointment_id IS NULL;

-- Query 5A: Safe UPDATE - 10% fee increase for senior doctors (>15 years experience)
UPDATE staff.doctors
SET consultation_fee=ROUND(consultation_fee+consultation_fee*0.1,2)
WHERE experience_years > 15;

-- Query 5B: Safe DELETE - Remove no_show appointments with no linked prescriptions
DELETE FROM clinical.appointments a
WHERE a.status = 'no_show'
  AND NOT EXISTS (
      SELECT 1 
      FROM clinical.prescriptions p 
      WHERE p.appointment_id = a.appointment_id
  );
