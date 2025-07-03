# Data Take-Home Assessment

For this project, I focused on building a clean, reliable foundation, starting with data quality and modeling, then working toward clear answers to each business question. The goal was to show how I'd approach this in a real-world setting: balancing clarity, scalability, and practical use.

Below is a breakdown of the steps I took, along with reflections on how this approach would scale in production.

## Data Architecture & Modeling Approach

### 1. Data Quality and Integrity Strategy

#### **Data Quality Issues Identified:**
- **Invalid ages**: Negative values (-5), unrealistic values (150+), null values
- **Invalid practice references**: Patients with practice_id = 0, 999, or null
- **Invalid activity data**: Negative durations, null durations, orphaned activities
- **Duplicate records**: Multiple patient entries with same patient_id
- **Missing data**: Null phone numbers, emails, gender values
- **Data format issues**: Inconsistent phone number formats, JSON parsing challenges

#### **Approach to Data Quality:**

**1. Layered Architecture:**
- **Staging Layer**: Preserves raw data for auditability
- **Intermediate Layer**: Applies business rules and data cleaning
- **Mart Layer**: Clean, analysis-ready dimensional models

**2. Data Cleaning Strategy:**
```sql
-- Example: Age validation in int_patients_clean.sql
where age between 0 and 120  -- Filter out invalid ages
  and practice_id is not null  -- Remove orphaned patients
  and practice_id in (select practice_id from stg_practices)  -- Valid practice references
```

**3. Deduplication:**
```sql
-- Using row_number() to keep only the most recent record
row_number() over (partition by patient_id order by registration_date desc) as rn
```

**4. Data Type Standardization:**
- Phone number cleaning using custom macro

### 2. Dimensional Model Design

#### **Core Dimensions:**
- **`dim_pcns`**: Primary Care Network information and hierarchy
- **`dim_practices`**: Practice information and PCN relationships  
- **`dim_patients`**: Patient demographics and contact information

#### **Fact Table:**
- **`fact_activities`**: Patient activity records with measures

#### **Key Design Decisions:**
- **Complete dimensional hierarchy**: PCN → Practice → Patient → Activities
- **No practice_id in fact table**: Follows dimensional modeling best practices
- **Single source of truth**: Patient-practice relationships only in dim_patients
- **Clean fact table**: Only valid activities with proper foreign keys
- **Referential integrity**: All foreign keys validated through relationships

## Business Questions & Solutions

### 1. How many patients belong to each PCN?

**Answer:**
- **visualize virtual niches PCN:** 87 patients
- **streamline proactive mindshare PCN:** 76 patients


### 2. What's the average patient age per practice?

**Answer:**
- **Hayes, Walker and Williams Clinic:** 59.0 years
- **Foster, West and Miller Clinic:** 57.0 years
- **Meza-Smith Clinic:** 56.0 years
- **Dominguez Ltd Clinic:** 49.0 years

**Key Features:**
- Excludes invalid ages (filtered in intermediate layer)
- Only includes patients with valid practice references
- Handles null ages appropriately

### 3. Patient age groups by PCN

**Answer:**

| PCN                                 | Age Group | Patient Count |
|--------------------------------------|-----------|--------------|
| streamline proactive mindshare PCN   | 0-18      | 6            |
| streamline proactive mindshare PCN   | 19-35     | 19           |
| streamline proactive mindshare PCN   | 36-50     | 9            |
| streamline proactive mindshare PCN   | 51+       | 42           |
| visualize virtual niches PCN         | 0-18      | 16           |
| visualize virtual niches PCN         | 19-35     | 16           |
| visualize virtual niches PCN         | 36-50     | 19           |
| visualize virtual niches PCN         | 51+       | 36           |


### 4. Hypertension percentage by practice

**Answer:**
- **Dominguez Ltd Clinic:** 44.9%
- **Foster, West and Miller Clinic:** 42.11%
- **Meza-Smith Clinic:** 39.47%
- **Hayes, Walker and Williams Clinic:** 26.32%


**Key Features:**
- JSON array parsing for conditions
- Percentage calculation with proper decimal handling
- Only includes valid patients and practices

### 5. Most recent activity per patient

**Answer:**
There are 163 patients in the cleaned dataset.

**Example (10 most recent):**

| patient_id | most_recent_activity_date |
|------------|--------------------------|
| 1054       | 2025-03-08 16:30:00      |
| 1086       | 2025-03-08 15:15:00      |
| 1246       | 2025-03-08 15:00:00      |
| 1224       | 2025-03-08 14:30:00      |
| 1014       | 2025-03-08 14:30:00      |
| 1001       | 2025-03-07 16:15:00      |
| 1213       | 2025-03-07 15:45:00      |
| 1238       | 2025-03-07 15:15:00      |
| 1148       | 2025-03-07 14:45:00      |
| 1077       | 2025-03-07 14:00:00      |


