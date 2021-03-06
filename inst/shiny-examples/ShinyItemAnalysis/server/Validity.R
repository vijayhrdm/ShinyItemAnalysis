#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# VALIDITY ######
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# * CORRELATION STRUCTURE ######
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# ** Polychoric correlation matrix ######
corr_structure <- reactive({
  data <- ordinal()

  # calculate correlations depending on selected method
  if (input$type_of_corr == 'spearman') {
    corP <- cor(data, method = 'spearman', use = "pairwise.complete.obs")
  } else if (input$type_of_corr == 'pearson') {
    corP <- cor(data, method = 'pearson', use = "pairwise.complete.obs")
  } else if (input$type_of_corr == 'polychoric') {
    corP <- polychoric(data, na.rm = T)
    corP <- corP$rho
  }
  corP
})

# ** Correlation plot ######
corr_plot_Input <- reactive({
  corP <- corr_structure()
  tlcex <- max(ifelse(dim(corP)[1] < 30, 1, 0.9 - (dim(corP)[1] - 30)*0.05), 0.5)
  numclust <- input$corr_plot_clust
  clustmethod <- input$corr_plot_clustmethod

  if(!input$itemnam) {
	  dimnames(corP)[[1]] <- dimnames(corP)[[2]] <- item_names()
  }

  # option to display correlation values
  if(input$show_corr %% 2 == 1 ) {
    updateActionButton(session, "show_corr", label = "Hide correlation values")
	  if (clustmethod == "none"){
	    corrplot(corP, tl.cex = tlcex, tl.pos = 'lt', method = 'number',
	             number.cex = 0.7, col = 'black', cl.pos = 'n')
    } else {
      corrplot(corP, tl.cex = tlcex, order = "hclust", hclust.method = clustmethod,
               addrect = numclust, tl.pos = 'lt', method = 'number',
               number.cex  = 0.7, col = 'black', cl.pos = 'n')
    }
   } else {
      updateActionButton(session, "show_corr", label = "Display correlation values")
    if (clustmethod == "none"){
	    corrplot(corP, tl.cex = tlcex, tl.pos = 'lt')
	  } else {
	    corrplot(corP, tl.cex = tlcex, order = "hclust", hclust.method = clustmethod,
	             addrect = numclust, tl.pos = 'lt')
	  }
  }
})

corr_plot_Input_report <- reactive({
  corP <- corr_structure()

  tlcex <- max(ifelse(dim(corP)[1] < 30, 1, 0.9 - (dim(corP)[1] - 30)*0.05), 0.5)

  numclust <- ifelse(input$customizeCheck, input$corr_plot_clust_report, input$corr_plot_clust)
  clustmethod <- ifelse(input$customizeCheck, input$corr_plot_clustmethod_report, input$corr_plot_clustmethod)

  if(!input$itemnam) {
	  dimnames(corP)[[1]] <- dimnames(corP)[[2]] <- item_names()
  }

  # option to display correlation values
  if(input$show_corr %% 2 == 1 ) {
    updateActionButton(session, "show_corr", label = "Hide correlation values")
    if (clustmethod == "none"){
      corrplot(corP, tl.cex = tlcex, tl.pos = 'lt', method = 'number',
               number.cex = 0.7, col = 'black', cl.pos = 'n')
    } else {
      corrplot(corP, tl.cex = tlcex, order = "hclust", hclust.method = clustmethod,
               addrect = numclust, tl.pos = 'lt', method = 'number',
               number.cex  = 0.7, col = 'black', cl.pos = 'n')
    }
  } else {
    updateActionButton(session, "show_corr", label = "Display correlation values")
    if (clustmethod == "none"){
      corrplot(corP, tl.cex = tlcex, tl.pos = 'lt')
    } else {
      corrplot(corP, tl.cex = tlcex, order = "hclust", hclust.method = clustmethod,
               addrect = numclust, tl.pos = 'lt')
    }
  }
})

