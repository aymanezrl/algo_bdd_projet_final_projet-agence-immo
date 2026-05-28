# ============================================
# PIPELINE DATA MARKETING - AGENCE IMMO
# Scoring de leads
# ============================================

import mysql.connector
import pandas as pd
import requests
from dotenv import load_dotenv
import os

# Chargement des variables d'environnement depuis .env
load_dotenv()

def connecter_base():
    """
    Connexion à la base MySQL via les variables d'environnement
    """
    connexion = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
    print("✅ Connexion à la base réussie !")
    return connexion

def charger_donnees(conn):
    """
    Charge les données depuis la vue vue_scoring_prospects
    et la table interactions
    """
    # Chargement de la vue scoring
    query_prospects = """
        SELECT 
            id_prospect,
            nom,
            prenom,
            ville,
            budget_max,
            nb_interactions,
            nb_biens_vus
        FROM vue_scoring_prospects
    """
    df_prospects = pd.read_sql(query_prospects, conn)
    print(f"✅ {len(df_prospects)} prospects chargés")

    # Chargement des interactions pour détecter les offres
    query_interactions = """
        SELECT 
            id_prospect,
            type_action,
            date_action
        FROM interactions
    """
    df_interactions = pd.read_sql(query_interactions, conn)
    print(f"✅ {len(df_interactions)} interactions chargées")

    return df_prospects, df_interactions
def enrichir_avec_api(df_prospects):
    """
    Enrichit les données avec l'API adresse.data.gouv.fr
    Récupère le code postal et le département de chaque ville
    """
    print("\n🌐 Appel API adresse.data.gouv.fr...")
    
    codes_postaux = []
    departements = []

    # On récupère les villes uniques pour limiter les appels API
    villes_uniques = df_prospects['ville'].unique()
    resultats_villes = {}

    for ville in villes_uniques:
        try:
            url = f"https://api-adresse.data.gouv.fr/search/?q={ville}&type=municipality&limit=1"
            response = requests.get(url, timeout=5)
            data = response.json()

            if data['features']:
                props = data['features'][0]['properties']
                resultats_villes[ville] = {
                    'code_postal': props.get('postcode', 'N/A'),
                    'departement': props.get('context', 'N/A').split(',')[0]
                }
            else:
                resultats_villes[ville] = {
                    'code_postal': 'N/A',
                    'departement': 'N/A'
                }
        except:
            resultats_villes[ville] = {
                'code_postal': 'N/A',
                'departement': 'N/A'
            }

    # Ajout des colonnes au dataframe
    df_prospects['code_postal'] = df_prospects['ville'].map(
        lambda v: resultats_villes[v]['code_postal']
    )
    df_prospects['departement'] = df_prospects['ville'].map(
        lambda v: resultats_villes[v]['departement']
    )

    print(f"✅ Enrichissement API terminé pour {len(villes_uniques)} villes")
    return df_prospects
def calculer_score_leads(df_prospects, df_interactions):
    """
    Calcule un score de lead pour chaque prospect
    basé sur 4 critères :
    - nb_interactions : plus il interagit, plus il est chaud
    - nb_biens_vus    : plus il visite de biens, plus il est sérieux
    - budget_max      : plus son budget est élevé, plus il est prioritaire
    - a_fait_offre    : s'il a déjà fait une offre, score maximum
    
    Score final : 0 à 100
    """

    # Critère 1 : score interactions (max 30 points)
    max_interactions = df_prospects['nb_interactions'].max()
    df_prospects['score_interactions'] = (
        df_prospects['nb_interactions'] / max_interactions * 30
    ).round(1)

    # Critère 2 : score biens vus (max 25 points)
    max_biens = df_prospects['nb_biens_vus'].max()
    df_prospects['score_biens'] = (
        df_prospects['nb_biens_vus'] / max_biens * 25
        if max_biens > 0 else 0
    ).round(1)

    # Critère 3 : score budget (max 25 points)
    max_budget = df_prospects['budget_max'].max()
    df_prospects['score_budget'] = (
        df_prospects['budget_max'] / max_budget * 25
    ).round(1)

    # Critère 4 : bonus offre déposée (20 points)
    prospects_avec_offre = df_interactions[
        df_interactions['type_action'] == 'offre'
    ]['id_prospect'].unique()

    df_prospects['score_offre'] = df_prospects['id_prospect'].apply(
        lambda x: 20 if x in prospects_avec_offre else 0
    )

    # Score total
    df_prospects['score_total'] = (
        df_prospects['score_interactions'] +
        df_prospects['score_biens'] +
        df_prospects['score_budget'] +
        df_prospects['score_offre']
    ).round(1)

    # Segmentation en 3 catégories
    df_prospects['segment'] = df_prospects['score_total'].apply(
        lambda s: 'Hot 🔥' if s >= 60
        else ('Warm 🌤️' if s >= 30
        else 'Cold ❄️')
    )

    print("\n✅ Scoring terminé !")
    print(df_prospects[['nom', 'prenom', 'score_total', 'segment']]
          .sort_values('score_total', ascending=False)
          .head(10))

    return df_prospects
def sauvegarder_resultats(df_prospects, conn):
    """
    Sauvegarde les résultats du scoring dans 
    une nouvelle table MySQL : scoring_leads
    """
    cursor = conn.cursor()

    # Création de la table si elle n'existe pas
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS scoring_leads (
            id_prospect     INT PRIMARY KEY,
            nom             VARCHAR(100),
            prenom          VARCHAR(100),
            ville           VARCHAR(100),
            code_postal     VARCHAR(10),
            departement     VARCHAR(10),
            budget_max      DECIMAL(10,2),
            nb_interactions INT,
            nb_biens_vus    INT,
            score_interactions DECIMAL(5,1),
            score_biens     DECIMAL(5,1),
            score_budget    DECIMAL(5,1),
            score_offre     INT,
            score_total     DECIMAL(5,1),
            segment         VARCHAR(20)
        )
    """)

    # Suppression des anciennes données
    cursor.execute("DELETE FROM scoring_leads")

    # Insertion des nouvelles données
    for _, row in df_prospects.iterrows():
        cursor.execute("""
            INSERT INTO scoring_leads VALUES
            (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            int(row['id_prospect']),
            row['nom'], row['prenom'], row['ville'],
            row['code_postal'], row['departement'],
            float(row['budget_max']),
            int(row['nb_interactions']),
            int(row['nb_biens_vus']),
            float(row['score_interactions']),
            float(row['score_biens']),
            float(row['score_budget']),
            int(row['score_offre']),
            float(row['score_total']),
            row['segment']
        ))

    conn.commit()
    cursor.close()
    print(f"\n✅ {len(df_prospects)} prospects sauvegardés dans scoring_leads !")
# Exécution
conn = connecter_base()
df_prospects, df_interactions = charger_donnees(conn)
df_prospects = enrichir_avec_api(df_prospects)
df_prospects = calculer_score_leads(df_prospects, df_interactions)
sauvegarder_resultats(df_prospects, conn)
conn.close()
print("\n🚀 Pipeline terminé avec succès !")