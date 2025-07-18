import json
import websocket
import threading
import time
from datetime import datetime
import os
import pytz

# Dictionnaire des symboles Binance → fichiers de sortie
SYMBOLS = {
    "btcusdt": "btc_usdt.ndjson",
    "ethusdt": "eth_usdt.ndjson",
    "solusdt": "sol_usdt.ndjson",
    "bnbusdt": "bnb_usdt.ndjson"
}

NDJSON_DIR = "data"
LOGS_DIR = "logs"

# Crée les dossiers si non existants
os.makedirs(NDJSON_DIR, exist_ok=True)
os.makedirs(LOGS_DIR, exist_ok=True)

def on_message(symbol):
    def handler(ws, message):
        data = json.loads(message)
        timestamp_utc = datetime.utcfromtimestamp(data['T'] / 1000)
        timestamp_local = timestamp_utc.replace(tzinfo=pytz.utc).astimezone(pytz.timezone("Europe/Paris"))

        trade = {
            "symbol": symbol.upper(),
            "timestamp": timestamp_utc.isoformat(),
            "timestamp_local": timestamp_local.isoformat(),
            "price": data['p'],
            "quantity": data['q'],
            "trade_id": data['t'],
            "buyer_market_maker": data['m']
        }

        file_path = os.path.join(NDJSON_DIR, SYMBOLS[symbol])
        with open(file_path, "a") as f:
            f.write(json.dumps(trade) + "\n")

        print(f"[{symbol.upper()}] {timestamp_local.strftime('%H:%M:%S')} - Prix: {trade['price']}")
    return handler

def on_error(ws, error):
    print("[WS ERROR]", error)
    with open(os.path.join(LOGS_DIR, "ws_errors.log"), "a") as log:
        log.write(str(error) + "\n")

def start_stream(symbol):
    url = f"wss://stream.binance.com:9443/ws/{symbol}@trade"

    def connect():
        while True:
            print(f"[CONNECT] {symbol.upper()} → {url}")
            ws = websocket.WebSocketApp(
                url,
                on_message=on_message(symbol),
                on_error=on_error,
                on_close=lambda ws, *args: print(f"[CLOSED] {symbol.upper()}")
            )
            try:
                ws.run_forever()
            except Exception as e:
                print(f"[EXCEPTION] {symbol.upper()} - {e}")
            print(f"[RETRY] {symbol.upper()} → reconnexion dans 5 secondes...")
            time.sleep(5)

    connect()

if __name__ == "__main__":
    threads = []
    for symbol in SYMBOLS:
        t = threading.Thread(target=start_stream, args=(symbol,))
        t.daemon = True
        t.start()
        threads.append(t)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[EXIT] Arrêt du script.")
