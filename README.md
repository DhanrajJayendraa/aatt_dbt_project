# Age assurance project Pipeline (Snowflake + dbt + Streamlit)

This repository implements a simple, reproducible pipeline:
- **Snowflake** stores raw and transformed data
- **dbt** performs transformations and computes metrics
- **Streamlit** provides a lightweight dashboard over the dbt outputs

## Architecture (high level)

1. **Manual load** of raw CSV → Snowflake table `RAW_RESULTS`
2. **dbt** transforms, cleans, and aggregates into analysis-ready tables
3. **Streamlit** reads the dbt outputs for exploration and reporting

---

## 0) Prerequisites

- Python 3.10+
- A Snowflake account + a role/warehouse/database/schema you can write to
- (Optional) `pyenv`/`venv` for isolation

---

## 1) Configure environment

Create a `.env` file (you can copy `.env.example`) and set your Snowflake details:

```
SNOWFLAKE_ACCOUNT=xxxx-xxxx
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ROLE=ANALYST
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=AGE_DB
SNOWFLAKE_SCHEMA=PUBLIC
INVERT_VERIFICATION_FLAG=false
```

> `INVERT_VERIFICATION_FLAG` flips `verification_status` semantics if your source uses inverted logic.

Install Python deps for the dbt project:

```bash
cd dbt_project
pip install -r requirements.txt
```

---

## 2) Load your raw data (manual)

You will **manually** load your CSV (e.g., `results.csv`) into Snowflake as a table named **`RAW_RESULTS`** within the database/schema configured above.

- Ensure the column names and types align with what the dbt models expect (see `dbt_project/models/staging/stg_results.sql`).
- If your schema differs, adjust `stg_results.sql` accordingly.

> No external loader is included in this repo. Manual load is sufficient.

---

## 3) Run transformations with dbt

From `dbt_project/`:

```bash
dbt build
```

The models will:
- Clean and normalize fields
- Compute **subject_age_years** and **absolute error**, with optional ±2σ outlier nulling per method
- Derive age-gate metrics (13/16/18): TP/TN/FP/FN, plus Accuracy, FPR, FNR, TPR, TNR
- Parse `verification_time` to seconds and aggregate latency

If needed, edit `profiles.yml` (or environment variables) to point dbt at your Snowflake target.

---

## 4) Run the Streamlit app

From the repo root:

```bash
streamlit run streamlit_app/streamlit_app.py
```

You’ll get:
- Estimation MAE (overall & per gate)
- Age-gate metrics (13/16/18) with confusion counts
- Verification-time medians/means by method

---

## Notes

- The ±2σ outlier nulling is applied **per method** on absolute error.
- If your `verification_status` semantics are inverted, set `INVERT_VERIFICATION_FLAG=true` in `.env` and rerun `dbt build`.
- Object names default to upper-case (Snowflake standard). Adjust in models if needed.
