# README: NBA Analysis

## Project Overview

This project aims to explore the multiple factors that affect the winning percentage of players and teams in NBA basketball games, and analyze the potential impact of geographical distribution on the winning percentage. Through the systematic study of four parts, the aim is to reveal the complex mechanism behind the winning rate of basketball games, and provide scientific basis for team management, player development and coach strategy formulation.

- Analysis of winning percentage of NBA players: Analyze the difference of winning percentage of different players in home-and-away scenarios, so as to reveal the impact of this important factor on the winning percentage of players, so as to better comprehensively evaluate the ranking and ability of players.

- Analysis of factors affecting the winning rate of NBA teams: From a macro perspective, the relationship between the overall winning rate of a team and team strategy, coaching, player cooperation, injuries, team chemistry and other factors is studied. The random forest model was used to quantify the influence and importance of these factors on the winning rate.

- Analysis of influencing factors of winning percentage of NBA players: In-depth study on how players' personal technical characteristics and other factors affect their winning percentage at the individual level. Collect and analyze detailed data of NBA players, including key statistical indicators such as points, rebounds, and assists, and explore the relationship between these data and players' win percentage. By comparing players at different positions and skill levels, the specific contribution of individual ability to the winning percentage is assessed.
Analysis of the geographical distribution and winning rate of NBA teams: consider the climatic conditions, economic level, fan culture, transportation convenience and other factors of the city where the team is located, and study how these geographical and socioeconomic factors affect the winning rate of the team. With the ggplot2 package in R, visualize team distribution and explore the correlation between geography and winning percentage.

- Research significance: This project not only provides in-depth data analysis perspective for basketball lovers, but also provides scientific basis for strategy formulation and personal development for team management, coaching team and individual players, which can provide decision support for NBA team management and help them conduct player selection, coaching team construction and strategic planning more scientifically. At the same time, it provides personalized training suggestions for individual players to improve their competitive level. In addition, the research results will also provide new research perspectives and data support for sports science, psychology, geography and other disciplines.

## Data

The dataset is downloaded from Kaggle (https://www.kaggle.com/datasets/nathanlauga/nba-games),  Below is a list of datasets utilized:

- games.csv : all games from 2004 season to last update with the date, teams and some details like number of points, etc.
- games_details.csv : details of games dataset, all statistics of players for a given game
- players.csv : players details (name)
- ranking.csv : ranking of NBA given a day 
- teams.csv : all teams of NBA

# Source Code

The source code used is as followed:

- app.py: Script to start the web app
- code.R: Scripts for data cleaning, analysis, and visualization
- report.Rmd: Write scripts for data analysis reports

# Running the Web App

First, you should installing the python package `streamlit`:

```python
pip install streamlit
```

then, runing:

```bash
streamlit run app.py
```

## License

This project is open source and available under the MIT License.

## Contact

For any further queries or suggestions, feel free to contact at.