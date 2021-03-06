#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
options(shiny.maxRequestSize=30*1024^2)
#options(shiny.port="1234")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste(input$experimentID, ".pdf",sep="")
    },

    content = function(file) {
      print(input$experimentID)
      print(input$maxMissing)
      print(input$peptides)
      inFile <- input$proteinGroups
      if (is.null(inFile))
        return(NULL)
      print(inFile$datapath)


      protein <- read.table(inFile$datapath,sep="\t",stringsAsFactors = F,header=T)

      print(dim(protein))
      print(length(colnames(protein)))
      rawF <- gsub("Intensity\\.", "", grep("Intensity\\.",colnames(protein),value=T) )
      print(rawF)
      condition <- quantable::split2table(rawF)[,3]
      annotation <- data.frame(Raw.file = rawF,
                              Condition = condition,
                              BioReplicate = paste("X",1:length(condition),sep=""),
                              Run = 1:length(condition),
                              IsotopeLabelType = rep("L",length(condition)), stringsAsFactors = F)


      library(SRMService)
      # these libraries are necessairy .. added by jonas (20161101)
      library(limma)
      library(qvalue)
         
      grp2 <- Grp2Analysis(annotation, input$experimentID , maxNA=input$maxMissing  , nrPeptides=input$peptides)
      grp2$setMQProteinGroups(protein)
      # debugging. added by jonas (20161101)

      print("rendering the thing locally in working dir")
      myWD <- getwd()
      print(paste("yourWD: ", myWD, sep=""))
      out <- rmarkdown::render('../../reports/Grp2Analysis.Rmd', output_format = "pdf_document")
      file.rename(out, file)
    }
  )




})
