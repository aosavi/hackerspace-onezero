retrieve_competition = function(url, num_teams){
  # load libraries
  library(rvest)
  
  spanish_league <- html(url)
  
  teams = spanish_league %>%
    html_nodes(".team") %>%
    html_text() %>%
    .[2:(num_teams + 1)]
  
  dataframe = spanish_league %>%
    html_node("table") %>%
    html_table()
  
  column_names = spanish_league %>%
    html_nodes(".cw") %>%
    html_text() %>%
    .[3:18] %>%
    c("GD","Pt")
  
  # doing some data editting. Remove rowsnames and first 2 rows
  dataframe = dataframe[-c(1,2),]
  rownames(dataframe) = NULL
  
  # remove colnames and redundant columns
  #ncol(dataframe)
  colnames(dataframe) = NULL
  dataframe = dataframe[,-c(22,25,26)] # do this sequentially
  dataframe = dataframe[,-c(1,2,4,10,16)]
    
  # making columns numeric
  dataframe = apply(dataframe,2,function(x) as.numeric(x))
  dataframe = as.data.frame(dataframe)
  
  # setting new rownames and column names
  rownames(dataframe) = teams
  colnames(dataframe) = column_names
  
  # make Total home and away games
  sum_home_games = NULL
  for (i in 1:nrow(dataframe)){
    sum_home_games[i] = dataframe[i,7] + dataframe[i,8] + dataframe[i,9]
  }
  
  sum_away_games = NULL
  for (i in 1:nrow(dataframe)){
    sum_away_games[i] = dataframe[i,12] + dataframe[i,13] + dataframe[i, 14]
  }
  dataframe$total_home = sum_home_games
  dataframe$total_away = sum_away_games
  
  ## Total possible points home and away
  # so use column 19 and 20
  pos_home_point = NULL
  for (i in 1:nrow(dataframe)){
    pos_home_point[i] = dataframe[i,19] * 3  
  }
  dataframe$pos_home_point = pos_home_point
  
  pos_away_point = NULL
  for (i in 1:nrow(dataframe)){
    pos_away_point[i] = dataframe[i,20] * 3
  }
  dataframe$pos_away_point = pos_away_point
  
  ## Actual obtained points
  ac_points_home = NULL
  for (i in 1:nrow(dataframe)){
    ac_points_home[i] = (dataframe[i,7] * 3) + (dataframe[i,8] * 1) + (dataframe[i,9] * 0)
  }
  
  # attach actual points home back to dataframe
  dataframe$ac_points_home = ac_points_home
  
  # actual points away
  ac_points_away = NULL
  for (i in 1:nrow(dataframe)){
    ac_points_away[i] = (dataframe[i,12] * 3) + (dataframe[i,13] * 1) + (dataframe[i, 14] * 0)
  }
  dataframe$ac_points_away = ac_points_away
  
  ## Proportions of obtained points
  prop_home_point = NULL
  
  for (i in 1:nrow(dataframe)){
    prop_home_point[i] = dataframe[i,23] / dataframe[i,21]
  }
  
  dataframe$prop_home_point = prop_home_point
  
  prop_away_point = NULL
  
  for (i in 1:nrow(dataframe)){
    prop_away_point[i] = dataframe[i,24] / dataframe[i,22]
  }
  
  dataframe$prop_away_point = prop_away_point
  
  return (dataframe)
}

# Get data frames for league 2012-2014
data_spanish_2013 = retrieve_competition("http://www.statto.com/football/stats/spain/primera-liga/2013-2014/table", 20)
data_spanish_2012 = retrieve_competition("http://www.statto.com/football/stats/spain/primera-liga/2012-2013/table", 20)
data_english_2013 = retrieve_competition("http://www.statto.com/football/stats/england/premier-league/2013-2014/table", 20)
data_english_2012 = retrieve_competition("http://www.statto.com/football/stats/england/premier-league/2012-2013/table", 20)
data_german_2013 = retrieve_competition("http://www.statto.com/football/stats/germany/bundesliga/2013-2014/table", 18)
data_german_2012 = retrieve_competition("http://www.statto.com/football/stats/germany/bundesliga/2012-2013/table", 18)

