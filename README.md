# Community Decision Intelligence Dashboard (CDIS)

A lightweight decision-support system designed for local NGOs and district teams to transform monitoring data into operational decisions.

**Key features**
- Upload Kobo/CSV exports or sample data.
- Automatic cleaning rules for common field datasets (health, attendance, trainings).
- Indicator generator and trend visualisations.
- Simple rule-based recommendation engine (actionable next steps).
- Designed for quick deployment in low-bandwidth contexts (Streamlit).

**Run locally**
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
streamlit run app.py
