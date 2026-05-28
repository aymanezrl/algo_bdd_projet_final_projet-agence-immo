# ============================================
# DASHBOARD - SCORING LEADS AGENCE IMMO
# ============================================

import dash
from dash import dcc, html, Input, Output
import plotly.express as px
import plotly.graph_objects as go
import mysql.connector
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

# ============================================
# CHARGEMENT DES DONNÉES
# ============================================
def charger_donnees_dashboard():
    conn = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
    df = pd.read_sql("SELECT * FROM scoring_leads", conn)
    conn.close()
    return df

df = charger_donnees_dashboard()

# ============================================
# INITIALISATION DE L'APP
# ============================================
app = dash.Dash(__name__)

# ============================================
# LAYOUT DU DASHBOARD
# ============================================
app.layout = html.Div([

    # Titre
    html.H1("🏠 Dashboard - Scoring Leads Agence Immo",
            style={'textAlign': 'center', 'color': '#2c3e50', 'marginBottom': '10px'}),

    # Filtre dropdown
    html.Div([
        html.Label("Filtrer par segment :"),
        dcc.Dropdown(
            id='filtre-segment',
            options=[
                {'label': 'Tous', 'value': 'Tous'},
                {'label': 'Hot 🔥', 'value': 'Hot 🔥'},
                {'label': 'Warm 🌤️', 'value': 'Warm 🌤️'},
                {'label': 'Cold ❄️', 'value': 'Cold ❄️'}
            ],
            value='Tous',
            clearable=False,
            style={'width': '300px'}
        )
    ], style={'margin': '20px'}),

    # KPIs
    html.Div(id='kpis', style={
        'display': 'flex',
        'justifyContent': 'space-around',
        'margin': '20px'
    }),

    # Graphiques
    html.Div([
        html.Div([
            dcc.Graph(id='graph-segments')
        ], style={'width': '48%', 'display': 'inline-block'}),

        html.Div([
            dcc.Graph(id='graph-scores')
        ], style={'width': '48%', 'display': 'inline-block'})
    ]),

    html.Div([
        dcc.Graph(id='graph-budget-score')
    ])

], style={'fontFamily': 'Arial', 'backgroundColor': '#f8f9fa', 'padding': '20px'})

# ============================================
# CALLBACK - mise à jour selon le filtre
# ============================================
@app.callback(
    Output('kpis', 'children'),
    Output('graph-segments', 'figure'),
    Output('graph-scores', 'figure'),
    Output('graph-budget-score', 'figure'),
    Input('filtre-segment', 'value')
)
def mettre_a_jour_dashboard(segment_choisi):

    # Filtrage des données
    if segment_choisi == 'Tous':
        df_filtre = df.copy()
    else:
        df_filtre = df[df['segment'] == segment_choisi].copy()

    # --- KPIs ---
    nb_prospects = len(df_filtre)
    score_moyen = round(df_filtre['score_total'].mean(), 1)
    budget_moyen = round(df_filtre['budget_max'].mean() / 1000, 0)
    nb_hot = len(df_filtre[df_filtre['segment'] == 'Hot 🔥'])

    kpis = [
        html.Div([
            html.H3(nb_prospects, style={'color': '#3498db', 'margin': '0'}),
            html.P("Prospects", style={'margin': '0'})
        ], style={'textAlign': 'center', 'background': 'white',
                  'padding': '20px', 'borderRadius': '10px', 'width': '20%'}),

        html.Div([
            html.H3(f"{score_moyen}/100", style={'color': '#e74c3c', 'margin': '0'}),
            html.P("Score moyen", style={'margin': '0'})
        ], style={'textAlign': 'center', 'background': 'white',
                  'padding': '20px', 'borderRadius': '10px', 'width': '20%'}),

        html.Div([
            html.H3(f"{int(budget_moyen)}k€", style={'color': '#2ecc71', 'margin': '0'}),
            html.P("Budget moyen", style={'margin': '0'})
        ], style={'textAlign': 'center', 'background': 'white',
                  'padding': '20px', 'borderRadius': '10px', 'width': '20%'}),

        html.Div([
            html.H3(nb_hot, style={'color': '#e67e22', 'margin': '0'}),
            html.P("Leads Hot 🔥", style={'margin': '0'})
        ], style={'textAlign': 'center', 'background': 'white',
                  'padding': '20px', 'borderRadius': '10px', 'width': '20%'}),
    ]

    # --- Graphique 1 : Répartition des segments ---
    segment_counts = df_filtre['segment'].value_counts().reset_index()
    segment_counts.columns = ['segment', 'count']
    fig_segments = px.pie(
        segment_counts,
        values='count',
        names='segment',
        title='Répartition des segments',
        color_discrete_sequence=['#e74c3c', '#f39c12', '#3498db']
    )

    # --- Graphique 2 : Top 10 prospects par score ---
    top10 = df_filtre.nlargest(10, 'score_total')
    top10['nom_complet'] = top10['prenom'] + ' ' + top10['nom']
    fig_scores = px.bar(
        top10,
        x='score_total',
        y='nom_complet',
        orientation='h',
        title='Top 10 prospects par score',
        color='score_total',
        color_continuous_scale='RdYlGn',
        labels={'score_total': 'Score', 'nom_complet': 'Prospect'}
    )
    fig_scores.update_layout(yaxis={'categoryorder': 'total ascending'})

    # --- Graphique 3 : Budget vs Score ---
    fig_budget = px.scatter(
        df_filtre,
        x='budget_max',
        y='score_total',
        color='segment',
        hover_data=['nom', 'prenom', 'ville'],
        title='Budget vs Score par prospect',
        labels={'budget_max': 'Budget (€)', 'score_total': 'Score'},
        color_discrete_map={
            'Hot 🔥': '#e74c3c',
            'Warm 🌤️': '#f39c12',
            'Cold ❄️': '#3498db'
        }
    )

    return kpis, fig_segments, fig_scores, fig_budget

# ============================================
# LANCEMENT
# ============================================
if __name__ == '__main__':
    app.run(debug=True)