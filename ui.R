#Packages
library(shiny)
library(shinydashboard)
library(maps)
library(dplyr)
library(leaflet)
library(shinycssloaders)
library(shinythemes)
library(datadigest)
library(rio)
library(DT)
library(stargazer)

#Use dashboard package to create the page
dashboardPage(

  #title
  dashboardHeader(title = "NBA Combine Analysis"),

  #sidebar title
  dashboardSidebar(title = "Varaible Selection",

  #Button to load the selected csv
  actionButton('load_csv', 'Load csv'),

  #Check boxes for selection combine predictor variables
  checkboxGroupInput("IV",
                  h3("Independent Variables"),
                  choices = list("Height" = "NO.SHOES",
                                 "Reach" = "REACH",
                                 "Weight" = "WEIGHT",
                                 "WingSpan" = "WINGSPAN",
                                 "Sprint Drill" = "X3.4.SPRINT",
                                 "Standing Vertical" = "STD.VERT",
                                 "Max Vertical" = "MAX.VERT"),
                  selected = c("NO.SHOES", "REACH","WEIGHT","WINGSPAN","WING.DIFF","X3.4.SPRINT","STD.VERT","MAX.VERT")),

  #Button to select one dependent variable
  radioButtons("DV", h3("Dependent Variable"),
                        choices = list("Value Over Replacement" = "VORP","Box Plus-Minux"="BPM","Player Efficiency Rating" = "PER", "Offensive Box Plus-Minus" = "OBPM", "Deffensive Box Plus-Minus" = "DBPM", "Usage" = "USG.", "Offensive Rating" = "ORtg",
                                       "Defensive Rating" = "DRtg", "Field Goal %" = "FG.",
                                       "True Shooting %" = "TS.","Efftective Field Goal %" = "eFG.",
                                       "Total Rebounds per Game" = "TRB","Total Rebound %" = "TRB.", "Blocks Per Game" = "BLK.","Steals Per Game" = "STL","Win Shares" = "WS",
                                       "Win Shares per 48" = "WS.48", "Offensive Win Shares" = "OWS", "Defensive Win Shares" = "DWS"),selected = "VORP")

  #Close sidebar
  ),

  #Body of page
  dashboardBody(

    #fluid page for more selection at the top of the body
    fluidPage(
      selectInput("PP", h3("Player Position"),
                       choices = list("ALL" = "A", "Guard/Wing" = "G",
                                      "Foward/Center" = "B"), selected = 1),

      selectInput("TS", h3("Time Span"),
                       choices = list("Career" = "Career", "First 5 Years" = "5Year",
                                      "Rookie Season" = "Rookie"), selected = 1),
      sliderInput(
      "Slider1",
      label = h3("Train/Test Split %"),
      min = 0,
      max = 100,
      value = 75
      )
  ),#close fluid page

  #New fluid page for rest of content separated into tabs
  fluidPage(
    tabBox(
      id = "tabset1",
      height = "1000px",
      width = 12,

  tabPanel("Data",
               box(withSpinner(dataTableOutput('dt')), width = 12)
           ),

  tabPanel("Data Summary",
        box(withSpinner(verbatimTextOutput("Summ")), width = 6),
        box(withSpinner(verbatimTextOutput("Summ_old")), width = 6),
        box(withSpinner(verbatimTextOutput("structure")), width = 12)
      ),
  tabPanel("Plots",
               box(withSpinner(plotOutput(
                 "Corr"
               )), width = 12)),

  tabPanel("Model",

        box(
           withSpinner(verbatimTextOutput("Model_new")),
           width = 6,
           title = "Model Summary"
         ),

        box(
          withSpinner(verbatimTextOutput("ImpVar")),
          width = 5,
          title = "Variable Importance"
        )
      ),

    tabPanel(
        "Prediction",
        box(withSpinner(plotOutput("Prediction")), width = 6, title = "Line of Best Fit"),
        box(withSpinner(plotOutput("residualPlots")), width = 6, title = "Diagnostic Plots")
      )
  )

  )
)

)



