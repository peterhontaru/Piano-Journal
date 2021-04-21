---
    output:
      html_document:
 
        toc: true
        toc_float: false
        toc_depth: 2
        number_sections: true
        
        code_folding: hide
        code_download: true
        
        fig_width: 15 
        fig_height: 6
        fig_align: "center"
        
        highlight: pygments
        theme: cerulean
        
        keep_md: true
        
    title: "Human Learning meets Machine Learning"
    subtitle: "1,200+ hours of piano practice"
    author: "by Peter Hontaru"
---

# Introduction

## What am I hoping to achieve with this project?

* predict how long it will take to learn a piece based on various features
* discover insights into my practice habits and find areas where I need to improve
* develop a recommender tool of piano pieces for others to select from based on factors of interest
* hopefully act as a source of inspiration/realistic piano progress for others who want to learn a musical instrument

**Context**: I started playing the piano in 2018 as a complete beginner and I've been tracking my practice time for around 2 and a half years. I now decided to put that to good use and see what interesting patterns I might be able to find.

## Data collection

* imputed conservative estimations for the first 10 months of the first year (Jan '18 to Oct '18)
* everything from Dec '18 onwards was tracked using Toggl, a time-tracking app/tool
* these times include my practice sessions (usually in short bouts of 30 minutes); piano lessons are excluded (usually 2-3 hours total per month)
* the **Extract, Transform, Load** script is available in the global.R file of this repo

**Disclaimer**: I am not affiliated with Toggl. I started using it a few years ago because it provided all the functionality I needed and loved its minimalistic design. The standard membership, which I use, is free of charge.

# Key insights

## Summary:

* identified various trends in average daily practice session, time of year, etc
* pieces could take me anywhere from around 4 hours to 40+ hours, subject to difficulty (as assessed by the ABRSM grade)
* the Random Forrest model was shown to be the most optimal model
  - **Rsquared** (0.585)
  - **MAE** - 5.9 hours 
  - **RMSE** - 7.5 hours
  * Looking at the variability of errors, there is still a tendency to over-predict for pieces that took very little and under-predict for the more difficult ones. There could be two main reasons for this:
    * practicing an old piece in order to further improve (which naturally adds more practice time as I re-learn it)
    * learning easier pieces later on in my journey which means I will learn them faster than expected (based on my earlier data where a piece of a similar difficulty took longer)
* the most important variables were shown to be the number of **length of the piece**, **standard of playing** (performance vs casual) and **experience**(cumulative hours before first practice session on each piece)


```r
knitr::opts_chunk$set(
    echo = FALSE, # show all of the code
    tidy = FALSE, # cleaner code printing
    size = "small", # smaller code
    
    fig.path = "figs/",# where the figures will end up
    out.width = "100%",

    message = FALSE,
    warning = FALSE
    )
```



# Exploratory Data Analysis (EDA)

## Piano practice timeline

<img src="figs/unnamed-chunk-3-1.png" width="100%" />

## How long did I practice per piece?

Based on the level at the time and the difficulty of the piece, we can see that each piece took around 10-30 hours of practice.

<img src="figs/timeline-1.gif" width="100%" />

## How consistent was my practice?

Generally, I've done pretty well to maintain a high level of consistency with the exception of August/December. This is usually where I tend to take annual leave.

<img src="figs/unnamed-chunk-4-1.png" width="100%" />

## Was there a trend in my amount of daily average practice? {.tabset .tabset-fade .tabset-pills}

We can see that my practice time was correlated with the consistency, where the average session was much shorter in the months I was away from the piano. There's also a trend where my practice close to an exam session was significantly higher than any other time of the year. **Can you spot in which month I had my exam in 2019? What about the end of 2020?**

*average practice length per month includes the days in which I did not practice*

### overall {-}

<img src="figs/unnamed-chunk-5-1.png" width="100%" />

### Year on Year {-}

Similar trends as before are apparent where my average daily session is longer before the exams than any other time in the year and a dip in the months where I usually take most of my annual leave. I really do need to start picking up the pace and get back to where I used to be.

<img src="figs/unnamed-chunk-6-1.png" width="100%" />

## Did COVID significantly impact my practice time? {.tabset .tabset-fade .tabset-pills}

### graph {-}

Despite a similar median, we can see that the practice sessions were less likely to be over 80 min after COVID. We can test if this was a significant impact with a t-test.

<img src="figs/unnamed-chunk-7-1.png" width="100%" />

### skewness assumption {-}

Given the extremely low p-value, the Shapiro-Wilk normality test implies that the distribution of the data is significantly different from a normal distribution and that we cannot assume the normality. However, we're working with the entire population dataset for each class and thus, unlike the independence of data, this assumption is not crucial.
  
<table class=" lightable-paper lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Shapiro-Wilk normality test</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> group </th>
   <th style="text-align:right;"> statistic </th>
   <th style="text-align:right;"> p.value </th>
   <th style="text-align:left;"> method </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> After COVID </td>
   <td style="text-align:right;"> 0.9607325 </td>
   <td style="text-align:right;"> 3e-07 </td>
   <td style="text-align:left;"> Shapiro-Wilk normality test </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Before COVID </td>
   <td style="text-align:right;"> 0.9549818 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:left;"> Shapiro-Wilk normality test </td>
  </tr>
</tbody>
</table>

### equal variances assumption {-}

We can see that with a large p value, we should fail to reject the Null hypothesis (Ho) and conclude that we do not have evidence to believe that population variances are not equal and use the equal variances assumption for our t test

<table class=" lightable-paper lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Levene's test</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> statistic </th>
   <th style="text-align:right;"> p.value </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> df.residual </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0410026 </td>
   <td style="text-align:right;"> 0.8395891 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 732 </td>
  </tr>
</tbody>
</table>

### t-test {-}

My practice sessions post-COVID are significantly shorter than those before the pandemic. This might be surprising, given that we were in the lockdown most of the time. However, I've been spending my time doing a few other things such as improving my technical skillset with R (this analysis wouldn't have been possible otherwise) and learning italian.

<table class=" lightable-paper lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:left;"> .y. </th>
   <th style="text-align:left;"> group1 </th>
   <th style="text-align:left;"> group2 </th>
   <th style="text-align:right;"> n1 </th>
   <th style="text-align:right;"> n2 </th>
   <th style="text-align:right;"> statistic </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> p </th>
   <th style="text-align:left;"> p.signif </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Duration </td>
   <td style="text-align:left;"> Before COVID </td>
   <td style="text-align:left;"> After COVID </td>
   <td style="text-align:right;"> 433 </td>
   <td style="text-align:right;"> 301 </td>
   <td style="text-align:right;"> 3.319481 </td>
   <td style="text-align:right;"> 732 </td>
   <td style="text-align:right;"> 0.000947 </td>
   <td style="text-align:left;"> *** </td>
  </tr>
</tbody>
</table>

## What type of music do I tend to play? {.tabset .tabset-fade .tabset-pills}

### by genre {-}

<img src="figs/unnamed-chunk-11-1.png" width="100%" />

