import streamlit as st
import pandas as pd


st.set_page_config(page_title="NBA Win Rate Analysis", page_icon="🏀", layout="wide", initial_sidebar_state="collapsed")



df_a = pd.read_csv('player_res.csv')
df_b = pd.read_csv('player_res_v.csv')


st.title("NBA Win Rate Analysis")

selected_data_sources = st.sidebar.multiselect("Select Data Sources:", ['Home Team', 'Visitor Team', 'Both Data', 'Image', 'ALL'], default=['Home Team'])


search_term = st.sidebar.text_input("Search by player name", "")

filtered_df_a = df_a[df_a['PLAYER_NAME'].str.contains(search_term)]
filtered_df_b = df_b[df_b['PLAYER_NAME'].str.contains(search_term)]


if 'Home Team' in selected_data_sources:
    st.write("## Home Team Data")
    st.dataframe(filtered_df_a)

if 'Visitor Team' in selected_data_sources:
    st.write("## Visitor Team Data")
    st.dataframe(filtered_df_b)

if 'Both Data' in selected_data_sources:
    st.write("## Home Team Data")
    st.dataframe(filtered_df_a)
    st.write("## Visitor Team Data")
    st.dataframe(filtered_df_b)

if 'Image' in selected_data_sources:
    st.image("nba.png", caption="NBA City")

if 'ALL' in selected_data_sources:
    st.write("## Home Team Data")
    st.dataframe(filtered_df_a)
    st.write("## Visitor Team Data")
    st.dataframe(filtered_df_b)
    st.image("nba.png", caption="NBA City")
