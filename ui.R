# ui.R
library(shiny)

# Define UI for random distribution application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Data Products Project - Exploratory Data Analysis"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      
      sliderInput("dose", 
                  "Dose in milligrams:", 
                  value = 0.75,
                  min = 0.5, 
                  max = 2.0, 
                  step=0.05),

      br(),
      
      checkboxInput("jitter", "Jitter dosage points:", value=FALSE),
      
      checkboxInput("smoothline", "Show LM Smoothing Line:", value=FALSE),
      
      conditionalPanel(
        condition = "input.smoothline == true",
        
        checkboxInput("shadow", "Show LM confidence region:", value=FALSE)
        ),
      
      conditionalPanel(
        condition = "input.shadow == true & input.smoothline == true",        
        selectInput("confidence", 
                    "Confidence region (shaded):", 
                    choices = list('80%'=.80,'85%'=.85,'90%'=.90, '95%'=0.95, '97.5%'=0.975),
                    selected = .95) 
        ),
      
      hr(),
      p('Instructions:'),
      p('Use the controls above to help you do exploratory analysis of the data.'),
      p('When this page first opens, you will see three user control above: a slider control to enter the dose, and check boxes for plotting jitters and showing a smoothing line on the plot to the right.'),
      p("Don't be afraid to click on these controls. It's fun.  And notice the effects to the plot and the control panel you produce by clicking on the above controls."),
      p('For example, if you click on the "Show LM Smoothing Line" checkbox it will show other controls below it, as well as show you smoothing lines for OJ and VC supp on the plot.'),
      p('Calculations are made based on your inputs resulting in a plot being updated as well as the three text fields above the plot.')
    ),
    
    mainPanel(
      h3('Created by Bill Killacky 5/21/15'),
      p('The Effect of Vitamin C on Tooth Growth in Guinea Pigs.  (Using the "Tooth Growth" dataset from the R package "datasets"). Guinea pigs were grouped by treatments of three dose levels of Vitamin C (0.5, 1, and 2 mg) with each of two supplimental (supp) delivery methods (orange juice=OJ or ascorbic acid=VC).'), 
      p('We created a fitted linear model based on dose+supp with tooth length as our outcome. Tooth length prediction calculations are displayed below using a prediction on our fitted linear model and the dose you set using the slider to the left.'),
      p('Please refer to the instruction to the left.'),
      h5('You entered a mg dose of'),
      verbatimTextOutput("odose"),
      
      h5('Prediction: guinea pig tooth growth where supp=OJ:'),
      verbatimTextOutput('predOJ'),      
      
      h5('Prediction: guinea pig tooth growth where supp=VC:'),
      verbatimTextOutput('predVC'),

      plotOutput("plot"))

      ) # end sidebarLayout

    ) # end fluidPage
)