### by composer {-}

<img src="figs/unnamed-chunk-12-1.png" width="100%" />

### by piece {-}

<img src="figs/unnamed-chunk-13-1.png" width="100%" />

## Relation between difficulty and number of practice hours {.tabset .tabset-fade .tabset-pills}

### ABRSM grade {-}

Simplified, ABBRSM grades are a group of 8 exams based on their difficulty (1 - beginner to 8 - advanced). There are also diploma grades but those are extremely advanced, equivalent to university level studies and out of the scope of this analysis. 

More information can be found on their official website at https://gb.abrsm.org/en/exam-support/your-guide-to-abrsm-exams/

<img src="figs/unnamed-chunk-14-1.png" width="100%" />

### level {-}

A further aggregation of ABRSM grades; this is helpful given the very limited dataset within each grade and much easier on the eye. This is an oversimplification but they're classified as:
  * 1-5: Beginner (1)
  * 5-6: Intermediate (2)
  * 7-8: Advanced (3)

<img src="figs/unnamed-chunk-15-1.png" width="100%" />

## What about the piece length?

<img src="figs/unnamed-chunk-16-1.png" width="100%" />

## Learning effect - do pieces of the same difficulty become easier to learn with time?

We can spot a trend where the time required to learn a piece of a similar difficulty (ABRSM Grade) decreases as my ability to play the piano increases (as judged by cumulative hours of practice). We should keep this in mind and include it as a variable into our prediction model.

<img src="figs/unnamed-chunk-17-1.png" width="100%" />

## Does "pausing" a piece impact the total time required to learn it?

How do we differentiate between pieces that we learn once and those that we come back to repeatedly? Examples could include wanting to improve the playing further, loving it so much we wanted to relearn it, preparing it for a new performance, etc.

As anyone that ever played the piano knows, re-learning a piece, particularly after you "drop" it for a few months/years, results in a much better performance/understanding of the piece. I definitely found that to be true in my experience, particularly with my exam pieces.The downside is that these pieces take longer to learn.

<img src="figs/unnamed-chunk-18-1.png" width="100%" />

## Repertoire

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:450px; "><table class=" lightable-paper lightable-striped lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Repertoire</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Project </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Duration </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Genre </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ABRSM </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Level </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Standard </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Length </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Experience </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Break </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Started </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Elton John - Rocket man </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 47 </td>
   <td style="text-align:left;"> Modern </td>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 4.0 </td>
   <td style="text-align:right;"> 1130 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-12-08 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Träumerei </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 14 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 3.0 </td>
   <td style="text-align:right;"> 1087 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-11-09 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Mozart - Allegro (3rd movement) K282 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 28 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 1081 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2020-11-05 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Ibert - Sérénade sur l’eau </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 10 </td>
   <td style="text-align:left;"> Modern </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 1038 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-09-24 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Kuhlau - Rondo Vivace </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 24 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.2 </td>
   <td style="text-align:right;"> 1014 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-08-03 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> C. Hartmann - The little ballerina </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 21 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 998 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-07-14 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Lalling Melody </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 5 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:right;"> 981 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-06-28 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Melody </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 4 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 972 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-06-20 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 2 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 3 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 952 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-06-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 3 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 20 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 952 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-06-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Waltz in Fm </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 27 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 895 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2020-04-18 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 1 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 30 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.7 </td>
   <td style="text-align:right;"> 877 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-04-07 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Kinderszenen 1 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 10 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 855 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-03-25 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Prelude in G from Cello Suite No 1 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 25 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.5 </td>
   <td style="text-align:right;"> 788 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-02-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Georg Böhm - Minuet in G </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 7 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 1.0 </td>
   <td style="text-align:right;"> 780 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2020-01-27 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Invention 4 in Dm </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 21 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 777 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-01-25 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Contredanse in Gb </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 23 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.2 </td>
   <td style="text-align:right;"> 762 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-01-16 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in Gm - 115 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 7 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:right;"> 750 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2020-01-07 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in G - 114 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 4 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 726 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2019-12-06 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Elton John - Your song (Arr Cornick) </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 36 </td>
   <td style="text-align:left;"> Modern </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 3.3 </td>
   <td style="text-align:right;"> 713 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2019-11-21 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Poulenc - Valse Tyrolienne </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 17 </td>
   <td style="text-align:left;"> Modern </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 562 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2019-09-02 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Prelude in Cm - 934 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 25 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.4 </td>
   <td style="text-align:right;"> 536 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2019-08-15 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Volksliedchen </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 10 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 1.8 </td>
   <td style="text-align:right;"> 501 </td>
   <td style="text-align:left;"> No </td>
   <td style="text-align:left;"> 2019-07-01 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Haydn - Andante in A </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 39 </td>
   <td style="text-align:left;"> Classical </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.8 </td>
   <td style="text-align:right;"> 468 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2019-06-08 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Remembrance </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 34 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.2 </td>
   <td style="text-align:right;"> 422 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2019-04-28 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in G - 116 </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 8 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Average </td>
   <td style="text-align:right;"> 2.0 </td>
   <td style="text-align:right;"> 361 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2019-03-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Invention 1 in C </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 27 </td>
   <td style="text-align:left;"> Baroque </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 1.7 </td>
   <td style="text-align:right;"> 350 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2019-02-22 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Waltz in Am </td>
   <td style="text-align:right;font-weight: bold;color: black !important;"> 26 </td>
   <td style="text-align:left;"> Romantic </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> Performance </td>
   <td style="text-align:right;"> 2.5 </td>
   <td style="text-align:right;"> 305 </td>
   <td style="text-align:left;"> Yes </td>
   <td style="text-align:left;"> 2019-01-07 </td>
  </tr>
</tbody>
</table></div>

# Modelling

Question: **How long would it take to learn a piece based on various factors?**

## detect outliers

Given the very limited data at the advanced level (Grade 7 ABRSM), those two pieces will be removed. One is an extreme outlier as well which will significantly impact our models.



## missing values

There are no missing values in the modelling dataset following the ETL process.

## Feature engineering

