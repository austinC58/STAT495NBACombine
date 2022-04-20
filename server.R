#Packages
library(shiny)
library(shinydashboard)
library(maps)
library(dplyr)
library(leaflet)
library(ggplot2)
library(tidyverse)
library(DT)
library(plotly)
library(corrplot)
library(caret)
library(stargazer)
library(rio)

#Start server function
function(input,output,session){


#data function to take user inputs and load according csv.
  data <- eventReactive(input$load_csv, {
   as.data.frame(read.csv(paste0('C:\\Users\\austi\\Downloads\\', input$PP ,input$TS ,'.csv'), row.names = 1))
  })

  observe({
    names <- names(data())
    updateSelectInput(session = session,
                      inputId = input$DV,
                      choices = names)
  })

#Function to produce the selected data table
  output$dt <- renderDataTable({
    req(data())
    datatable(
      data()
    )}
  )

#Function to display a summary. Using stargazer package
  output$Summ <-
    renderPrint(
      stargazer(
        data(),
        type = "text",
        title = "Statistics",
        digits = 1,
        out = "table1.txt"
      )
    )

  output$Summ_old <- renderPrint(summary(data()))
  output$structure <- renderPrint(str(data()))


  #Train/Test slider
  splitSlider <- reactive({
    input$Slider1 / 100
  })





  #Function to collect the selected independent variables
  #Input_model <- reactive({

   # selData <- data()[,c(input$IV)]

  #})


  set.seed(155)  # setting seed to reproduce results of random sampling
  trainingRowIndex <-
    reactive({
      sample(1:nrow(data()),
             splitSlider() * nrow(data()))
    })

  trainingData <- reactive({
    tmptraindt <- data()
    tmptraindt[trainingRowIndex(), ]
  })

  testData <- reactive({
    tmptestdt <- data()
    tmptestdt[-trainingRowIndex(),]
  })



  output$Train <-
    renderText(paste("Train Data:", NROW(trainingData()), "records"))
  output$Test <-
    renderText(paste("Test Data:", NROW(testData()), "records"))



output$Corr <-
    renderPlot(corrplot(
      cor(data())
    ))


###Regression

lmModel <- reactive({
    req(trainingData(),input$IV,input$DV)
    current_formula <- paste0(input$DV, " ~ ", paste0(input$IV, collapse = " + "))
    current_formula <- as.formula(current_formula)
    model <- lm(current_formula, data = trainingData(), na.action=na.exclude)
    return(model)
  })


output$Model_new <- renderPrint({
    req(lmModel())
    summary(lmModel())
  })

Importance <- reactive({
    varImp(lmModel, scale = FALSE)
  })

 tmpImp <- reactive({

    imp <- as.data.frame(varImp(lmModel()))
    imp <- data.frame(overall = imp$Overall,
                      names   = rownames(imp))
    imp[order(imp$overall, decreasing = T),]

  })

  output$ImpVar <- renderPrint(tmpImp())

  price_predict <- reactive({
    predict(lmModel(), testData())
  })

  tmp <- reactive({
    tmp1 <- testData()
    tmp1[, c(input$DV)]
  })


  actuals_preds <-
    reactive({
      data.frame(cbind(actuals = tmp(), predicted = price_predict()))
    })


  Fit <-
    reactive({
      plot(actuals_preds()$actuals,
          actuals_preds()$predicted,
          pch = 16,
          cex = 1.3,
          col = "blue",
          main = "Line of Best Fit",
          xlab = "Actual",
          ylab = "Predicted"
        )
    })

  output$Prediction <- renderPlot(Fit())

  output$residualPlots <- renderPlot({
    par(mfrow = c(2, 2)) # Change the panel layout to 2 x 2
    plot(lmModel())
    par(mfrow = c(1, 1)) # Change back to 1 x 1

  })

}
