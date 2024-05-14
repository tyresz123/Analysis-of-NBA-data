setwd("C:\\Users\\Administrator\\Desktop\\nba")
library(tidyverse)
library(randomForest)
game=read_csv("games.csv")
game_detile=read_csv("games_details.csv")
rank=read_csv("ranking.csv")
team=read_csv("teams.csv")
player=read_csv("players.csv")
#games
game=game[,-c(3,7,14)]#比赛主客队得分
#game_detile
game_detile=game_detile[,-c(9)]#球员得分
#rank
rank=rank[,-c(13)]


#分析球员姓名和比赛结果关系(算胜率，胜场最多)
###主场
merged_data = inner_join(game, player, by = c("HOME_TEAM_ID" = "TEAM_ID"),relationship = "many-to-many")
###名字
merged_data %>%
  mutate(FirstName = map_chr(str_split(PLAYER_NAME, " "), ~ .x[1])) %>%
  group_by(FirstName) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)
###姓
merged_data %>%
  mutate(FirstName = map_chr(str_split(PLAYER_NAME, " "), ~ .x[2])) %>%
  group_by(FirstName) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)
###球员
merged_data  %>%
  group_by(PLAYER_NAME) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)

###客场

merged_data_v <- left_join(game, player, by = c("VISITOR_TEAM_ID" = "TEAM_ID"),relationship = "many-to-many")
merged_data_v %>%
  mutate(FirstName = map_chr(str_split(PLAYER_NAME, " "), ~ .x[1])) %>%
  group_by(FirstName) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS==0, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)

merged_data_v %>%
  mutate(FirstName = map_chr(str_split(PLAYER_NAME, " "), ~ .x[2])) %>%
  group_by(FirstName) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS==0, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)

merged_data_v  %>%
  group_by(PLAYER_NAME) %>%
  summarise(total_wins = sum(HOME_TEAM_WINS==0, na.rm = TRUE)) %>%
  arrange(desc(total_wins)) %>%  # 按总胜利次数降序排序
  slice(1:10)



##分析团队比赛结果因素
total_data=game_detile%>%inner_join(game,by=c("GAME_ID"),relationship = "many-to-many")
use_dat=total_data%>%select(c("TEAM_ID","FGM","FGA","FG_PCT","FG3M","FG3A","FG3_PCT","FTM","FTA","FT_PCT","OREB","DREB","REB","AST","STL","BLK","TO","PF","PTS","PLUS_MINUS","HOME_TEAM_ID","HOME_TEAM_WINS"))
use_dat2 <- use_dat %>%
  mutate(win = ifelse(TEAM_ID == HOME_TEAM_ID & HOME_TEAM_WINS == 1, 1,
                      ifelse(TEAM_ID != HOME_TEAM_ID & HOME_TEAM_WINS == 0, 1, 0)))
use_dat2=use_dat2%>%select(-c("HOME_TEAM_ID","HOME_TEAM_WINS","TEAM_ID"))
#消除多重共线性
step(lm(win ~ ., data = na.omit(use_dat2)))
#拟合逻辑回归
model1=glm(win ~ FGM + FGA + FG_PCT + FG3M + FG3A + FTM + FTA + 
             FT_PCT + OREB + DREB + AST + STL + BLK + PF + PLUS_MINUS, data = na.omit(use_dat2), family = binomial)
predicted <- ifelse(predict(model1, type = "response")>0.5,1,0)
model2=randomForest(win ~ FGM + FGA + FG_PCT + FG3M + FG3A + FTM + FTA + 
                      FT_PCT + OREB + DREB + AST + STL + BLK + PF + PLUS_MINUS, data = na.omit(use_dat2))


#分析球队的胜利贡献度（胜利贡献度指对比赛胜利的影响，胜利球队共性，因素分析）
#FGA-fg3a=2分球出手次数
#先分析球队胜率变量再筛球员变量
dat_play=game_detile[,-c(2,3,4,5,7,9)]%>%inner_join(game,by=c("GAME_ID"),relationship = "many-to-many")
dat_play=dat_play[,-c(1)]
dat_play=na.omit(dat_play)
use_dat_play=dat_play%>%select(c("START_POSITION","FGA","FG_PCT","FG3A","FG3_PCT","FTA","FT_PCT","OREB","DREB","AST","STL","BLK","TO","PF","PTS","PLUS_MINUS"))
quantile(use_dat_play$PTS,0.25)
quantile(use_dat_play$PTS,0.5)
quantile(use_dat_play$PTS,0.75)
use_dat_play$class=0
use_dat_play$class[use_dat_play$PTS>8]=1
use_dat_play$class[use_dat_play$PTS>13]=2
use_dat_play$class[use_dat_play$PTS>19]=3
use_dat_play$class=as.factor(use_dat_play$class)
use_dat_play=use_dat_play[,-c(15)]
model_p=randomForest(class~.,use_dat_play)
model_p$importance%>%as.data.frame()%>%arrange(desc(MeanDecreaseGini))
#时间因素
team%>%group_by(YEARFOUNDED)%>%summarise(n())
city_data <- data.frame(
  CITY = c("Atlanta", "Boston", "New Orleans", "Chicago", "Dallas", "Denver", "Houston",
           "Los Angeles", "Miami", "Milwaukee", "Minneapolis", "Brooklyn", 
           "New York", "Orlando", "Indianapolis", "Philadelphia", "Phoenix", "Portland", 
           "Sacramento", "San Antonio", "Oklahoma City", "Toronto", "Salt Lake City", 
           "Memphis", "Washington", "Detroit", "Charlotte", "Cleveland", "San Francisco"),
  Latitude = c(33.7490, 42.3601, 29.9511, 41.8781, 32.7767, 39.7392, 29.7604, 
               34.0522, 25.7617, 43.0389, 44.9778, 40.6782, 40.7128, 
               28.5383, 39.7684, 39.9526, 33.4484, 45.5122, 38.5816, 
               29.4241, 35.4676, 43.6511, 40.7608, 35.1495, 38.8951, 
               42.3314, 35.2271, 41.4993, 37.7749),
  Longitude = c(-84.3880, -71.0589, -90.0715, -87.6298, -96.7970, -104.9903, -95.3698, 
                -118.2437, -80.1918, -87.9065, -93.2650, -73.9442, -74.0060, 
                -81.3792, -86.1581, -75.1652, -112.0740, -122.6587, -121.4944, 
                -98.4936, -97.5164, -79.3832, -111.8910, -90.0489, -77.0369, 
                -83.0458, -80.8431, -81.6944, -122.4194)
)
usa <- map_data("usa")

# 创建地图并添加城市标记
# 创建地图并添加城市标记和标签
# 洛杉矶两个球队
# 纽约和布鲁克林共用球队
#加上胜率
ggplot() +
  geom_polygon(data = usa, aes(x = long, y = lat, group = group), fill = "white", color = "black") +
  geom_point(data = city_data, aes(x = Longitude, y = Latitude), color = "red", size = 3) +
  geom_text(data = city_data, aes(x = Longitude, y = Latitude, label = CITY), vjust = -0.5, size = 3) +
  theme_void() +
  theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
  labs(title = "NBA Teams' Cities in USA", caption = "Source: City data from NBA teams")
