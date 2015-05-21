# server.R

library(shiny)
library(datasets)  # datasets Author: R Core Team and contributors worldwide
library(ggplot2)

ui_smooth_line <- TRUE
uismoothShadedCR <- TRUE

tgAll <- ToothGrowth
set.seed(52315)
fitAll <- lm(len~dose+supp, data=tgAll)

uismoothing <- 'lm'
uiloess <- FALSE
uicrlevel <- .90

shinyServer(function(input, output) {
  
  # Generate a plot of the data. Also uses the inputs to build
  # the plot label. Note that the dependencies on both the inputs
  # and the data reactive expression are both tracked, and
  # all expressions are called in the sequence implied by the
  # dependency graph
  
  # pass variables from the subroutine environment to this environment
  myShiny.env <- environment()
  
  output$plot <- renderPlot({
    p <- myGpig(input$dose, input$confidence, input$shadow, input$smoothline, input$jitter)
    predVC <- get('predVC', envir=myShiny.env)
    predOJ <- get('predOJ', envir=myShiny.env)
    output$predVC <- renderPrint({ round(predVC, 2) })
    output$predOJ <- renderPrint({ round(predOJ, 2) })
    output$odose <- renderPrint({ input$dose})
    p
  })

 #-------------------------------------------------------------------------
 #  function to perform Calculations based on user inputs
 #------------------------------------------------------------------------- 
    myGpig <- function(ui_dose, ui_confidence, ui_shadow, ui_smooth_line, ui_jitter) {    
      #------- start of render plot ------------
      uicrlevel <- as.numeric(ui_confidence)
      uismoothShadedCR <- ui_shadow
      #-------------------------- plot -----
      set.seed(52315)
      predmeVC <- data.frame(dose=ui_dose, supp='VC')
      predmeOJ <- data.frame(dose=ui_dose, supp='OJ')
      #
      # predict tooth length given supp and dose
      #
      predVC <- as.numeric(predict(fitAll, predmeVC))
      predOJ <- as.numeric(predict(fitAll, predmeOJ))
      
      # pass two variables back to the environment outside of this subroutine
      assign('predVC', predVC, envir=myShiny.env)
      assign('predOJ', predOJ, envir=myShiny.env)
      
      p <- ggplot(tgAll, aes(dose, len, color=supp))    
      p <- p + annotate("text", x=1.65, y=10, label =paste('For dose:', round(ui_dose, 2)))
      p <- p + annotate("text", x=1.65, y=8.75, label =paste('lm predicted OJ:',round(predOJ, 2)))
      p <- p + annotate("text", x=1.65, y=7.5, label =paste('lm predicted VC:', round(predVC, 2)))
      p <- p + geom_vline(xintercept=ui_dose, col='darkgrey', lwd=1)
      p <- p + geom_hline(yintercept=predVC, col='darkgrey', lwd=1)
      p <- p + geom_hline(yintercept=predOJ, col='darkgrey', lwd=1)
      p <- p + geom_point(shape=19)
      if (ui_jitter == TRUE) {
        p <- p + geom_point(position=position_jitter(width=0.2), alpha=0.4)
      }

      
      # smoothing choices
      if (ui_smooth_line == TRUE) {
        if (uismoothShadedCR ==  TRUE) {
          p <- p + annotate("text", x=1.65, y=5, label=paste("Smoothing confidence:", uicrlevel))
        }
        
        if (uiloess == TRUE) {
          p <- p + annotate("text", x=1.65, y=6.25, label=paste('Loess smoothing'))
        } else {
          p <- p + annotate("text", x=1.65, y=6.25, label=paste('LM smoothing'))
        }
        
        if (uismoothShadedCR == TRUE) {
          if (uiloess == TRUE) {
            p <- p + geom_smooth(method=loess, level=uicrlevel)  # defaults to loess (locally weighted polynomial curve)
          } else {
            p <- p + geom_smooth(method=lm, level=uicrlevel) # add linear regression line (95% confidence region)
          }
        } else {
          if (uiloess == TRUE) {
            p <- p + geom_smooth(method=loess, se=FALSE, level=uicrlevel)  # defaults to loess (locally weighted polynomial curve)
          } else {
            p <- p + geom_smooth(method=lm, se=FALSE, level=uicrlevel) # add linear regression line (unshaded 95% confidence region)
          }
        }        
      } # end of ui_smooth_line == TRUE  
      p <- p + ggtitle('Tooth Growth with Different Treatments')
      #-------------------------- plot -----
    }
 #-------------------------------------------------------------------------
  
})