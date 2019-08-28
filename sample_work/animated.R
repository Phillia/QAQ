library(tidyverse)
library(here)
library(ggrepel)
library(gganimate)

load(here("sample.rda"))
### preset theme ###
goldenScatterCAtheme <- theme(
    ## Removes main plot gray background
    panel.background = element_rect(fill = "white"),
    ## Golden rectangle plotting area (leave out for square)
    aspect.ratio = ((1 + sqrt(5))/2)^(-1),
    ## All axes changes
    axis.ticks.length = unit(0.5, "char"), # longer ticks
    ## Horizontal axis changes
    axis.line.x.top = element_line(size = 0.2), # thinner axis lines
    axis.line.x.bottom = element_line(size = 0.2), # thinner axis lines
    axis.ticks.x = element_line(size = 0.2), # thinner ticks
    axis.text.x = element_text(color = "black", size = 12),
    ## match type of axis labels and titles
    axis.title.x = element_text(size = 12,
                                margin = margin(t = 7.5, r = 0, b = 0, l = 0)),
    ## match type; pad space between title and labels
    ## Vertical axis changes
    axis.ticks.y = element_blank(), # no y axis ticks (gridlines suffice)
    axis.text.y = element_text(color = "black", size = 12,
                               margin = margin(t = 0, r = -4, b = 0, l = 0)),
    ## match type of axis labels and titles, pad
    axis.title.y = element_text(size = 12,
                                margin = margin(t = 0, r = 7.5, b = 0, l = 0)),
    ## match type of axis labels and titles, pad
    ## Legend
    legend.key = element_rect(fill = NA, color = NA),
    ## Remove unhelpful gray background
    ## Gridlines (in this case, horizontal from left axis only
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "gray45", size = 0.2),
    ## Faceting (small multiples)
    strip.background = element_blank(),
    ## Remove unhelpful trellis-like shading of titles
    strip.text.x = element_text(size=12), # Larger facet titles
    strip.text.y = element_blank(), # No titles for rows of facets
    strip.placement = "outside", # Place titles outside plot
    panel.spacing.x = unit(1.25, "lines"), # Horizontal space b/w plots
    panel.spacing.y = unit(1, "lines") # Vertical space b/w plots
)

### animated graph 1: eyeball ###
ybreaks <- c(25,50,100,200,300,500)
xbreaks <- seq(25,150,25)
popBreaks <- rev(c(3, 10, 30, 100, 300)*1000000)
dp0 <- d0 %>% select(country_code,region,pop,U5MR,E2_l5,year) %>% filter(complete.cases(.))

p <- ggplot(dp0, aes(y=U5MR, x=E2_l5, colour = factor(region), size=pop)) +
    goldenScatterCAtheme +
    geom_point(alpha = 0.55) +
    scale_y_continuous(breaks=ybreaks,labels=ybreaks) +
    scale_x_continuous(breaks = xbreaks, labels = paste0(xbreaks,"%")) +
    scale_color_brewer(palette = "Set2") +
    scale_size(breaks = popBreaks,
               labels = popBreaks/1000000,
               range = c(2, 12)) +
    labs(title = 'Year: {frame_time}', 
         x = 'Female Secondary School Enrollment Gross Ratio (lagged 5 years)', 
         y = 'Under-5 Mortality Rate (per 1,000)',
         col="Region",
         size="Population (millions)") +
    transition_time(as.integer(year)) +
    ease_aes('linear') +
    shadow_wake(wake_length = 0.1, alpha = FALSE)


anim1 <- animate(p, 100, 10,width= 800, height=400)
anim_save(here("animated1.gif"), anim1)



### animated graph 2: child mortality ###
dp1 <- d0 %>% select(year,U5MR,country_code,income_group,region) %>% filter(complete.cases(.)) %>% mutate(h=25)

p2 <- ggplot(dp1,aes(x=year,y=U5MR,group=country_code,color=income_group)) + 
    theme_minimal() +
    geom_line(size=0.35,alpha=0.7) + 
    geom_hline(yintercept =25, linetype="dashed") + 
    facet_grid(.~ region) +
    ggtitle("Country-Level Under 5 Mortality Rate Per 1,000 Live Births") +
    ylab('U5MR per 1,000') + 
    theme(legend.position = "top",
          legend.title = element_blank(),
          legend.spacing.x = unit(0.5, 'cm'),
          axis.text.x = element_text(angle = 90, hjust = 1),
          strip.text.x = element_text(size = 6),
          axis.title = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(color = "gray45", size = 0.2)) + 
    guides(color = guide_legend(override.aes = list(size=2))) + transition_reveal(year)


anim2 <- animate(p2, end_pause = 20,width=800,height=400)
anim_save(here("animated2.gif"), anim2)

