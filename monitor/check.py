import os
import psycopg2
import requests
from dotenv import load_dotenv

load_dotenv(dotenv_path="../.env")

FILAMENT_API_URL = os.getenv("FILAMENT_API_URL", "http://localhost:8080/api/v1")
SOURCE_DSN = os.getenv("POSTGRES_DSN", "postgres://filament:secure_filament_password@localhost:5432/app_db?sslmode=disable")

def check_replication_lag():
    """Calculates byte lag between current server WAL and the replication slot."""
    try:
        conn = psycopg2.connect(SOURCE_DSN)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT 
                slot_name, 
                active, 
                pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn) AS byte_lag 
            FROM pg_replication_slots 
            WHERE plugin = 'pgoutput';
        """)
        
        slots = cursor.fetchall()
        cursor.close()
        conn.close()
        
        lag_metrics = []
        for slot in slots:
            slot_name, active, byte_lag = slot
            lag_metrics.append({
                "slot_name": slot_name,
                "active": active,
                "byte_lag_bytes": byte_lag or 0
            })
        return lag_metrics
    except Exception as e:
        return [{"error": str(e)}]

def get_pipeline_health():
    try:
        response = requests.get(f"{FILAMENT_API_URL}/pipelines/orders_audit_cdc/status", timeout=3)
        if response.status_code == 200:
            return response.json()
        return {"status_code": response.status_code, "message": "Pipeline endpoint unreachable"}
    except requests.exceptions.RequestException:
        return {"error": "Unable to reach Filament control plane API"}

if __name__ == "__main__":
    print("=== Filament CDC Pipeline Health Report ===")
    print("Replication Slot Lag:", check_replication_lag())
    print("Pipeline API Status:", get_pipeline_health())