# ** Output correlation plot ######
output$corr_plot <- renderPlot({
  corr_plot_Input()
})

# ** DB correlation plot ######
output$DB_corr_plot <- downloadHandler(
  filename =  function() {
    paste("fig_CorrelationPlot.png", sep = "")
  },
  content = function(file) {
    # in corrplot this must be plotted completely again!
    corP <- corr_structure()
    tlcex <- max(ifelse(dim(corP)[1] < 30, 1, 0.9 - (dim(corP)[1] - 30)*0.05), 0.5)

    numclust <- input$corr_plot_clust
    clustmethod <- input$corr_plot_clustmethod

    png(file, height = setting_figures$height, width = setting_figures$height,
        units = "in",
        res = setting_figures$dpi,
        pointsize = setting_figures$dpi/72)
    if (clustmethod == "none"){
      corrplot(corP, tl.cex = tlcex)
    } else {
      corrplot(corP, tl.cex = tlcex, order = "hclust", hclust.method = clustmethod,
               addrect = numclust)
    }
    dev.off()
  }
)

# ** DB correlation matrix ######
output$corr_matrix <- downloadHandler(
	filename = function() {
		paste("Correlation_matrix", ".csv", sep = "")
	},
	content = function(file) {
	  corP <- corr_structure()
	  write.csv(corP, file)
	})