### 6. Patients with no activity for 3 months

**Answer:**
- **Total patients with no activity for 3 months after their first activity:** 112


**Example (first 10):**

| patient_id | age | age_group | practice_id | first_activity_date | last_activity_date | gap_duration |
|------------|-----|-----------|-------------|-------------------|-------------------|--------------|
| 1100001    | 35  | 19-35     | 1           | 2023-01-10 14:30:00 | 2023-04-10 14:30:00 | 90 days |
| 1099       | 109 | 51+       | 3           | 2024-03-05 11:30:00 | 2025-02-24 11:00:00 | 355 days |
| 1058       | 29  | 19-35     | 1           | 2024-03-23 10:00:00 | 2025-02-07 10:15:00 | 321 days |
| 1057       | 77  | 51+       | 2           | 2024-03-27 09:15:00 | 2024-11-11 16:45:00 | 229 days |
| 1091       | 8   | 0-18      | 3           | 2024-03-29 09:30:00 | 2025-03-03 16:15:00 | 339 days |
| 1183       | 70  | 51+       | 3           | 2024-03-30 10:30:00 | 2025-02-06 13:45:00 | 313 days |
| 1107       | 85  | 51+       | 1           | 2024-03-30 14:00:00 | 2025-01-02 09:45:00 | 278 days |
| 1062       | 115 | 51+       | 4           | 2024-03-30 14:30:00 | 2025-02-17 10:45:00 | 323 days |
| 1053       | 55  | 51+       | 2           | 2024-04-23 13:00:00 | 2025-03-01 15:30:00 | 312 days |
| 1247       | 0   | 0-18      | 4           | 2024-04-29 14:45:00 | 2025-03-01 11:30:00 | 305 days |

## Real-World Production Approaches

### **Assignment vs Production Patterns**

**This Assignment Approach:**
- ✅ **Specific question marts**: `mart_patient_pcn_summary`, `mart_practice_age_summary`, etc.
- ✅ **Direct answers**: Each business question has a dedicated mart model

**Real-World Production Approach:**
- ✅ **Generic, reusable marts**: Focus on common metrics and dimensions
- ✅ **Semantic layer**: Business questions answered through BI tools and analytics platforms
- ✅ **Ad-hoc analysis**: Data analysts write SQL directly against dimensional models

### **Production-Ready Architecture**

#### **1. Semantic Layer Approach (Recommended)**

**Modern Data Stack:**
```
Raw Data → dbt (Transform) → Data Warehouse → Semantic Layer → BI Tools
```

**Example of Semantic Layer Tools:**
- **dbt Semantic Layer - dbt Cloud**: Define metrics once, query anywhere
- **Cube**: Headless BI with API-first approach
- **Metabase**: Self-service analytics with semantic layer
- **Looker/Omni**: Data modeling and exploration platform

### **Recommended Production Architecture**

#### **Phase 1: Foundation (Current State)**
- ✅ **Core dimensional models**: `dim_patients`, `dim_practices`, `dim_pcns`, `fact_activities`
- ✅ **Data quality layer**: Comprehensive testing and validation
- ✅ **Documentation**: Complete schema documentation

#### **Phase 2: Generic Marts**
- **`mart_patient_summary`**: All patient metrics in one place
- **`mart_practice_summary`**: All practice metrics in one place
- **`mart_activity_summary`**: All activity metrics in one place

#### **Phase 3: Semantic Layer**
- **dbt Semantic Layer**: Define metrics once, query anywhere
- **BI Tool Integration**: Connect to Tableau, Power BI, Looker or Omni (these two can be used as Semantic Layers as well)
- **Self-Service Analytics**: Enable business users to explore data

#### **Phase 4: Advanced Analytics**
- **ML/AI Integration**: Predictive analytics on patient outcomes
- **Real-time Analytics**: Streaming data for operational dashboards
- **Data Governance**: Advanced security and access controls


## Data Quality Results

After implementing this specific data quality strategy:
- **Total valid patients:** 163 (filtered from raw data with quality issues)
- **Total valid activities:** 1,194 (cleaned and validated)
- **All fact table tests pass:** ✅
- **All dimensional model tests pass:** ✅

### **Data Quality Filtering Impact**

This data quality approach resulted in filtering out significant data quality issues:

**Raw Data Analysis:**
- **Total raw patients:** 255
- **Patients with invalid practice_id (0, 999, null):** 28 patients
- **Patients with invalid ages:** 44 patients  
- **Duplicate patients:** 20 patients
- **Final cleaned patients:** 163

**Practice Distribution Before vs After Cleaning:**
| practice_id | Raw Patients | Cleaned Patients | Filtered Out |
|-------------|--------------|------------------|--------------|
| 1           | 45           | 38               | 7            |
| 2           | 42           | 38               | 4            |
| 3           | 56           | 49               | 7            |
| 4           | 46           | 38               | 8            |
| 0           | 4            | 0                | 4            |
| 999         | 11           | 0                | 11           |
| null        | 13           | 0                | 13           |
| 5           | 38           | 0                | 38           |