# Get data frames for the competitions
data_spanish_2014 = retrieve_competition("http://www.statto.com/football/stats/spain/primera-liga/2014-2015/table", 20)  
data_english_2014 = retrieve_competition("http://www.statto.com/football/stats/england/premier-league/2014-2015/table", 20)   
data_german_2014 = retrieve_competition("http://www.statto.com/football/stats/germany/bundesliga/2014-2015/table", 18)

## Average Spanish
av_spanish_home_points = mean(data_spanish$ac_points_home) # 11.4 points on average from home games
av_spanish_away_points = mean(data_spanish$ac_points_away) # 9.15 points on average from away games

#### Illustration that clubs get more points from home than from away games
## Average English
(av_english_home_points = mean(data_english_2014$ac_points_home)) # 16.8
(av_english_away_points = mean(data_english_2014$ac_points_away)) # 11.7

## Average German
(av_german_home_points = mean(data_german_2014$ac_points_home)) # 14.22
(av_german_away_points = mean(data_german_2014$ac_points_away)) # 8.88

## Now let's make a simulation. What are the amount of points that away wins needs
## to get in order to get the same points on average as home wins. THe simulation
## uses the dataframe test  

away_point_setter = function(points_away, update, margin, dataframe){
    
    # get means from total points away and total points home
    tot_points_away = mean(dataframe$ac_points_away)
    tot_points_home = mean(dataframe$ac_points_home)
    
    # not converged at True
    not_converged = TRUE
    points_away_sim = NULL
    
    # as long as we're not converged we update amount of points for an away game
    while (not_converged){
      if (abs(tot_points_home - tot_points_away) > margin)
      {
        for (i in 1:nrow(dataframe))
        {
          points_away_sim[i] = dataframe[i, 12] * points_away + dataframe[i, 13] * 1 + dataframe[i, 14] * 0
        }
        tot_points_away = mean(points_away_sim)
        points_away = points_away + update
      }
      else
      {
        not_converged = FALSE
      }
    }
    return (c(points_away, points_away_sim))
}

## Spanish
# Spanish competition 2014
new_score_spanish_2014 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_spanish_2014) # 3.87 points
out_points_spanish_2014 = new_score_spanish_2014[1]

# spanish 2013
new_score_spanish_2013 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_spanish_2013) # 3.87 points
out_points_spanish_2013 = new_score_spanish_2013[1]

# spanish 2012
new_score_spanish_2012 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_spanish_2012)
out_points_spanish_2012 = new_score_spanish_2012[1]

## English competition
# English 2014
new_score_english_2014 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_english_2014)
out_points_english_2014 = new_score_english_2014[1]

# English 2013
new_score_english_2013 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_english_2013)
out_points_english_2013 = new_score_english_2013[1]

# English 2012
new_score_english_2012 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_english_2012)
out_points_english_2012 = new_score_english_2012[1]

## Germany competition
# Germany 2014
new_score_german_2014 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_german_2014)
out_points_german_2014 = new_score_german_2014[1]

# Germany 2013
new_score_german_2013 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_german_2013)
out_points_german_2013 = new_score_german_2013[1]

# Germany 2012
new_score_german_2012 = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_german_2012)
out_points_german_2012 = new_score_german_2012[1]

### Now lets weight all these scores. 
# Competitions with 20 teams have 38 rounds. 10 matches per round so: 380 matches
# Competitions with 18 teams have 36 rounds. 9 matches per round so: 324 matches
weighted_out_points = ((out_points_spanish_2014 * 380) + (out_points_spanish_2013 * 380) + 
  (out_points_spanish_2012 * 380) + (out_points_english_2014 * 380) + (out_points_english_2013 * 380) +
  (out_points_english_2012 * 380) + (out_points_german_2014 * 324) + (out_points_german_2013 * 324) +
  (out_points_german_2012 * 324)) / ((380 * 6) + (324 * 3))

