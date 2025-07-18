import os

# Racine du projet
base_dir = "DATA_binance"
subdirs = [
    "data",
    "logs"
]

ndjson_files = [
    "btc_usdt.ndjson",
    "eth_usdt.ndjson",
    "sol_usdt.ndjson",
    "bnb_usdt.ndjson"
]

log_file = "logs/ws_errors.log"
main_script = "stream_multi.py"

# 1. Créer les dossiers
os.makedirs(base_dir, exist_ok=True)
for sub in subdirs:
    os.makedirs(os.path.join(base_dir, sub), exist_ok=True)

# 2. Créer les fichiers NDJSON vides
for file in ndjson_files:
    file_path = os.path.join(base_dir, "data", file)
    if not os.path.exists(file_path):
        open(file_path, "w").close()

# 3. Créer le fichier de log
log_path = os.path.join(base_dir, log_file)
if not os.path.exists(log_path):
    open(log_path, "w").close()

# 4. Créer un fichier stream_multi.py vide si tu veux le compléter ensuite
script_path = os.path.join(base_dir, main_script)
if not os.path.exists(script_path):
    with open(script_path, "w") as f:
        f.write("# Script WebSocket multi-paires Binance\n")

print(f"✅ Structure créée dans : {base_dir}")
