# postgresql18-hospital-clinic-db
Relational Hospital and Clinic Management Database built in PostgreSQL 18 with UUIDv7, multi-schema architecture, and operational SQL analytics.

## 📌 Project Overview
A multi-schema relational database designed from scratch in **PostgreSQL 18** and managed via **pgAdmin 4**. This project simulates real-world hospital operations, enforcing strict referential integrity while answering key clinical and financial business questions.

## 🗄️ Architecture & Schema Design
The database (`clinic_db`) is organized into two logical schemas:
* **`staff` schema:** Stores practitioner profiles and fee structures (`doctors`).
* **`clinical` schema:** Manages patient records, scheduling, and medical documentation (`patients`, `appointments`, `prescriptions`).

### Key Technical Features
* **Modern Primary Keys:** Implemented PostgreSQL 18's native `uuidv7()` function for time-ordered, index-friendly unique identifiers.
* **Data Integrity & Constraints:** Applied `FOREIGN KEY` constraints (`ON DELETE RESTRICT`), `UNIQUE` email rules, and strict `CHECK` constraints validating blood groups, appointment statuses, and non-negative fees.
* **Time-Zone Awareness:** Utilized `TIMESTAMPTZ` for accurate scheduling timestamps.

## 📊 Operational SQL Queries Covered
All DDL and analytical queries are available in [`clinic_database_project.sql`](clinic_database_project.sql):
1. **Specialist Filtering:** Queried active Cardiology and Neurology specialists by experience range using `IN` and `BETWEEN`.
2. **Dynamic Age Calculation:** Computed exact patient ages across cities using PostgreSQL's `AGE()` function.
3. **Revenue Analytics:** Aggregated consultation revenue and completed visit counts by medical specialization using `INNER JOIN` and `GROUP BY`.
4. **Resource Utilization:** Identified unbooked doctors with zero appointments using `LEFT JOIN` and `IS NULL` filtering.
5. **Safe Data Mutations:** Applied conditional `UPDATE` fee adjustments for senior specialists and executed safe `DELETE` operations on `no_show` appointments using `NOT EXISTS` to protect linked prescriptions.

## 🛠️ Tech Stack
* **Database:** PostgreSQL 18
* **Administration Tool:** pgAdmin 4