# 4.609

### What would be the total amount of points acquired by football teams under the new rule?
new_points_alg = function(competition, away_points, number_teams, name){
  new_out_score = NULL
  for (i in 1:nrow(competition)){
    new_out_score[i] =  ((competition[i,12] * away_points) + (competition[i,13] * 1) + 
      (competition[i,7] * 3) + (competition[i,8] * 1))
  }
  
  new_data = data.frame(competition[,18],new_out_score, type = rep(paste(name), times = number_teams))
  rownames(new_data) = rownames(competition)
  colnames(new_data) = c('old_points', 'new_points', 'type')
  return(new_data)
}

### Apply algorithm on all datasets
# Spanish
competition_spanish_2014 = new_points_alg(data_spanish_2014, weighted_out_points, 20, "spanish_2014")
competition_spanish_2013 = new_points_alg(data_spanish_2013, weighted_out_points, 20, "spanish_2013")
competition_spanish_2012 = new_points_alg(data_spanish_2012, weighted_out_points, 20, "spanish_2012")
# English
competition_english_2014 = new_points_alg(data_english_2014, weighted_out_points, 20, "english_2014")
competition_english_2013 = new_points_alg(data_english_2013, weighted_out_points, 20, "english_2013")
competition_english_2012 = new_points_alg(data_english_2012, weighted_out_points, 20, "english_2012")
# German
competition_german_2014 = new_points_alg(data_german_2014, weighted_out_points, 18, "german_2014")
competition_german_2013 = new_points_alg(data_german_2013, weighted_out_points, 18, "german_2013")
competition_german_2012 = new_points_alg(data_german_2012, weighted_out_points, 18, "german_2012")

## Put it all in 1 csv file. THis can be used in the app
total_data = rbind(competition_spanish_2014, competition_spanish_2013, competition_spanish_2012,
                   competition_english_2014, competition_english_2013, competition_english_2012,
                   competition_german_2014, competition_german_2013, competition_german_2012, deparse.level = 2)

write.csv(total_data, file = "competition_points.csv", row.names = TRUE, quote = FALSE)

## Take 
data1_spanish_2014 = data.frame(teams = rownames(data_spanish_2014), 
                                home_points = data_spanish_2014$ac_points_home, 
                                away_points = data_spanish_2014$ac_points_away,
                                league = rep("data_spanish_2014", times = 20))
data1_spanish_2013 = data.frame(teams = rownames(data_spanish_2013), 
                                home_points = data_spanish_2013$ac_points_home, 
                                away_points = data_spanish_2013$ac_points_away,
                                league = rep("data_spanish_2013", times = 20))
data1_spanish_2012 = data.frame(teams = rownames(data_spanish_2012), 
                                home_points = data_spanish_2012$ac_points_home, 
                                away_points = data_spanish_2012$ac_points_away,
                                league = rep("data_spanish_2012", times = 20))
data1_english_2014 = data.frame(teams = rownames(data_english_2014), 
                                home_points = data_english_2014$ac_points_home, 
                                away_points = data_english_2014$ac_points_away,
                                league = rep("data_english_2014", times = 20))
data_english_2013 = data.frame(teams = rownames(data_english_2013), 
                               home_points = data_english_2013$ac_points_home, 
                               away_points = data_english_2013$ac_points_away,
                               league = rep("data_english_2013", times = 20))
data_english_2012 = data.frame(teams = rownames(data_english_2012), 
                               home_points = data_english_2012$ac_points_home, 
                               away_points = data_english_2012$ac_points_away,
                               league = rep("data_english_2012", times = 20))
data_german_2014 = data.frame(teams = rownames(data_german_2014), 
                              home_points = data_german_2014$ac_points_home, 
                              away_points = data_german_2014$ac_points_away,
                              league = rep("data_german_2014", times = 18))