# ** Dendrogram ######
dendrogram_plot_Input <- reactive({
  corP <- corr_structure()
  dist <- as.dist(1 - corP)
  clustmethod <- input$corr_plot_clustmethod
  numclust <- input$corr_plot_clust

  hc <- hclust(dist, method = clustmethod)

  if (numclust == 1){
    order <- hc$order
    label <- if (!input$itemnam) item_names()[hc$order] else hc$label[hc$order]
    times <- length(label)
  } else {
    plot(hc)
    rhc <- rect.hclust(hc, k = numclust)
    order <- unlist(rhc)
    label <- if (!input$itemnam) item_names()[order] else names(order)
    times <- sapply(rhc, length)
  }

  df <- data.frame(label = label,
                   num = order,
                   cluster = rep(paste("Cluster", 1:numclust), times))
  dendr <- dendro_data(hc, type = "rectangle")
  if(!input$itemnam){

	dendr$labels$label <- label

  }

  dfd <- merge(dendr$labels, df, by = "label")

  ggplot() +
    geom_segment(data = segment(dendr),
                 aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_text(data = dfd,
              aes(x = x, y = y, label = label, hjust = 0, color = cluster)) +
    coord_flip() + scale_y_reverse(expand = c(0.2, 0)) +
    ylab("Height") +
    theme_app() +
    theme(axis.line.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank())
})

# ** Output dendrogram ######
output$dendrogram_plot <- renderPlot({
  dendrogram_plot_Input()
})

# ** DB dendrogram ######
output$DB_dendrogram <- downloadHandler(
  filename =  function() {
    paste("fig_Dendrogram.png", sep = "")
  },
  content = function(file) {
    ggsave(file, plot = dendrogram_plot_Input() +
             theme(text = element_text(size = setting_figures$text_size)),
           device = "png",
           height = setting_figures$height, width = setting_figures$width,
           dpi = setting_figures$dpi)
  }
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# * FACTOR ANALYSIS ######
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# ** Scree plot ######
scree_plot_Input <- reactive({
  corP <- corr_structure()

  ev <- eigen(corP)$values

  df <- data.table(pos = 1:length(ev), ev)

  ggplot(data = df, aes(x = pos, y = ev)) +
    geom_point() +
    geom_line() +
    xlab("Component number") + ylab("Eigen value") +
    scale_x_continuous(breaks = 1:length(ev), expand = c(0.01, 0.01)) +
    theme_app()
})

# ** Output scree plot ######
output$scree_plot <- renderPlot({
  scree_plot_Input()
})

# ** DB scree plot ######
output$DB_scree_plot <- downloadHandler(
  filename =  function() {
    paste("fig_ScreePlot.png", sep = "")
  },
  content = function(file) {
    ggsave(file, plot = scree_plot_Input() +
             theme(text = element_text(size = setting_figures$text_size)),
           device = "png",
           height = setting_figures$height, width = setting_figures$width,
           dpi = setting_figures$dpi)
  }
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# * PREDICTIVE VALIDITY ######
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# ** DDplot with criterion validity AKA DCplot ######
DCplot <- reactive({
  correct <- ordinal()

  difc_type <- input$DCplot_difficulty
  average.score <- (difc_type == "AVGS")

  DDplot(correct, item.names = item_numbers(),
         average.score = average.score, criterion = unlist(criterion()),
         thr = switch(input$DCplotThr_cb, "TRUE" = input$DCplotThr, "FALSE" = NULL),
         val_type = input$DCplot_validity)
})

# ** Output for Diif/Disr. plot with plotly ######
output$DCplot <- renderPlotly({
  p <- DCplot() %>%
    ggplotly(tooltip = c("item", "fill", "value", "yintercept"))

  # renaming/removing unnecessary text
  for (i in 1:2) {
    for (j in 1:length(p$x$data[[i]][["text"]])) {
      p$x$data[[i]][["text"]][j] %<>%
        str_remove_all(("parameter: |value: ")) %>%
        str_replace("item", "Item") %>%
        str_remove("(?<=\\.\\d{3}).*")

    }
    if (input$DCplotThr_cb == TRUE) {
      for (j in 1:length(p$x$data[[3]][["text"]])) {
        p$x$date[[3]][["text"]][j] %<>%
          str_replace("yintercept", "Threshold")
      }
    }
  }

  p %>% plotly::config(displayModeBar = F)
})

#** DB DC plot ######
output$DB_DCplot <- downloadHandler(
  filename =  function() {
    paste("fig_difficulty-validity_plot.png", sep = "")
  },
  content = function(file) {
    ggsave(file, plot = DCplot() +
             theme(text = element_text(size = setting_figures$text_size)),
           device = "png",
           height = setting_figures$height, width = setting_figures$width,
           dpi = setting_figures$dpi)
  }
)


# ** Validity boxplot ######
validity_plot_boxplot_Input <- reactive({
  ts <- total_score()
  cv <- unlist(criterion())

  df <- data.table(ts, cv)
  df <- df[complete.cases(df), ]

  set.seed(1)

  g <- ggplot(df, aes(y = ts, x = as.factor(cv), fill = as.factor(cv))) +
    geom_boxplot() +
    geom_jitter(shape = 16, position = position_jitter(0.2)) +
    scale_fill_brewer(palette = "Blues") +
    xlab("Criterion group") +
    ylab("Total score") +
    coord_flip() +
    theme_app()
  g
})

# ** Validity scatterplot ######
validity_plot_scatter_Input <- reactive({
  ts <- total_score()
  cv <- unlist(criterion())

  size <- as.factor(cv)
  levels(size) <- table(cv)
  size <- as.numeric(as.character(size))

  df <- data.table(ts, cv, size)
  df <- df[complete.cases(df), ]

  g <- ggplot(df, aes(y = cv, x = ts, size = size)) +
    geom_point(color = "black") +
    geom_smooth(method = lm,
                se = FALSE,
                color = "red",
                show.legend = FALSE) +
    xlab("Total score") +
    ylab("Criterion variable") +
    theme_app() +
    theme(legend.justification = c(0.99, 0.01),
          legend.position = c(0.99, 0.01))
  g
})

# ** Validity descriptive plot ######
validity_plot_Input <- reactive({
  cv <- criterion()

  ## this is fixed value to recognize discrete variable
  k <- 6
  if (length(unique(cv)) <= length(cv)/k){
    g <- validity_plot_boxplot_Input()
  } else {
    g <- validity_plot_scatter_Input()
  }
  g
})

# ** Output validity descriptive plot ######
output$validity_plot <- renderPlot({
  validity_plot_Input()
})

# ** DB validity descriptive plot ######
output$DB_validity_plot <- downloadHandler(
  filename =  function() {
    cv <- criterion()
    k <- 6
    type <- ifelse(length(unique(cv)) <= length(cv)/k, "boxplot", "scatterplot")
    paste("fig_CriterionVariable_", type, ".png", sep = "")
  },
  content = function(file) {
    ggsave(file, plot = validity_plot_Input() +
             theme(text = element_text(size = setting_figures$text_size)),
           device = "png",
           height = setting_figures$height, width = setting_figures$width,
           dpi = setting_figures$dpi)
  }
)

# ** Validity correlation table ######
validity_table_Input <- reactive({
  ts <- total_score()
  cv <- criterion()

  ct <- cor.test(ts, cv, method = "spearman", exact = F)
  tab <- c(round(ct$estimate, 2), round(ct$statistic, 2), round(ct$p.value, 3))
  names(tab) <- c(HTML("&rho;"), "S-value", "p-value")

  if (tab[3] == 0.00){
    tab[3] <- "<0.01"
  }

  tab
})

# * Output validity correlation table ######
output$validity_table <- renderTable({
  validity_table_Input()
},
include.rownames = TRUE,
include.colnames = FALSE,
sanitize.text.function = function(x) x)

# ** Interpretation ######
output$validity_table_interpretation <- renderUI({
  tab <- validity_table_Input()
  p.val <- tab["p-value"]
  rho <- tab[1]

  txt1 <- paste ("<b>", "Interpretation:","</b>")
  txt2 <- ifelse(rho > 0, "positively", "negatively")
  txt3 <- ifelse(p.val < 0.05,
                 paste("The p-value is less than 0.05, thus we reject the null hypotheses.
                       Total score and criterion variable are", txt2, "correlated."),
                 "The p-value is larger than 0.05, thus we don't reject the null hypotheses.
                 We cannot conclude that a significant correlation between total score
                 and criterion variable exists.")
  HTML(paste(txt1, txt3))
})

# ** Validity distractor text ######
output$validity_distractor_text <- renderUI({
  cv <- criterion()

  ## this is fixed value to recognize discrete variable
  k <- 6
  if (length(unique(cv)) <= length(cv)/k){
   num.group <- length(levels(as.factor(cv)))
  } else {
   num.group <- input$validity_group
  }

  txt1 <- paste('Respondents are divided into ')
  txt2 <- ifelse((length(unique(cv)) <= length(cv)/k),
                 paste("<b>", num.group, "</b> groups as it seems that criterion variable is discrete. "),
                 paste("<b>", num.group, "</b> groups by their criterion variable. "))
  txt3 <- paste ("Subsequently, we display percentage
                 of respondents in each group who selected given answer (correct answer or distractor).
                 The correct answer should be more often selected by respondents with higher values of criterion variable
                 than by those with lower values, i.e.")
  txt4 <- paste ("<b>",'solid line should be increasing.',"</b>")
  txt5 <- paste('The distractor should work in opposite direction, i.e. ')
  txt6 <- paste ("<b>",'dotted lines should be decreasing.',"<b>")
  HTML(paste(txt1, txt2, txt3, txt4, txt5, txt6))
})

# ** Admisible groups for cut ####
validity_admisible_groups <- reactive({
  cv <- criterion()
  k <- 6

  if (length(unique(cv)) <= length(cv)/k){
    groups <- length(levels(as.factor(cv)))
    validity_change_cut_indicator$discrete <- TRUE
  } else {
    cv_quant <- lapply(1:5, function(i) quantile(cv, seq(0, 1, by = 1/i), na.rm = TRUE))
    cv_quant_unique <- sapply(cv_quant, function(i) !any(duplicated(i)))
    validity_change_cut_indicator$discrete <- FALSE
    groups <- c(1:5)[cv_quant_unique]
  }

  groups
})

# ** Status of changing cut ####
validity_change_cut_indicator <- reactiveValues(change = FALSE,
                                                discrete = FALSE)

# ** Updating cut slider ####
observeEvent(!(input$validity_group %in% validity_admisible_groups()), {
  if (!(input$validity_group %in% validity_admisible_groups())){
    validity_change_cut_indicator$change <- TRUE
    c <- max(validity_admisible_groups())
    updateSliderInput(session, "validity_group", value = c)
  }
})

# ** Warning for non-unique cut ####
output$validity_groups_alert <- renderUI({
  if (validity_change_cut_indicator$change) {
    if (validity_change_cut_indicator$discrete){
      txt <- paste0('<font color = "orange">The criterion seems to be discrete. The number of groups was set to ',
                    validity_admisible_groups(), ".</font>")
    } else {
      txt <- paste0('<font color = "orange">The cut of criterion variable was not unique. The maximum number of
                    groups, for which criterion variable is unique is ', max(validity_admisible_groups()), ".</font>")
    }
  } else {
    txt <- " "
  }
  HTML(txt)
})

# ** Validity distractors plot ######
validity_distractor_plot_Input <- reactive({

  num.group <- input$validity_group

  a <- nominal()
  k <- key()
  i <- input$validitydistractorSlider
  cv <- criterion()
  multiple.answers <- c(input$type_validity_combinations_distractor == "Combinations")

  plotDistractorAnalysis(data = a, key = k, num.group = num.group,
                         item = i,
                         item.name = item_names()[i],
                         multiple.answers = multiple.answers,
                         matching = cv,
                         match.discrete = validity_change_cut_indicator$discrete)
})

# ** Output validity distractors plot ######
output$validity_distractor_plot <- renderPlot({
  validity_distractor_plot_Input()
})

# ** DB validity distractors plot ######
output$DB_validity_distractor_plot <- downloadHandler(
  filename =  function() {
    paste("fig_DistractorsValidityPlot.png", sep = "")
  },
  content = function(file) {
    ggsave(file, plot = validity_distractor_plot_Input() +
             theme(text = element_text(size = setting_figures$text_size)),
           device = "png",
           height = setting_figures$height, width = setting_figures$width,
           dpi = setting_figures$dpi)
  }
)

# ** Validity correlation table for items ######
validity_table_item_Input <- reactive({
  correct <- binary()
  cv <- criterion()
  i <- input$validitydistractorSlider

  ct <- cor.test(unlist(correct[, i, with = F]), cv, method = "spearman", exact = F)
  tab <- c(round(ct$estimate, 2), round(ct$statistic, 2), round(ct$p.value, 3))
  names(tab) <- c(HTML("&rho;"), "S-value", "p-value")
  if (tab[3] == 0.00){
    tab[3] <- "<0.01"
  }

  tab
})

# ** Output validity correlation table for items ######
output$validity_table_item <- renderTable({
  validity_table_item_Input()
},
include.rownames = TRUE,
include.colnames = FALSE,
sanitize.text.function = function(x) x)

# ** Interpretation ####
output$validity_table_item_interpretation <- renderUI({
  tab <- validity_table_item_Input()
  p.val <- tab["p-value"]
  rho <- tab[1]
  i <- input$validitydistractorSlider

  txt1 <- paste ("<b>", "Interpretation:","</b>")
  txt2 <- ifelse(rho > 0, "positively", "negatively")
  txt3 <- ifelse(p.val < 0.05,
                 paste("The p-value is less than 0.05, thus we reject the null hypotheses.
                         Scored item", i, "and criterion variable are", txt2, "correlated."),
                 paste("The p-value is larger than 0.05, thus we don't reject the null hypotheses.
                   We cannot conclude that a significant correlation between scored item", i,
                       "and criterion variable exists."))
  HTML(paste(txt1, txt3))
})

# ** Warning for missing values ####
output$corr_na_alert <- renderUI({
  txt <- na_score()
  HTML(txt)
})