* **categorical**:
  * **ABRSM grade**: 1 to 8
  * **Genre**: Baroque, Classical, Romantic, Modern
  * **Break**: learning it continuously or setting it aside for a while (1 month minimum)
  * **Standard** of practice: public performance or average (relative to someone's level of playing)
* **numerical**:
  * **Experience**: total hours practiced before the first practice session on each piece
  * piece **Length**: minutes

## Pre-processing

Let's use some basic standardisation offered by the caret package such as **centering** (subtract mean from values) and **scaling** (divide values by standard deviation).



## Resampling

Given the small size of the dataset, bootstrapping resampling method will be applied.



## Model selection


```r
# set number of clusters 
clusters <- 4

# run them all in parallel
cl <- makeCluster(clusters, type = "SOCK")
 
# register cluster train in paralel
registerDoSNOW(cl)

# train models
model <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                  data = model_data,
                  method = "ranger",
                  tuneLength = 100,
                  trControl = train.control)


model2 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "lmStepAIC",
                tuneLength = 100,
                trControl = train.control)


model3 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "lm",
                tuneLength = 100,
                trControl = train.control)

model4 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "ridge",
                tuneLength = 100,
                trControl = train.control)

model5 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "rf",
                tuneLength = 100,
                trControl = train.control)

model6 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "gbm",
                tuneLength = 100,
                trControl = train.control)

model7 <- train(Duration ~ ABRSM + Genre + Length + Cumulative_Duration + Break + Standard,
                data = model_data,
                method = "pls",
                tuneLength = 100,
                trControl = train.control)
 
# shut the instances of R down
stopCluster(cl)

# compare models
model_list <- list(ranger = model, lmStepAIC = model2, lm = model3, ridge = model4, rf = model5, gbm = model6, pls = model7)

model_comparison <- resamples(model_list)

# learning curves to indicate overfitting and underfitting
# hyper parameters 
# https://topepo.github.io/caret/model-training-and-tuning.html#model-training-and-parameter-tuning
# https://topepo.github.io/caret/random-hyperparameter-search.html
```

We chose the Random Forest model as it was the best performing model. It is known as a model which is:

* not very sensitive to outliers
* good for non-linearity
* variable importance can be biased if categorical variables have few levels (toward high levels) or are correlated


```
## 
## Call:
## summary.resamples(object = model_comparison)
## 
## Models: ranger, lmStepAIC, lm, ridge, rf, gbm, pls 
## Number of resamples: 25 
## 
## MAE 
##               Min.  1st Qu.   Median     Mean  3rd Qu.      Max. NA's
## ranger    3.216848 4.546412 5.226721 5.350732 6.185954  8.074644    0
## lmStepAIC 4.059373 6.035128 6.625829 7.373961 8.656703 12.293508    0
## lm        3.457466 6.104998 6.831580 7.407868 8.107952 16.638647    0
## ridge     3.514506 5.195608 5.904643 5.936369 7.002558  7.751690   10
## rf        2.867137 5.123509 5.592698 5.959335 6.989707  8.722035    0
## gbm       4.593238 6.146348 6.951988 7.261349 8.076775 16.990824    0
## pls       4.460543 5.041959 5.930350 5.848360 6.295627  7.970644    0
## 
## RMSE 
##               Min.  1st Qu.   Median     Mean   3rd Qu.      Max. NA's
## ranger    4.531594 5.821475 6.907062 6.876131  7.614550 10.521156    0
## lmStepAIC 4.678084 7.290730 8.706652 9.067898 10.179064 15.976038    0
## lm        3.979872 8.065115 8.705383 9.404728 10.412562 19.451739    0
## ridge     4.989087 6.206758 6.862180 7.045983  7.854493  8.687658   10
## rf        3.394308 6.640020 7.115649 7.546307  8.461888 11.065527    0
## gbm       5.906910 7.466537 8.041088 8.843606  8.994092 21.377506    0
## pls       5.322380 6.303446 7.096138 7.043631  7.345444  9.624458    0
## 
## Rsquared 
##                   Min.   1st Qu.    Median      Mean   3rd Qu.      Max. NA's
## ranger    0.2598148174 0.5915672 0.6861549 0.6395133 0.7899287 0.8801139    0
## lmStepAIC 0.0005882529 0.4001020 0.5735153 0.5051570 0.6597403 0.8997367    0
## lm        0.0019980780 0.2879700 0.5871362 0.4965277 0.6363397 0.8958706    0
## ridge     0.3743315404 0.6559275 0.6807293 0.6828744 0.7764227 0.8621330   10
## rf        0.1341300382 0.5248279 0.6068158 0.5858350 0.7012294 0.8842650    0
## gbm       0.0669333944 0.3848695 0.5685371 0.5338006 0.6661362 0.8728232    0
## pls       0.3579501758 0.6342263 0.6727956 0.6723318 0.7638235 0.8898141    0
```

Based on our regression model, it does not look like we have significant multicollinearity between the full model variables so we can continue as it is.

<table class=" lightable-paper lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Variance Inflation Factor (VIF)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> names </th>
   <th style="text-align:right;"> VIF </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ABRSM6 </td>
   <td style="text-align:right;"> 4.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cumulative_Duration </td>
   <td style="text-align:right;"> 3.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM5 </td>
   <td style="text-align:right;"> 3.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM4 </td>
   <td style="text-align:right;"> 3.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreClassical </td>
   <td style="text-align:right;"> 2.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Length </td>
   <td style="text-align:right;"> 2.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> StandardPerformance </td>
   <td style="text-align:right;"> 2.4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BreakNo </td>
   <td style="text-align:right;"> 2.1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreRomantic </td>
   <td style="text-align:right;"> 1.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM2 </td>
   <td style="text-align:right;"> 1.7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreModern </td>
   <td style="text-align:right;"> 1.7 </td>
  </tr>
</tbody>
</table>

### Actuals vs Predictions


```{=html}
<div id="htmlwidget-b7aa45dd5c8d1cf9ef22" style="width:100%;height:576px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-b7aa45dd5c8d1cf9ef22">{"x":{"data":[{"x":[8.49660722222223,11.9175838888889,5.77038222222222,28.1258761111111,27.156945,9.14350111111112,18.6305133333333,7.07084333333334,5.1912911111111,5.06910388888888,9.69723166666667],"y":[3.86666666666667,8.45,6.83333333333333,26.1166666666667,29.5333333333333,3.11666666666667,20.3333333333333,6.51666666666667,4.63333333333333,4.06666666666667,9.75],"text":["Bach - Minuet in G - 114<br />Predicted:  8.496607<br />Actual:  3.866667<br />Residuals: -4.62994056<br />Level: Beginner","Bach - Minuet in G - 116<br />Predicted: 11.917584<br />Actual:  8.450000<br />Residuals: -3.46758389<br />Level: Beginner","Bach - Minuet in Gm - 115<br />Predicted:  5.770382<br />Actual:  6.833333<br />Residuals:  1.06295111<br />Level: Beginner","Chopin - Waltz in Am<br />Predicted: 28.125876<br />Actual: 26.116667<br />Residuals: -2.00920944<br />Level: Beginner","Clementi - Sonatina no 3 - Mov 1<br />Predicted: 27.156945<br />Actual: 29.533333<br />Residuals:  2.37638833<br />Level: Beginner","Clementi - Sonatina no 3 - Mov 2<br />Predicted:  9.143501<br />Actual:  3.116667<br />Residuals: -6.02683444<br />Level: Beginner","Clementi - Sonatina no 3 - Mov 3<br />Predicted: 18.630513<br />Actual: 20.333333<br />Residuals:  1.70282000<br />Level: Beginner","Georg Böhm - Minuet in G<br />Predicted:  7.070843<br />Actual:  6.516667<br />Residuals: -0.55417667<br />Level: Beginner","Schumann - Lalling Melody<br />Predicted:  5.191291<br />Actual:  4.633333<br />Residuals: -0.55795778<br />Level: Beginner","Schumann - Melody<br />Predicted:  5.069104<br />Actual:  4.066667<br />Residuals: -1.00243722<br />Level: Beginner","Schumann - Volksliedchen<br />Predicted:  9.697232<br />Actual:  9.750000<br />Residuals:  0.05276833<br />Level: Beginner"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(255,65,13,1)","opacity":0.75,"size":11.3385826771654,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(255,65,13,1)"}},"hoveron":"points","name":"Beginner","legendgroup":"Beginner","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[23.3649344444444,19.1205872222222,27.4489661111111,25.2092655555556,19.1381722222222,24.3956022222222,22.345005,32.6938405555555,33.0190166666667,15.1216105555555,23.2738755555556,28.891945,18.0561027777778,11.74907,30.6133461111111],"y":[26.6666666666667,20.6666666666667,24.95,24.7333333333333,21.0666666666667,22.9166666666667,27.4166666666667,35.6833333333333,39.0333333333333,10.3833333333333,24.0666666666667,27.5666666666667,16.8,9.86666666666667,34.05],"text":["Bach - Invention 1 in C<br />Predicted: 23.364934<br />Actual: 26.666667<br />Residuals:  3.30173222<br />Level: Intermediate","Bach - Invention 4 in Dm<br />Predicted: 19.120587<br />Actual: 20.666667<br />Residuals:  1.54607944<br />Level: Intermediate","Bach - Prelude in Cm - 934<br />Predicted: 27.448966<br />Actual: 24.950000<br />Residuals: -2.49896611<br />Level: Intermediate","Bach - Prelude in G from Cello Suite No 1<br />Predicted: 25.209266<br />Actual: 24.733333<br />Residuals: -0.47593222<br />Level: Intermediate","C. Hartmann - The little ballerina<br />Predicted: 19.138172<br />Actual: 21.066667<br />Residuals:  1.92849444<br />Level: Intermediate","Chopin - Contredanse in Gb<br />Predicted: 24.395602<br />Actual: 22.916667<br />Residuals: -1.47893556<br />Level: Intermediate","Chopin - Waltz in Fm<br />Predicted: 22.345005<br />Actual: 27.416667<br />Residuals:  5.07166167<br />Level: Intermediate","Elton John - Your song (Arr Cornick)<br />Predicted: 32.693841<br />Actual: 35.683333<br />Residuals:  2.98949278<br />Level: Intermediate","Haydn - Andante in A<br />Predicted: 33.019017<br />Actual: 39.033333<br />Residuals:  6.01431667<br />Level: Intermediate","Ibert - Sérénade sur l’eau<br />Predicted: 15.121611<br />Actual: 10.383333<br />Residuals: -4.73827722<br />Level: Intermediate","Kuhlau - Rondo Vivace<br />Predicted: 23.273876<br />Actual: 24.066667<br />Residuals:  0.79279111<br />Level: Intermediate","Mozart - Allegro (3rd movement) K282<br />Predicted: 28.891945<br />Actual: 27.566667<br />Residuals: -1.32527833<br />Level: Intermediate","Poulenc - Valse Tyrolienne<br />Predicted: 18.056103<br />Actual: 16.800000<br />Residuals: -1.25610278<br />Level: Intermediate","Schumann - Kinderszenen 1<br />Predicted: 11.749070<br />Actual:  9.866667<br />Residuals: -1.88240333<br />Level: Intermediate","Schumann - Remembrance<br />Predicted: 30.613346<br />Actual: 34.050000<br />Residuals:  3.43665389<br />Level: Intermediate"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(110,226,255,1)","opacity":0.75,"size":11.3385826771654,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(110,226,255,1)"}},"hoveron":"points","name":"Intermediate","legendgroup":"Intermediate","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[5.06910388888888,5.42290025316455,5.77669661744022,6.13049298171588,6.48428934599155,6.83808571026722,7.19188207454289,7.54567843881856,7.89947480309422,8.25327116736989,8.60706753164556,8.96086389592123,9.3146602601969,9.66845662447257,10.0222529887482,10.3760493530239,10.7298457172996,11.0836420815752,11.4374384458509,11.7912348101266,12.1450311744022,12.4988275386779,12.8526239029536,13.2064202672292,13.5602166315049,13.9140129957806,14.2678093600562,14.6216057243319,14.9754020886076,15.3291984528833,15.6829948171589,16.0367911814346,16.3905875457103,16.7443839099859,17.0981802742616,17.4519766385373,17.8057730028129,18.1595693670886,18.5133657313643,18.8671620956399,19.2209584599156,19.5747548241913,19.9285511884669,20.2823475527426,20.6361439170183,20.9899402812939,21.3437366455696,21.6975330098453,22.0513293741209,22.4051257383966,22.7589221026723,23.1127184669479,23.4665148312236,23.8203111954993,24.174107559775,24.5279039240506,24.8817002883263,25.235496652602,25.5892930168776,25.9430893811533,26.296885745429,26.6506821097046,27.0044784739803,27.358274838256,27.7120712025316,28.0658675668073,28.419663931083,28.7734602953586,29.1272566596343,29.48105302391,29.8348493881856,30.1886457524613,30.542442116737,30.8962384810126,31.2500348452883,31.603831209564,31.9576275738396,32.3114239381153,32.665220302391,33.0190166666667],"y":[5.04848287406796,5.05177683151387,5.07426615887294,5.11581651511952,5.17650760491233,5.2564191329101,5.35564230007438,5.4743337984638,5.61241355568387,5.76974326003541,5.94618459981921,6.14159926333608,6.35584893888683,6.58879531477227,6.8449007765218,7.12947080146785,7.44106451003205,7.77820348467332,8.13940930785057,8.52320356202272,8.9281078296487,9.3526436931874,9.79533273509774,10.2546965378387,10.7292566838691,11.2175347556478,11.7180523356339,12.2293310062863,12.7498923500637,13.2883830267951,13.8822543946245,14.5240690163639,15.2010449948816,15.9004004330458,16.6093534337245,17.3151220997859,18.0049245340983,18.6659788395298,19.2855031189485,19.8507154752227,20.3519976125091,20.8344353515372,21.3140230063243,21.7873918724304,22.2511732454154,22.7019984208394,23.1364986942624,23.5513053612444,23.9430497173453,24.3010076817659,24.3838844849384,24.3567954226538,24.5794579946375,24.8964509417491,25.1902865741904,25.4689161715591,25.7402910134528,26.0123623794693,26.293081549206,26.5903998022607,26.9122684182309,27.2666386767145,27.6614618573089,28.0951050797891,28.5314393595753,28.9729965370875,29.4278074211248,29.9039028204862,30.4050944046292,30.9219615868374,31.4536828311383,32.0003580525116,32.5620871659371,33.1389700863947,33.7311067288641,34.3385970083252,34.9615408397577,35.6000381381414,36.2541888184562,36.9240927956817],"text":["Predicted:  5.069104<br />Actual:  5.048483<br />Level: red","Predicted:  5.422900<br />Actual:  5.051777<br />Level: red","Predicted:  5.776697<br />Actual:  5.074266<br />Level: red","Predicted:  6.130493<br />Actual:  5.115817<br />Level: red","Predicted:  6.484289<br />Actual:  5.176508<br />Level: red","Predicted:  6.838086<br />Actual:  5.256419<br />Level: red","Predicted:  7.191882<br />Actual:  5.355642<br />Level: red","Predicted:  7.545678<br />Actual:  5.474334<br />Level: red","Predicted:  7.899475<br />Actual:  5.612414<br />Level: red","Predicted:  8.253271<br />Actual:  5.769743<br />Level: red","Predicted:  8.607068<br />Actual:  5.946185<br />Level: red","Predicted:  8.960864<br />Actual:  6.141599<br />Level: red","Predicted:  9.314660<br />Actual:  6.355849<br />Level: red","Predicted:  9.668457<br />Actual:  6.588795<br />Level: red","Predicted: 10.022253<br />Actual:  6.844901<br />Level: red","Predicted: 10.376049<br />Actual:  7.129471<br />Level: red","Predicted: 10.729846<br />Actual:  7.441065<br />Level: red","Predicted: 11.083642<br />Actual:  7.778203<br />Level: red","Predicted: 11.437438<br />Actual:  8.139409<br />Level: red","Predicted: 11.791235<br />Actual:  8.523204<br />Level: red","Predicted: 12.145031<br />Actual:  8.928108<br />Level: red","Predicted: 12.498828<br />Actual:  9.352644<br />Level: red","Predicted: 12.852624<br />Actual:  9.795333<br />Level: red","Predicted: 13.206420<br />Actual: 10.254697<br />Level: red","Predicted: 13.560217<br />Actual: 10.729257<br />Level: red","Predicted: 13.914013<br />Actual: 11.217535<br />Level: red","Predicted: 14.267809<br />Actual: 11.718052<br />Level: red","Predicted: 14.621606<br />Actual: 12.229331<br />Level: red","Predicted: 14.975402<br />Actual: 12.749892<br />Level: red","Predicted: 15.329198<br />Actual: 13.288383<br />Level: red","Predicted: 15.682995<br />Actual: 13.882254<br />Level: red","Predicted: 16.036791<br />Actual: 14.524069<br />Level: red","Predicted: 16.390588<br />Actual: 15.201045<br />Level: red","Predicted: 16.744384<br />Actual: 15.900400<br />Level: red","Predicted: 17.098180<br />Actual: 16.609353<br />Level: red","Predicted: 17.451977<br />Actual: 17.315122<br />Level: red","Predicted: 17.805773<br />Actual: 18.004925<br />Level: red","Predicted: 18.159569<br />Actual: 18.665979<br />Level: red","Predicted: 18.513366<br />Actual: 19.285503<br />Level: red","Predicted: 18.867162<br />Actual: 19.850715<br />Level: red","Predicted: 19.220958<br />Actual: 20.351998<br />Level: red","Predicted: 19.574755<br />Actual: 20.834435<br />Level: red","Predicted: 19.928551<br />Actual: 21.314023<br />Level: red","Predicted: 20.282348<br />Actual: 21.787392<br />Level: red","Predicted: 20.636144<br />Actual: 22.251173<br />Level: red","Predicted: 20.989940<br />Actual: 22.701998<br />Level: red","Predicted: 21.343737<br />Actual: 23.136499<br />Level: red","Predicted: 21.697533<br />Actual: 23.551305<br />Level: red","Predicted: 22.051329<br />Actual: 23.943050<br />Level: red","Predicted: 22.405126<br />Actual: 24.301008<br />Level: red","Predicted: 22.758922<br />Actual: 24.383884<br />Level: red","Predicted: 23.112718<br />Actual: 24.356795<br />Level: red","Predicted: 23.466515<br />Actual: 24.579458<br />Level: red","Predicted: 23.820311<br />Actual: 24.896451<br />Level: red","Predicted: 24.174108<br />Actual: 25.190287<br />Level: red","Predicted: 24.527904<br />Actual: 25.468916<br />Level: red","Predicted: 24.881700<br />Actual: 25.740291<br />Level: red","Predicted: 25.235497<br />Actual: 26.012362<br />Level: red","Predicted: 25.589293<br />Actual: 26.293082<br />Level: red","Predicted: 25.943089<br />Actual: 26.590400<br />Level: red","Predicted: 26.296886<br />Actual: 26.912268<br />Level: red","Predicted: 26.650682<br />Actual: 27.266639<br />Level: red","Predicted: 27.004478<br />Actual: 27.661462<br />Level: red","Predicted: 27.358275<br />Actual: 28.095105<br />Level: red","Predicted: 27.712071<br />Actual: 28.531439<br />Level: red","Predicted: 28.065868<br />Actual: 28.972997<br />Level: red","Predicted: 28.419664<br />Actual: 29.427807<br />Level: red","Predicted: 28.773460<br />Actual: 29.903903<br />Level: red","Predicted: 29.127257<br />Actual: 30.405094<br />Level: red","Predicted: 29.481053<br />Actual: 30.921962<br />Level: red","Predicted: 29.834849<br />Actual: 31.453683<br />Level: red","Predicted: 30.188646<br />Actual: 32.000358<br />Level: red","Predicted: 30.542442<br />Actual: 32.562087<br />Level: red","Predicted: 30.896238<br />Actual: 33.138970<br />Level: red","Predicted: 31.250035<br />Actual: 33.731107<br />Level: red","Predicted: 31.603831<br />Actual: 34.338597<br />Level: red","Predicted: 31.957628<br />Actual: 34.961541<br />Level: red","Predicted: 32.311424<br />Actual: 35.600038<br />Level: red","Predicted: 32.665220<br />Actual: 36.254189<br />Level: red","Predicted: 33.019017<br />Actual: 36.924093<br />Level: red"],"type":"scatter","mode":"lines","name":"fitted values","line":{"width":3.77952755905512,"color":"rgba(255,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[-2.5,52.5],"y":[-2.5,52.5],"text":"intercept: 0<br />slope: 1","type":"scatter","mode":"lines","line":{"width":1.88976377952756,"color":"rgba(190,190,190,1)","dash":"dash"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":115.626400996264,"r":39.8505603985056,"b":130.676629306766,"l":70.9007887090079},"font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":15.2760481527605},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-2.5,52.5],"tickmode":"array","ticktext":["0","10","20","30","40","50"],"tickvals":[0,10,20,30,40,50],"categoryorder":"array","categoryarray":["0","10","20","30","40","50"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.81901203819012,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"EconSansCndReg","size":15.2760481527605},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.265670402656704,"zeroline":false,"anchor":"y","title":{"text":"Predicted","font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":11.9551681195517}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-2.5,52.5],"tickmode":"array","ticktext":["0","10","20","30","40","50"],"tickvals":[0,10,20,30,40,50],"categoryorder":"array","categoryarray":["0","10","20","30","40","50"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.81901203819012,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"EconSansCndReg","size":15.2760481527605},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.265670402656704,"zeroline":false,"anchor":"x","title":{"text":"Actual","font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":11.9551681195517}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":12.2208385222084},"y":1.2,"orientation":"h","x":0.4},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"7bcb5a3ae383":{"text":{},"x":{},"y":{},"label":{},"colour":{},"type":"scatter"},"7bcb502edbbc":{"x":{},"y":{},"label":{},"colour":{}},"7bcb345c3cc4":{"intercept":{},"slope":{}}},"cur_data":"7bcb5a3ae383","visdat":{"7bcb5a3ae383":["function (y) ","x"],"7bcb502edbbc":["function (y) ","x"],"7bcb345c3cc4":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

### Residual distribution

We can see that the residuals are mostly situated around 0.

<img src="figs/unnamed-chunk-27-1.png" width="100%" />

### Actuals versus Residuals

Looking at the variability of errors, there is still a tendency to over-predict for pieces that took very little and under-predict for the more difficult ones. There could be two main reasons for this:

* practicing an old piece in order to further improve (which naturally adds more practice time as I re-learn it)
* learning easier pieces later on in my journey which means I will learn them faster than expected (based on my earlier data where a piece of a similar difficulty took longer)


```{=html}
<div id="htmlwidget-b4919d0e71d318a290f7" style="width:100%;height:576px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-b4919d0e71d318a290f7">{"x":{"data":[{"x":[1.32083333333333,40.8291666666667],"y":[0,0],"text":"yintercept: 0","type":"scatter","mode":"lines","line":{"width":11.3385826771654,"color":"rgba(133,133,133,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[3.86666666666667,8.45,6.83333333333333,26.1166666666667,29.5333333333333,3.11666666666667,20.3333333333333,6.51666666666667,4.63333333333333,4.06666666666667,9.75],"y":[-4.62994055555556,-3.46758388888889,1.06295111111111,-2.00920944444446,2.37638833333332,-6.02683444444445,1.70281999999999,-0.55417666666667,-0.557957777777768,-1.00243722222221,0.0527683333333329],"text":["Bach - Minuet in G - 114<br />Actual:  3.866667<br />Residuals: -4.62994056<br />Level: Beginner<br />Predicted:  8.496607","Bach - Minuet in G - 116<br />Actual:  8.450000<br />Residuals: -3.46758389<br />Level: Beginner<br />Predicted: 11.917584","Bach - Minuet in Gm - 115<br />Actual:  6.833333<br />Residuals:  1.06295111<br />Level: Beginner<br />Predicted:  5.770382","Chopin - Waltz in Am<br />Actual: 26.116667<br />Residuals: -2.00920944<br />Level: Beginner<br />Predicted: 28.125876","Clementi - Sonatina no 3 - Mov 1<br />Actual: 29.533333<br />Residuals:  2.37638833<br />Level: Beginner<br />Predicted: 27.156945","Clementi - Sonatina no 3 - Mov 2<br />Actual:  3.116667<br />Residuals: -6.02683444<br />Level: Beginner<br />Predicted:  9.143501","Clementi - Sonatina no 3 - Mov 3<br />Actual: 20.333333<br />Residuals:  1.70282000<br />Level: Beginner<br />Predicted: 18.630513","Georg Böhm - Minuet in G<br />Actual:  6.516667<br />Residuals: -0.55417667<br />Level: Beginner<br />Predicted:  7.070843","Schumann - Lalling Melody<br />Actual:  4.633333<br />Residuals: -0.55795778<br />Level: Beginner<br />Predicted:  5.191291","Schumann - Melody<br />Actual:  4.066667<br />Residuals: -1.00243722<br />Level: Beginner<br />Predicted:  5.069104","Schumann - Volksliedchen<br />Actual:  9.750000<br />Residuals:  0.05276833<br />Level: Beginner<br />Predicted:  9.697232"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(255,65,13,1)","opacity":0.75,"size":11.3385826771654,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(255,65,13,1)"}},"hoveron":"points","name":"Beginner","legendgroup":"Beginner","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[26.6666666666667,20.6666666666667,24.95,24.7333333333333,21.0666666666667,22.9166666666667,27.4166666666667,35.6833333333333,39.0333333333333,10.3833333333333,24.0666666666667,27.5666666666667,16.8,9.86666666666667,34.05],"y":[3.30173222222229,1.54607944444444,-2.49896611111112,-0.475932222222216,1.92849444444445,-1.47893555555553,5.07166166666667,2.98949277777787,6.01431666666668,-4.73827722222221,0.792791111111093,-1.32527833333335,-1.25610277777778,-1.88240333333335,3.4366538888889],"text":["Bach - Invention 1 in C<br />Actual: 26.666667<br />Residuals:  3.30173222<br />Level: Intermediate<br />Predicted: 23.364934","Bach - Invention 4 in Dm<br />Actual: 20.666667<br />Residuals:  1.54607944<br />Level: Intermediate<br />Predicted: 19.120587","Bach - Prelude in Cm - 934<br />Actual: 24.950000<br />Residuals: -2.49896611<br />Level: Intermediate<br />Predicted: 27.448966","Bach - Prelude in G from Cello Suite No 1<br />Actual: 24.733333<br />Residuals: -0.47593222<br />Level: Intermediate<br />Predicted: 25.209266","C. Hartmann - The little ballerina<br />Actual: 21.066667<br />Residuals:  1.92849444<br />Level: Intermediate<br />Predicted: 19.138172","Chopin - Contredanse in Gb<br />Actual: 22.916667<br />Residuals: -1.47893556<br />Level: Intermediate<br />Predicted: 24.395602","Chopin - Waltz in Fm<br />Actual: 27.416667<br />Residuals:  5.07166167<br />Level: Intermediate<br />Predicted: 22.345005","Elton John - Your song (Arr Cornick)<br />Actual: 35.683333<br />Residuals:  2.98949278<br />Level: Intermediate<br />Predicted: 32.693841","Haydn - Andante in A<br />Actual: 39.033333<br />Residuals:  6.01431667<br />Level: Intermediate<br />Predicted: 33.019017","Ibert - Sérénade sur l’eau<br />Actual: 10.383333<br />Residuals: -4.73827722<br />Level: Intermediate<br />Predicted: 15.121611","Kuhlau - Rondo Vivace<br />Actual: 24.066667<br />Residuals:  0.79279111<br />Level: Intermediate<br />Predicted: 23.273876","Mozart - Allegro (3rd movement) K282<br />Actual: 27.566667<br />Residuals: -1.32527833<br />Level: Intermediate<br />Predicted: 28.891945","Poulenc - Valse Tyrolienne<br />Actual: 16.800000<br />Residuals: -1.25610278<br />Level: Intermediate<br />Predicted: 18.056103","Schumann - Kinderszenen 1<br />Actual:  9.866667<br />Residuals: -1.88240333<br />Level: Intermediate<br />Predicted: 11.749070","Schumann - Remembrance<br />Actual: 34.050000<br />Residuals:  3.43665389<br />Level: Intermediate<br />Predicted: 30.613346"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(110,226,255,1)","opacity":0.75,"size":11.3385826771654,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(110,226,255,1)"}},"hoveron":"points","name":"Intermediate","legendgroup":"Intermediate","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[3.11666666666667,3.57130801687764,4.02594936708861,4.48059071729958,4.93523206751055,5.38987341772152,5.84451476793249,6.29915611814346,6.75379746835443,7.2084388185654,7.66308016877637,8.11772151898734,8.57236286919831,9.02700421940928,9.48164556962025,9.93628691983122,10.3909282700422,10.8455696202532,11.3002109704641,11.7548523206751,12.2094936708861,12.664135021097,13.118776371308,13.573417721519,14.02805907173,14.4827004219409,14.9373417721519,15.3919831223629,15.8466244725738,16.3012658227848,16.7559071729958,17.2105485232068,17.6651898734177,18.1198312236287,18.5744725738397,19.0291139240506,19.4837552742616,19.9383966244726,20.3930379746835,20.8476793248945,21.3023206751055,21.7569620253165,22.2116033755274,22.6662447257384,23.1208860759494,23.5755274261603,24.0301687763713,24.4848101265823,24.9394514767932,25.3940928270042,25.8487341772152,26.3033755274262,26.7580168776371,27.2126582278481,27.6672995780591,28.12194092827,28.576582278481,29.031223628692,29.4858649789029,29.9405063291139,30.3951476793249,30.8497890295359,31.3044303797468,31.7590717299578,32.2137130801688,32.6683544303797,33.1229957805907,33.5776371308017,34.0322784810127,34.4869198312236,34.9415611814346,35.3962025316456,35.8508438818565,36.3054852320675,36.7601265822785,37.2147679324895,37.6694092827004,38.1240506329114,38.5786919831224,39.0333333333333],"y":[-2.99256617727432,-2.86856309579274,-2.75239436296033,-2.63981301527368,-2.53269697891513,-2.42962228107184,-2.32987689647928,-2.23302475592534,-2.13862979019795,-2.04625593008502,-1.95546710637446,-1.8658272498542,-1.77764993533499,-1.70251219389899,-1.63733746275438,-1.57272301593397,-1.49926877716218,-1.41899633093336,-1.33955941530922,-1.26094460209508,-1.1831384630963,-1.10612757011819,-1.0298984949661,-0.954437809445347,-0.879732085361275,-0.805767894519214,-0.732531808724499,-0.660010399782462,-0.588190239498436,-0.517057899677756,-0.446599952125753,-0.376802968647763,-0.307653521049118,-0.239138181135151,-0.171243520711195,-0.103956111582585,-0.0372625255546536,0.0288506655672664,0.0943968899778418,0.156441564857287,0.192609678734853,0.21094906656347,0.2271931076485,0.257075181295305,0.310175806248654,0.355204353767178,0.394736973249696,0.440393650920387,0.50164476175831,0.570555181960206,0.645058302439835,0.725659045996629,0.812776370769632,0.904301164428239,1.00011861109059,1.101561604817,1.20996303966782,1.32665580970335,1.45297280898394,1.58856946545545,1.73147613879886,1.88163613214069,2.03901305921934,2.20357053377324,2.37527216954077,2.55408158026034,2.73996237967037,2.93287818150925,3.13279259951539,3.33966924742721,3.55347173898309,3.77416368792145,4.00170870798069,4.23607041289922,4.47721241641545,4.72509833226778,4.97969177419461,5.24095635593435,5.50885569122541,5.78335339380619],"text":["Actual:  3.116667<br />Residuals: -2.99256618<br />Level: red","Actual:  3.571308<br />Residuals: -2.86856310<br />Level: red","Actual:  4.025949<br />Residuals: -2.75239436<br />Level: red","Actual:  4.480591<br />Residuals: -2.63981302<br />Level: red","Actual:  4.935232<br />Residuals: -2.53269698<br />Level: red","Actual:  5.389873<br />Residuals: -2.42962228<br />Level: red","Actual:  5.844515<br />Residuals: -2.32987690<br />Level: red","Actual:  6.299156<br />Residuals: -2.23302476<br />Level: red","Actual:  6.753797<br />Residuals: -2.13862979<br />Level: red","Actual:  7.208439<br />Residuals: -2.04625593<br />Level: red","Actual:  7.663080<br />Residuals: -1.95546711<br />Level: red","Actual:  8.117722<br />Residuals: -1.86582725<br />Level: red","Actual:  8.572363<br />Residuals: -1.77764994<br />Level: red","Actual:  9.027004<br />Residuals: -1.70251219<br />Level: red","Actual:  9.481646<br />Residuals: -1.63733746<br />Level: red","Actual:  9.936287<br />Residuals: -1.57272302<br />Level: red","Actual: 10.390928<br />Residuals: -1.49926878<br />Level: red","Actual: 10.845570<br />Residuals: -1.41899633<br />Level: red","Actual: 11.300211<br />Residuals: -1.33955942<br />Level: red","Actual: 11.754852<br />Residuals: -1.26094460<br />Level: red","Actual: 12.209494<br />Residuals: -1.18313846<br />Level: red","Actual: 12.664135<br />Residuals: -1.10612757<br />Level: red","Actual: 13.118776<br />Residuals: -1.02989849<br />Level: red","Actual: 13.573418<br />Residuals: -0.95443781<br />Level: red","Actual: 14.028059<br />Residuals: -0.87973209<br />Level: red","Actual: 14.482700<br />Residuals: -0.80576789<br />Level: red","Actual: 14.937342<br />Residuals: -0.73253181<br />Level: red","Actual: 15.391983<br />Residuals: -0.66001040<br />Level: red","Actual: 15.846624<br />Residuals: -0.58819024<br />Level: red","Actual: 16.301266<br />Residuals: -0.51705790<br />Level: red","Actual: 16.755907<br />Residuals: -0.44659995<br />Level: red","Actual: 17.210549<br />Residuals: -0.37680297<br />Level: red","Actual: 17.665190<br />Residuals: -0.30765352<br />Level: red","Actual: 18.119831<br />Residuals: -0.23913818<br />Level: red","Actual: 18.574473<br />Residuals: -0.17124352<br />Level: red","Actual: 19.029114<br />Residuals: -0.10395611<br />Level: red","Actual: 19.483755<br />Residuals: -0.03726253<br />Level: red","Actual: 19.938397<br />Residuals:  0.02885067<br />Level: red","Actual: 20.393038<br />Residuals:  0.09439689<br />Level: red","Actual: 20.847679<br />Residuals:  0.15644156<br />Level: red","Actual: 21.302321<br />Residuals:  0.19260968<br />Level: red","Actual: 21.756962<br />Residuals:  0.21094907<br />Level: red","Actual: 22.211603<br />Residuals:  0.22719311<br />Level: red","Actual: 22.666245<br />Residuals:  0.25707518<br />Level: red","Actual: 23.120886<br />Residuals:  0.31017581<br />Level: red","Actual: 23.575527<br />Residuals:  0.35520435<br />Level: red","Actual: 24.030169<br />Residuals:  0.39473697<br />Level: red","Actual: 24.484810<br />Residuals:  0.44039365<br />Level: red","Actual: 24.939451<br />Residuals:  0.50164476<br />Level: red","Actual: 25.394093<br />Residuals:  0.57055518<br />Level: red","Actual: 25.848734<br />Residuals:  0.64505830<br />Level: red","Actual: 26.303376<br />Residuals:  0.72565905<br />Level: red","Actual: 26.758017<br />Residuals:  0.81277637<br />Level: red","Actual: 27.212658<br />Residuals:  0.90430116<br />Level: red","Actual: 27.667300<br />Residuals:  1.00011861<br />Level: red","Actual: 28.121941<br />Residuals:  1.10156160<br />Level: red","Actual: 28.576582<br />Residuals:  1.20996304<br />Level: red","Actual: 29.031224<br />Residuals:  1.32665581<br />Level: red","Actual: 29.485865<br />Residuals:  1.45297281<br />Level: red","Actual: 29.940506<br />Residuals:  1.58856947<br />Level: red","Actual: 30.395148<br />Residuals:  1.73147614<br />Level: red","Actual: 30.849789<br />Residuals:  1.88163613<br />Level: red","Actual: 31.304430<br />Residuals:  2.03901306<br />Level: red","Actual: 31.759072<br />Residuals:  2.20357053<br />Level: red","Actual: 32.213713<br />Residuals:  2.37527217<br />Level: red","Actual: 32.668354<br />Residuals:  2.55408158<br />Level: red","Actual: 33.122996<br />Residuals:  2.73996238<br />Level: red","Actual: 33.577637<br />Residuals:  2.93287818<br />Level: red","Actual: 34.032278<br />Residuals:  3.13279260<br />Level: red","Actual: 34.486920<br />Residuals:  3.33966925<br />Level: red","Actual: 34.941561<br />Residuals:  3.55347174<br />Level: red","Actual: 35.396203<br />Residuals:  3.77416369<br />Level: red","Actual: 35.850844<br />Residuals:  4.00170871<br />Level: red","Actual: 36.305485<br />Residuals:  4.23607041<br />Level: red","Actual: 36.760127<br />Residuals:  4.47721242<br />Level: red","Actual: 37.214768<br />Residuals:  4.72509833<br />Level: red","Actual: 37.669409<br />Residuals:  4.97969177<br />Level: red","Actual: 38.124051<br />Residuals:  5.24095636<br />Level: red","Actual: 38.578692<br />Residuals:  5.50885569<br />Level: red","Actual: 39.033333<br />Residuals:  5.78335339<br />Level: red"],"type":"scatter","mode":"lines","name":"fitted values","line":{"width":3.77952755905512,"color":"rgba(255,0,0,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":115.626400996264,"r":39.8505603985056,"b":130.676629306766,"l":70.9007887090079},"font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":15.2760481527605},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[1.32083333333333,40.8291666666667],"tickmode":"array","ticktext":["10","20","30","40"],"tickvals":[10,20,30,40],"categoryorder":"array","categoryarray":["10","20","30","40"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.81901203819012,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"EconSansCndReg","size":15.2760481527605},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.265670402656704,"zeroline":false,"anchor":"y","title":{"text":"Actual","font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":11.9551681195517}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-6.62889200000001,6.61637422222224],"tickmode":"array","ticktext":["-6","-3","0","3","6"],"tickvals":[-6,-3,0,3,6],"categoryorder":"array","categoryarray":["-6","-3","0","3","6"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.81901203819012,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"EconSansCndReg","size":15.2760481527605},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(204,204,204,1)","gridwidth":0.265670402656704,"zeroline":false,"anchor":"x","title":{"text":"Residuals","font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":11.9551681195517}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"EconSansCndReg","size":12.2208385222084},"y":1.2,"orientation":"h","x":0.4},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"7bcb21d29642":{"yintercept":{},"type":"scatter"},"7bcb886d867":{"text":{},"x":{},"y":{},"colour":{},"label":{}},"7bcb4ce95690":{"x":{},"y":{},"colour":{},"label":{}}},"cur_data":"7bcb21d29642","visdat":{"7bcb21d29642":["function (y) ","x"],"7bcb886d867":["function (y) ","x"],"7bcb4ce95690":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

## Linear Regression (LR) or Random Forest (RF)?

We can see that the Random Forest performed significantly better than the Linear Regression model. This isn't surprising since there might be non-linear trends within the data, and RFs are known to be more accurate.

<table class=" lightable-paper lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Model 1 vs model 2</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> estimate </th>
   <th style="text-align:right;"> statistic </th>
   <th style="text-align:right;"> p.value </th>
   <th style="text-align:right;"> parameter </th>
   <th style="text-align:right;"> conf.low </th>
   <th style="text-align:right;"> conf.high </th>
   <th style="text-align:left;"> method </th>
   <th style="text-align:left;"> alternative </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1.858421 </td>
   <td style="text-align:right;"> 3.01994 </td>
   <td style="text-align:right;"> 0.0059183 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 0.5883319 </td>
   <td style="text-align:right;"> 3.12851 </td>
   <td style="text-align:left;"> One Sample t-test </td>
   <td style="text-align:left;"> two.sided </td>
  </tr>
</tbody>
</table>

## How many predictors did the most optimal model have?

<img src="figs/predictors-1.png" width="100%" />

## What were the most important variables?

We can now see that the most important variables seemed to be the length of the piece, my experience prior to starting a piece and time difficulty of the piece. These were also confirmed by the linear regression model.

<img src="figs/factors-1.png" width="100%" />

# Limitations

* very **limited data** which did not allow for a train/test split; however, a bootstrap resampling method is known to be a good substitute
* biased to **one person's** learning ability (others might learn faster or slower)
* on top of total hours of practice, **quality of practice** is a significant factor which is not captured in this dataset
* very **difficult to assess when a piece is "finished"** as you can always further improve on your interpretation
* not all pieces had official **ABRSM ratings** and a few had to be estimated; even for those that do have an official rating, the difficulty of a piece is highly subjective to each pianist and hard to quantify with one number
* **memorisation** might be a confounding variable that was not accounted for; sometimes there's an effort to practice a bit for longer just to memorise without an improvement in performance

# Hardest things about this analysis:

* the Extract-Transform-Load process - clean the "dirty data" and find creative ways to input the data on the front end of the app to make it reporting friendly on the back-end (with all the variables such as Genre, Type of practice, Composer and Piece name, tag pieces as "work in progress" etc)
* automate ways to differentiate between pieces that I came back to vs pieces I only studied once
* work with very limited data

# Interactive application:

* you can find an interactive display of this presentation, as well as the model in production at the [following link](https://peterhontaru.shinyapps.io/piano-practice-prediction/)
* https://peterhontaru.shinyapps.io/piano-practice-prediction/

# What's next?

* keep practicing, gather more data and refresh this analysis + update the model
* add a recommender tab to the shiny dashboard where people could be recommended a piece based on specific features
* connect to the Toggl API for live updates
