library(shiny)
shinyUI(fluidPage(
  title = "Football App",
  sidebarLayout(
    sidebarPanel(
      h2("App explanation", align = "center"),
      p("This app uses webdata from the English, German and Spanish football competitions
        from the years 2012/2013 until 2014/2015."),
      p("It then allows the user to display the competition rankings as calculated by 
        a new scoring rule or to see whether there are outlier countries according to
        this new rule."),
      
      radioButtons(inputId = 'choice', label = "Do you want to see country rankings or outlier 
                   teams per competition",choices = list("country rankings" = "rank",
                                                             "outlier teams" = "outlier")),
      conditionalPanel(
        condition = 'input.choice === "rank"',
        # Choose the competition to be displayed
        selectInput(inputId = 'country', label = "Which competition do you want to be displayed",
                   choices = list("English competition" = "english",
                                  "Spanish competition" = "spanish",
                                  "German competition" = "german")),
        selectInput(inputId = 'season', label = 'For which years do you want to see the ranking?',
                   choices = list("Only 2014" = "2014",
                                  "Only 2013" = "2013",
                                  "Only 2012" = "2012")),
        selectInput(inputId = 'ranking', label = 'Do you want to see the old or new ranking?',
                     choices = list("new" = "new_points",
                                    "old" = "old_points",
                                    "difference" = "difference"))
        ),
      conditionalPanel(
        condition = 'input.choice === "outlier"',
        selectInput(inputId = 'country1', label = "Which competition do you want to be displayed?",
                     choices = list("England" = "english",
                                    "Spain" = "spanish",
                                    "Germany" = "german")),
        selectInput(inputId = 'season1', label = 'For which years do you want to see the outliers?',
                     choices = list("Only 2014" = "2014",
                                    "All years" = "all",
                                    "Only 2013" = "2013",
                                    "Only 2012" = "2012"))
      )
        ),
    mainPanel(
      tabsetPanel(
        tabPanel('Ranking', 
                 dataTableOutput(
                   outputId = "mytable")),
        tabPanel('Outliers', plotOutput('myPlot'))
      )
    )
  )
)
)
      