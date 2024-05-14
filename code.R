setwd("C:\\Users\\Administrator\\Desktop\\nba")
library(tidyverse)
library(randomForest)
library(ggrepel)
game=read_csv("games.csv")
game_detile=read_csv("games_details.csv")
rank=read_csv("ranking.csv")
team=read_csv("teams.csv")
player=read_csv("players.csv")
#games
game=game[,-c(3,7,14)]#比赛主客队得分
#game_detile
game_detile=game_detile[,-c(9)]#球员得分


#分析球员姓名和比赛结果关系(算胜率，胜场最多)
###主场
merged_data = inner_join(game, player, by = c('SEASON',"HOME_TEAM_ID" = "TEAM_ID"),relationship = "many-to-many")
###球员
temp_dat=merged_data  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamTotal=n())
mean_count=mean(temp_dat$TeamTotal)
merged_data  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamWinning =sum(HOME_TEAM_WINS)/n(), TeamWins=sum(HOME_TEAM_WINS), TeamTotal=n())%>%filter(TeamTotal>mean_count) %>%
  arrange(desc(TeamWinning))%>%head(10)
play_res=merged_data  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamWinning =sum(HOME_TEAM_WINS)/n(), TeamWins=sum(HOME_TEAM_WINS), TeamTotal=n())%>%filter(TeamTotal>mean_count) %>%
  arrange(desc(TeamWinning))

write.csv(play_res,"player_res.csv")
###客场

merged_data_v <- inner_join(game, player, by = c('SEASON',"VISITOR_TEAM_ID" = "TEAM_ID"),relationship = "many-to-many")
temp_dat_v=merged_data_v  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamTotal=n())
mean_count_v=mean(temp_dat$TeamTotal)

merged_data_v  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamWinning =sum(ifelse(HOME_TEAM_WINS == 0, 1, 0))/n(), TeamWins=sum(HOME_TEAM_WINS), TeamTotal=n())%>%filter(TeamTotal>mean_count_v) %>%
  arrange(desc(TeamWinning))%>%head(10)

play_res_v=merged_data_v  %>%
  group_by(PLAYER_NAME) %>%na.omit()%>%
  summarise(TeamWinning =sum(ifelse(HOME_TEAM_WINS == 0, 1, 0))/n(), TeamWins=sum(HOME_TEAM_WINS), TeamTotal=n())%>%filter(TeamTotal>mean_count_v) %>%
  arrange(desc(TeamWinning))
write.csv(play_res_v,"player_res_v.csv")


##分析团队比赛结果因素
game_detile_team=game_detile%>%select(-TEAM_CITY,-PLAYER_ID,-PLAYER_NAME,-NICKNAME,-START_POSITION,-MIN)%>%group_by(GAME_ID,TEAM_ID,TEAM_ABBREVIATION)%>%summarise_all(mean)
game_team=game%>%select(-GAME_DATE_EST,-VISITOR_TEAM_ID,-SEASON)
total_data=game_detile_team%>%inner_join(game_team,by=c("GAME_ID",'TEAM_ID'='HOME_TEAM_ID'),relationship = "many-to-many")%>%na.omit()
#linear model
##随机森林
total_data$HOME_TEAM_WINS=as.factor(total_data$HOME_TEAM_WINS)
model_team=randomForest(HOME_TEAM_WINS~FGA+FG_PCT+FG3A+FG3_PCT+FTA+FT_PCT+OREB+DREB+AST+STL+BLK+TO+PF+PTS,data=total_data[,-c(1,2,3)])
model_team%>%importance()%>%as.data.frame()%>%arrange(desc(MeanDecreaseGini))

#分析球队的胜利贡献度（胜利贡献度指对比赛胜利的影响，胜利球队共性，因素分析）
#FGA-fg3a=2分球出手次数
#先分析球队胜率变量再筛球员变量
play_dat=merged_data%>%select(-GAME_DATE_EST,-GAME_ID,-HOME_TEAM_ID,-VISITOR_TEAM_ID,-SEASON,-PLAYER_NAME,-PLAYER_ID)%>%distinct()
play_dat$HOME_TEAM_WINS=as.factor(play_dat$HOME_TEAM_WINS)
model_play=randomForest(HOME_TEAM_WINS~.,data = play_dat)
model_play%>%importance()%>%as.data.frame()%>%arrange(desc(MeanDecreaseGini))

#时间因素
team%>%group_by(YEARFOUNDED)%>%summarise(n())
city_data <- data.frame(
  CITY = c("Atlanta", "Boston", "Brooklyn", "Charlotte", "Chicago", "Cleveland", "Dallas", 
           "Denver", "Detroit", "Golden State", "Houston", "Indiana", "Los Angeles Clippers", 
           "Los Angeles Lakers", "Memphis", "Miami", "Milwaukee", "Minnesota", "New Orleans", 
           "New York", "Oklahoma City", "Orlando", "Philadelphia", "Phoenix", "Portland", 
           "Sacramento", "San Antonio", "Toronto", "Utah", "Washington"),
  Latitude = c(33.749, 42.361, 40.678, 35.227, 41.878, 41.499, 32.776, 
               39.739, 42.331, 37.774, 29.760, 39.768, 34.052, 34.052, 
               35.149, 25.761, 43.038, 44.977, 29.951, 40.712, 35.467, 
               28.538, 39.952, 33.448, 45.505, 38.581, 29.424, 43.651, 
               40.760, 38.581),
  Longitude = c(-84.388, -71.058, -73.944, -80.843, -87.629, -81.694, -96.796, 
                -104.990, -83.046, -122.414, -95.369, -86.158, -118.244, -118.243, 
                -90.051, -80.191, -87.906, -93.265, -90.071, -74.006, -97.516, 
                -81.379, -75.165, -112.074, -122.675, -121.494, -98.493, -79.383, 
                -111.890, -77.036)  # Updated Washington longitude
)
usa <- map_data("usa")

team_win=merged_data  %>%
  group_by(HOME_TEAM_ID) %>%na.omit()%>%
  summarise(TeamWinning =sum(HOME_TEAM_WINS)/n(), TeamWins=sum(HOME_TEAM_WINS), TeamTotal=n()) %>%
  arrange(desc(TeamWinning))

# 创建地图并添加城市标记
# 创建地图并添加城市标记和标签
# 洛杉矶两个球队
# 纽约和布鲁克林共用球队
#加上胜率
team_win_final=team_win%>%inner_join(team,by=c("HOME_TEAM_ID"='TEAM_ID'))%>%select(CITY,ABBREVIATION,TeamWinning)%>%arrange(desc(TeamWinning))
team_win_final$CITY[9]=c("Los Angeles Lakers")
team_win_final$CITY[19]=c("Los Angeles Clippers")
final_data=team_win_final%>%inner_join(city_data,by=c("CITY"))
ggplot() +
  geom_polygon(data = usa, aes(x = long, y = lat, group = group), fill = "white", color = "black") +
  geom_point(data = final_data, aes(x = Longitude, y = Latitude, size = TeamWinning, alpha=TeamWinning, color = TeamWinning)) +
  scale_color_gradient(low = "green", high = "red", name = "TeamWinning")+
  geom_text_repel(data = city_data, aes(x = Longitude, y = Latitude, label = CITY), 
                  box.padding = 0.5, point.padding = 0.5, force = 0.5,
                  size = 3, vjust = -0.5) +
  theme_void() +
  theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
  labs(title = "NBA Teams' Cities in USA", caption = "Source: City data from NBA teams")


