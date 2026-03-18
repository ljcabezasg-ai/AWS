import boto3
import os
from datetime import datetime

# 🔧 CONFIGURACIÓN
bucket_name = "backup-restart-johanna-123"   
local_folder = "./mi_carpeta"    # ⚠️ CAMBIA ESTO

# Cliente S3
s3 = boto3.client('s3')

# Crear carpeta con fecha
fecha = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
s3_folder = f"backup_{fecha}/"

def upload_folder():
    for root, dirs, files in os.walk(local_folder):
        for file in files:
            local_path = os.path.join(root, file)

            # Mantener estructura
            relative_path = os.path.relpath(local_path, local_folder)
            s3_path = s3_folder + relative_path.replace("\\", "/")

            try:
                s3.upload_file(local_path, bucket_name, s3_path)
                print(f"Subido: {s3_path}")
            except Exception as e:
                print(f"Error: {e}")

if __name__ == "__main__":
    upload_folder()