data_german_2013 = data.frame(teams = rownames(data_german_2013), 
                              home_points = data_german_2013$ac_points_home, 
                              away_points = data_german_2013$ac_points_away,
                              league = rep("data_german_2013", times = 18))
data_german_2012 = data.frame(teams = rownames(data_german_2012), 
                              home_points = data_german_2012$ac_points_home, 
                              away_points = data_german_2012$ac_points_away,
                              league = rep("data_german_2012", times = 18))
tot_data = rbind(data1_spanish_2014, data1_spanish_2013, data1_spanish_2012,
                 data1_english_2014, data_english_2013, data_english_2012,
                 data_german_2014, data_german_2013, data_german_2012)

## write this file to a CSV file
write.csv(tot_data, file = "outlier_points.csv", row.names = FALSE, quote = FALSE)
                 
# Get data frames for the competitions
data_spanish_2014  
data_english_2014   
data_german_2014
# now plot it
library(ggplot2)
ggplot(data = data_spanish_2014, aes(x = ac_points_home, y = ac_points_away, label = rownames(data_spanish_2014))) + 
  geom_point() +
  geom_text(size = 3) +
  geom_abline(intercept = 0, slope = 1) +
  ylab("points away") + xlab("home points") +
  theme_bw()

## Ranking based on new scoring rule
new_ranking_spanish = data_spanish$spanish_away_points + data_spanish$ac_points_home
new_ranking_spanish = rank(-new_ranking_spanish)

(new_spanish = data.frame(teams = rownames(data_spanish), old_ranking = 1:20,
                         new_ranking = new_ranking_spanish))

# English competition
new_score_english = away_point_setter(points_away = 3, update = 0.01, margin = 0.05, data_english)
out_points_english = new_score_english[1]
english_away_points = new_score_english[2:21]
data_english$english_away_points = english_away_points

# now plot it
ggplot(data = data_english, aes(x = ac_points_home, y = english_away_points, label = rownames(data_english))) +
  geom_point() +
  geom_text(size = 3) +
  geom_abline(intercept = 0, slope = 1) +
  ylab("points away") + xlab("home points") +
  theme_bw()

## Ranking based on new scoring rule
new_ranking_english = data_english$english_away_points + data_english$ac_points_home
new_ranking_english = rank(-new_ranking_english)

new_english = data.frame(teams = rownames(data_english), old_ranking = 1:20,
                        new_ranking = new_ranking_english)

# German competition 
new_score_german = away_point_setter(points_away = 3, update= 0.01, margin = 0.05, data_german)
out_points_german = new_score_german[1]
german_away_points = new_score_german[2:19]
data_german$german_away_points = german_away_points

# now plot it
ggplot(data = data_german, aes(x = ac_points_home, y = german_away_points, label = rownames(data_german))) +
  geom_point() + 
  geom_text(size = 3) +
  geom_abline(intercept = 0, slope = 1) +
  ylab("points away") + xlab("home points") +
  theme_bw()

## Ranking based on new scoring rule
new_ranking_german = data_german$german_away_points + data_german$ac_points_home
new_ranking_german = rank(-new_ranking)

new_german = data.frame(teams = rownames(data_german), old_ranking = 1:18,
                         new_ranking = new_ranking_german)

### Get data from other seasons as well. 2013-2014 and 2012-2013
## Spanish
data_spanish_2013 = retrieve_competition("http://www.statto.com/football/stats/spain/primera-liga/2013-2014", 20)
data_spanish_2012 = retrieve_competition("http://www.statto.com/football/stats/spain/primera-liga/2012-2013/table", 20)

## English
data_english_2013 = retrieve_competition("http://www.statto.com/football/stats/england/premier-league/2013-2014", 20)
data_english_2012 = retrieve_competition("http://www.statto.com/football/stats/england/premier-league/2012-2013", 20)

### German
data_german_2013 = retrieve_competition("http://www.statto.com/football/stats/germany/bundesliga/2013-2014", 18)
data_german_2012 = retrieve_competition("http://www.statto.com/football/stats/germany/bundesliga/2012-2013/table", 18)

