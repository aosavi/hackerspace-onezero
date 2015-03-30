# Presentation webscraping help file

library(rvest)
url <- "http://www.tripadvisor.nl/Attraction_Review-g188590-d240813-Reviews-Heineken_Experience-Amsterdam_North_Holland_Province.html"
data <- html(url)

# sometimes it is kind of trial and error. We type in .rating_s and we get a lot of rubbish
score <- data %>%
  html_nodes(".rating_s") %>%
  html_text()

# Let's therefore zoom in of the html nodes with class rating_s
data %>%
  html_nodes(".rating_s") %>%
  .[1]

## just some test
print (paste("Hello", "world"))

# If you look closely at some of the information, you see that it is actually wrapped
# in the class "rating_s_fill", more specifically in the attribute "alt"
score <- data %>%
  html_nodes(".rating .rating_s_fill") %>%
  html_attr("alt") %>%
  gsub(" van 5 sterren", "", .) #%>%
  gsub(",",".",.) %>%
  as.numeric()


# Let's make a web crawler for trip advisor ratings
# note that the webcrawler works well for 5 pages. Then it seems that tripadvisor
# puts sort of a time out on it as it starts returning NA values.
extract_ratings = function(number, url, root_url){
  library(rvest)
  
  # empty list and vector for storage
  ratings = list()
  page_rating = NULL
  
  # page structure is a bit weird. The right link is the 3rd on the first 2 pages
  # right links after the first two pages is the 6th. So define variable struct
  struct = 3
  
  # loop until we have acquired the last link
  
  for (j in 1:number){
    
    # print the page we are on
    print (paste("Page", j, sep=" "))
    
    # if we are not on the first page we have to concatenate the relative url with 
    # the actual website
    if (j != 1){
      url <- paste(root_url,link,sep="")
    }
    
    # get the webpage by means of the url
    page <- url %>%
      html()
    
    # get the reviews of the page
    reviews <- page %>%
      html_nodes("#REVIEWS .innerBubble")
    
    # get ratings. Correct ratings are the first 10
    score <- page %>%
      html_node("#REVIEWS") %>%
      html_nodes(".rating .rating_s_fill") #%>%
      html_attr("alt") %>
      .[1:10] %>%
      gsub(" van 5 sterren", "", .) %>%
      as.numeric()
    
    # print the ratings
    print (score)
    
    
    
    # now extract the link to the next page from the root page
    # in the case of the first 2 pages
    if (j < 3){
      link <- page %>%
        html_node(".pgLinks") %>%
        html_nodes("a") %>%
        .[[struct]] %>%
        html_attr("href")
      print (link)
    }
    
    # on any subsequent pages
    else {
      link <- page %>%
        html_node(".pgLinks") %>%
        html_nodes("a") %>%
        .[[struct * 2]] %>%
        html_attr("href")
      print (link)
    }
    
    # set page rating to null again
    score = NULL
    
  }
  return (ratings)
}

# apply the function on the first tripadvisor page of the heineken experience
scores = extract_ratings(number = 7, 
                         url = "http://www.tripadvisor.nl/Attraction_Review-g188590-d240813-Reviews-Heineken_Experience-Amsterdam_North_Holland_Province.html",
                         root_url = "http://www.tripadvisor.nl")  

# unlist the scores
scores = data.frame(unlist(scores))
colnames(scores)[1] = "Rating"

# Make a histogram with distribution of scores
library(ggplot2)
table(scores$Rating)
ggplot(data = scores, aes(x = Rating)) +
  geom_histogram(aes(y=..density..),      
                 binwidth=.5,
                 colour="black", fill="white") +
  geom_density(alpha = 0.2, fill = "#FF6666")
  



# If you want you could also use the language xpath the extract the same information
score <- xpathApply(data, "//*[@class='rating_s_fill']", xmlAttrs, "alt")

xpathSApply(data, "//img[@class='rating_s_fill']")




rating <- reviews %>%
  html_node(".rating .rating_s_fill") %>%
  html_attr("alt") %>%
  gsub(" of 5 stars", "", .) %>%
  as.integer()

score <- data %>%
  html_nodes(".rating_s_fill") %>%
  html_attr("alt") %>%
  gsub(" van 5 sterren","",.) %>%
  gsub(",",".",.) %>%
  as.numeric()

# put the scores in our list
ratings[[i]] = score  


# now extract the link to the next page from the root page
link <- data %>%
  html_node(".pgLinks") %>%
  html_node("a") %>%
  html_attr("href")

}
return (ratings)
}
