# Age COE Pipeline (Snowflake + dbt + Streamlit)

This repo reproduces the analysis pipeline you asked for:
- **dlt** loads raw data (e.g. `results.csv`) into **Snowflake** as `RAW_RESULTS`
- **dbt** transforms & aggregates:
  - cleans and normalises fields
  - computes **subject_age_years**, **absolute error** with optional ±2σ outlier nulling (per method)
  - builds **age-gate** checks (13/16/18) into TP/TN/FP/FN and metrics (Accuracy, FPR, FNR, TPR, TNR)
  - summarises **MAE** overall and per gate
  - parses `verification_time` to seconds and aggregates latency
- **Streamlit** provides a lightweight dashboard over the dbt output tables

## 0) Prereqs

- Python 3.10+
- A Snowflake account + a role/warehouse/database/schema you can write to
- `dbt-core` and `dbt-snowflake`
- `dlt` with Snowflake destination
- `streamlit`

## 1) Configure credentials

Copy `.env.example` to `.env` and fill in your Snowflake details.

```bash
cp .env.example .env
# then edit .env with your account, user, etc.
```

Environment variables used:

- `SNOWFLAKE_ACCOUNT` (like `xy12345.ap-southeast-2` without `.snowflakecomputing.com`)
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`
- `SNOWFLAKE_DATABASE`
- `SNOWFLAKE_SCHEMA`

> Ensure the role has USAGE on database/schema and the warehouse has adequate credits.

## 2) Install dependencies

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r dlt_pipeline/requirements.txt
pip install -r dbt_project/requirements.txt
pip install -r streamlit_app/requirements.txt
```

## 3) Load your raw CSV into Snowflake (with dlt)

Place your raw file at a path you choose (default path assumed below). Then run:

```bash
# from repo root
python dlt_pipeline/pipeline.py --csv-path ./results.csv
```

This creates/overwrites table **{SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}.RAW_RESULTS**.

## 4) Build transformations with dbt

Edit `dbt_project/profiles.yml` if needed (or set `DBT_PROFILES_DIR` to point to it). Then run:

```bash
cd dbt_project
# verify connection
dbt debug --profiles-dir .
# build models
dbt build --profiles-dir .
```

**Outputs built:**

- `INT_ABS_ERROR` (per-row absolute error and outlier flags)
- `METRICS_ESTIMATION` (MAE overall & per gate; ±2σ logic applied)
- `METRICS_GATES` (confusion counts + Accuracy/FPR/FNR/TPR/TNR by gate and overall)
- `METRICS_VERIFICATION_TIME` (verification time stats by method)

## 5) Visualise with Streamlit

```bash
streamlit run streamlit_app/streamlit_app.py
```

You’ll get:
- Estimation MAE (overall & per gate)
- Age-gate metrics (13/16/18) with confusion counts
- Verification-time medians/means by method

## Notes

- The ±2σ outlier nulling is applied **per method** on absolute error, mirroring your logic.
- If your `verification_status` semantics are inverted (i.e. `'t'` means "under gate" instead of "over gate"), set `INVERT_VERIFICATION_FLAG=true` in `.env` and rerun `dbt build`.
- All object names default to upper-case (Snowflake normal). Adjust in models if needed.
