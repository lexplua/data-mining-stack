### MLFlow + MinIO + Postgres

Local dev environment setup for experiment tracking and artifact storage

Implements Scenario 4 from MLflow [documentation](https://www.mlflow.org/docs/latest/tracking.html#scenario-4-mlflow-with-remote-tracking-server-backend-and-artifact-stores)
![diagram](https://www.mlflow.org/docs/latest/_images/scenario_4.png)

MinIO as S3 protocol storage

Usage:

Checkout repository, change `.env` file if needed. Run `docker compose`
```bash
docker compose up --build
```

MinIO web interface on your machine: http://localhost:9001/

MLflow web interface on yor machine: http://localhost:5000/


Environment variables for training scripts:
```python
import mlflow
import os
os.environ['AWS_ACCESS_KEY_ID'] = "1234"
os.environ['AWS_SECRET_ACCESS_KEY'] ="123441212344321"
os.environ['MLFLOW_S3_ENDPOINT_URL']="http://localhost:9000"
mlflow.set_tracking_uri('http://localhost:5000/')
```

For `mlflow` CLI also environment variable must be set
```bash
export MLFLOW_TRACKING_URI=http://localhost:5000/
```