**PCN Distribution Comparison:**
| PCN                                 | Raw Data | Cleaned Data 
|--------------------------------------|----------|------------------|
| visualize virtual niches PCN         | 102      | 87               | 
| streamline proactive mindshare PCN   | 87       | 76               | 

*Note: The level of data quality filtering can be adjusted based on how data sources are managed and the outcomes of discussions with stakeholders and platform owners.


**Approach:**
- ✅ **Strict data validation:** Filter out invalid ages, practice references, and duplicates
- ✅ **Referential integrity:** Only include patients with valid practice relationships
- ✅ **Business logic compliance:** Exclude orphaned records that can't be properly analyzed
- ✅ **Data lineage:** Clear audit trail of what was filtered and why


**Key Data Quality Decisions:**
1. **Excluded practice_id = 0, 999, null:** These represent invalid practice references
2. **Excluded practice_id = 5:** This practice doesn't exist in the practices table
3. **Filtered invalid ages:** Removed negative ages and unrealistic values (>120)
4. **Deduplicated patients:** Kept only the most recent registration per patient
5. **Validated relationships:** Ensured all patients have valid practice and PCN relationships

**Business Impact:**
- **Reliable analytics:** All numbers represent real, analyzable patients
- **Data integrity:** No orphaned records that would break joins
- **Audit compliance:** Clear documentation of data quality decisions
- **Production readiness:** Approach suitable for enterprise data warehouses

## Testing Strategy

### **Data Quality Tests:**
- **Uniqueness**: No duplicate patients or activities
- **Referential Integrity**: All foreign keys reference valid records
- **Data Ranges**: Ages between 0-120, durations positive
- **Not Null**: Critical fields must have values

### **Custom Tests:**
```sql
-- Example: assert_no_invalid_ages.sql
select count(*) as invalid_ages
from dim_patients 
where age < 0 OR age > 120
```

## Technical Implementation Details

### **Project Structure:**
```
models/
├── staging/          # Raw data preservation
├── intermediate/     # Data cleaning and business logic
└── marts/           # Analysis-ready dimensional models
```

### **Key Macros:**
- `clean_phone_number.sql`: Standardizes phone number formats
- Custom tests for data quality validation

### **Dependencies:**
- dbt-utils for advanced testing capabilities

## Production Enhancements

### **1. Slowly Changing Dimensions (SCDs)**

In a production environment, dimensional data changes over time and needs to be tracked:

- **SCD Type 1**: Overwrite existing records (current implementation)
- **SCD Type 2**: Historical tracking with effective dates and versioning (recommended for production)
- **SCD Type 3**: Limited history with previous value columns

**Key considerations**: Patient age groups, practice transfers, condition changes over time.

### **2. Source Freshness Monitoring**

Production environments require monitoring of data freshness and pipeline health:

- **Source freshness configuration** with warning/error thresholds (2-48 hours)
- **Custom freshness tests** for monitoring data staleness
- **Pipeline health monitoring** dashboards
- **Automated alerts** when data is stale

**Key considerations**: Real-time activity data (2-4 hour thresholds), patient data (6-12 hours), practice data (24-48 hours).

### **3. Incremental Models for Performance**

For large datasets, incremental models would be implemented:

- **Incremental fact tables** for activity data
- **Unique key configuration** for deduplication
- **Schema change handling** for evolving data structures
- **Performance optimization** for large-scale data processing

### **4. Data Lineage and Impact Analysis**

- **Custom lineage tests** to track data dependencies
- **Impact analysis** for model changes
- **Orphaned record detection** and validation
- **Documentation of data flows** and transformations

### **5. Performance Optimization**

- **Clustering and partitioning** strategies for large tables
- **Materialization strategy** optimization (views vs tables)
- **Query performance** monitoring and optimization
- **Resource utilization** tracking

### **6. Data Quality Monitoring**

- **Automated data quality metrics** and scoring
- **Real-time quality monitoring** dashboards
- **Quality threshold alerts** and notifications
- **Data quality trend analysis** over time

### **7. Alerting and Notifications**

- **dbt alerts configuration** for critical issues
- **Slack/email integration** for team notifications
- **Escalation procedures** for data pipeline failures
- **Automated recovery** processes where possible

### **8. Additional Production Considerations**

- **Data governance** and access controls
- **Backup and recovery** procedures
- **Disaster recovery** planning
- **Compliance monitoring** (HIPAA for healthcare)
- **Audit logging** and data lineage tracking
- **Cost optimization** and resource management

These production enhancements would transform this assignment into a robust, enterprise-ready data pipeline with proper monitoring, performance optimization, and data quality management suitable for real-world healthcare analytics.
