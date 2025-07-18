# Utilise une image Python officielle légère
FROM python:3.11-slim

# Variables d'environnement pour ne pas générer de fichiers pycache
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Crée un dossier de travail dans le container
WORKDIR /app

# Copie les fichiers requirements.txt et script python dans le container
COPY requirements.txt .
COPY stream_multi.py .
COPY data ./data
COPY logs ./logs

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Crée les dossiers data et logs si pas déjà créés
RUN mkdir -p data logs

# Expose éventuellement un port si nécessaire (non nécessaire ici)
# EXPOSE 8000

# Commande pour lancer le script
CMD ["python", "stream_multi.py"]
