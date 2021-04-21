---
    output:
      html_document:
              
        toc: true
        toc_float: false
        toc_depth: 3
        number_sections: true
        
        code_folding: hide
        code_download: true
        
        fig_width: 9 
        fig_height: 5
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

An example of my video (around 2 years into playing here):

<div align="center">
   <iframe width="560" height="315" src="https://www.youtube.com/embed/eTJiT6TXIcw" frameborder="0" data-external="1" allowfullscreen>
   </iframe>
</div>

## Data collection

* imputed conservative estimations for the first 10 months of the first year (Jan '18 to Oct '18)
* everything from Dec '18 onwards was tracked using Toggl, a time-tracking app/tool
* these times include my practice sessions (usually in short bouts of 30 minutes); piano lessons are excluded (usually 2-3 hours total per month)
* individual pieces were tracked from '19 onwards (initially it was just a generic "piano")
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
    echo = FALSE, # show all code
    tidy = FALSE, # cleaner code printing
    size = "small", # smaller code
    
    fig.path = "figures/", #graphics location
    out.width = "100%",

    message = FALSE,
    warning = FALSE
    )
```



# Exploratory Data Analysis (EDA)

## Piano practice timeline

<img src="figures/unnamed-chunk-3-1.png" width="100%" />

## How long did I practice per piece?

Based on the level at the time and the difficulty of the piece, we can see that each piece took around 10-30 hours of practice.

<img src="figures/timeline-1.gif" width="100%" />

## How consistent was my practice?

Generally, I've done pretty well to maintain a high level of consistency with the exception of August/December. This is usually where I tend to take annual leave.

<img src="figures/unnamed-chunk-4-1.png" width="100%" />

## Was there a trend in my amount of daily average practice? {.tabset .tabset-fade .tabset-pills}

We can see that my practice time was correlated with the consistency, where the average session was much shorter in the months I was away from the piano. There's also a trend where my practice close to an exam session was significantly higher than any other time of the year. **Can you spot in which month I had my exam in 2019? What about the end of 2020?**

*average practice length per month includes the days in which I did not practice*

### overall {-}

<img src="figures/unnamed-chunk-5-1.png" width="100%" />

### Year on Year {-}

Similar trends as before are apparent where my average daily session is longer before the exams than any other time in the year and a dip in the months where I usually take most of my annual leave. I really do need to start picking up the pace and get back to where I used to be.

<img src="figures/unnamed-chunk-6-1.png" width="100%" />

## Did COVID significantly impact my practice time? {.tabset .tabset-fade .tabset-pills}

### graph {-}

Despite a similar median, we can see that the practice sessions were less likely to be over 80 min after COVID. We can test if this was a significant impact with a t-test.

<img src="figures/unnamed-chunk-7-1.png" width="100%" />

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

<img src="figures/unnamed-chunk-11-1.png" width="100%" />

### by composer {-}

<img src="figures/unnamed-chunk-12-1.png" width="100%" />

### by piece {-}

<img src="figures/unnamed-chunk-13-1.png" width="100%" />

## Relation between difficulty and number of practice hours {.tabset .tabset-fade .tabset-pills}

### ABRSM grade {-}

Simplified, ABBRSM grades are a group of 8 exams based on their difficulty (1 - beginner to 8 - advanced). There are also diploma grades but those are extremely advanced, equivalent to university level studies and out of the scope of this analysis. 

More information can be found on their official website at https://gb.abrsm.org/en/exam-support/your-guide-to-abrsm-exams/

<img src="figures/unnamed-chunk-14-1.png" width="100%" />

### level {-}

A further aggregation of ABRSM grades; this is helpful given the very limited dataset within each grade and much easier on the eye. This is an oversimplification but they're classified as:
  * 1-5: Beginner (1)
  * 5-6: Intermediate (2)
  * 7-8: Advanced (3)

<img src="figures/unnamed-chunk-15-1.png" width="100%" />

## What about the piece length?

<img src="figures/unnamed-chunk-16-1.png" width="100%" />

## Learning effect - do pieces of the same difficulty become easier to learn with time?

We can spot a trend where the time required to learn a piece of a similar difficulty (ABRSM Grade) decreases as my ability to play the piano increases (as judged by cumulative hours of practice). We should keep this in mind and include it as a variable into our prediction model.

<img src="figures/unnamed-chunk-17-1.png" width="100%" />

## Does "pausing" a piece impact the total time required to learn it?

How do we differentiate between pieces that we learn once and those that we come back to repeatedly? Examples could include wanting to improve the playing further, loving it so much we wanted to relearn it, preparing it for a new performance, etc.

As anyone that ever played the piano knows, re-learning a piece, particularly after you "drop" it for a few months/years, results in a much better performance/understanding of the piece. I definitely found that to be true in my experience, particularly with my exam pieces.The downside is that these pieces take longer to learn.

<img src="figures/unnamed-chunk-18-1.png" width="100%" />

## Repertoire

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:450px; "><table class=" lightable-paper lightable-striped lightable-hover" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; width: auto !important; margin-left: auto; margin-right: auto;'>
<caption>Repertoire (red - response variable; green - predictor variables)</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Project </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Duration </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Genre </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Length </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Standard </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> Experience </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Break </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ABRSM </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Level </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> Started </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Elton John - Rocket man </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 47 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Modern </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 4.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1130 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 7 </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> 2020-12-08 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Träumerei </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 14 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 3.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1087 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 7 </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> 2020-11-09 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Mozart - Allegro (3rd movement) K282 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 28 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 3.3 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1081 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-11-05 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Ibert - Sérénade sur l’eau </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 10 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Modern </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1038 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-09-24 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Kuhlau - Rondo Vivace </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 24 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.2 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1014 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-08-03 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> C. Hartmann - The little ballerina </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 21 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 998 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-07-14 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Lalling Melody </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 5 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.3 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 981 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-06-28 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Melody </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 4 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 972 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-06-20 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 2 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 3 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 952 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-06-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 3 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 20 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 952 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-06-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Waltz in Fm </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 27 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 895 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-04-18 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Clementi - Sonatina no 3 - Mov 1 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 30 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 877 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-04-07 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Kinderszenen 1 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 10 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 855 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-03-25 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Prelude in G from Cello Suite No 1 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 25 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.5 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 788 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-02-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Georg Böhm - Minuet in G </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.0 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 780 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-01-27 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Invention 4 in Dm </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 21 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 777 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-01-25 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Contredanse in Gb </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 23 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.2 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 762 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 6 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2020-01-16 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in Gm - 115 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.3 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 750 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 1 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2020-01-07 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in G - 114 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 4 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 726 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> 2019-12-06 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Elton John - Your song (Arr Cornick) </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 36 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Modern </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 3.3 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 713 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-11-21 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Poulenc - Valse Tyrolienne </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 17 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Modern </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 562 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-09-02 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Prelude in Cm - 934 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 25 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.4 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 536 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-08-15 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Volksliedchen </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 10 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.8 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 501 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> No </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 2 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2019-07-01 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Haydn - Andante in A </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 39 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Classical </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.8 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Average </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 468 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-06-08 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Schumann - Remembrance </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 34 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.2 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 422 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-04-28 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Minuet in G - 116 </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 8 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 361 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> NA </td>
   <td style="text-align:left;"> Advanced </td>
   <td style="text-align:left;"> 2019-03-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Bach - Invention 1 in C </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 27 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Baroque </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 1.7 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 350 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 5 </td>
   <td style="text-align:left;"> Intermediate </td>
   <td style="text-align:left;"> 2019-02-22 </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;color: black !important;"> Chopin - Waltz in Am </td>
   <td style="text-align:right;font-weight: bold;color: red !important;"> 26 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Romantic </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 2.5 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Performance </td>
   <td style="text-align:right;font-weight: bold;color: green !important;"> 305 </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> Yes </td>
   <td style="text-align:left;font-weight: bold;color: green !important;"> 4 </td>
   <td style="text-align:left;"> Beginner </td>
   <td style="text-align:left;"> 2019-01-07 </td>
  </tr>
</tbody>
</table></div>

# Modelling

Question: **How long would it take to learn a piece based on various factors?**

## outliers

Given the very limited data at the advanced level (Grade 7 ABRSM), those two pieces will be removed. One is an extreme outlier as well which will significantly impact our models.



## missing values

There are no missing values in the modelling dataset following the ETL process.

## feature engineering

* **categorical**:
  * **ABRSM grade**: 1 to 8
  * **Genre**: Baroque, Classical, Romantic, Modern
  * **Break**: learning it continuously or setting it aside for a while (1 month minimum)
  * **Standard** of practice: public performance or average (relative to someone's level of playing)
* **numerical**:
  * **Experience**: total hours practiced before the first practice session on each piece
  * piece **Length**: minutes

## pre-processing

Let's use some basic standardisation offered by the caret package such as **centering** (subtract mean from values) and **scaling** (divide values by standard deviation).



## resampling

Given the small size of the dataset, bootstrapping resampling method will be applied.



## model selection


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
## ranger    3.021008 4.266143 4.946282 5.299442 6.243741  7.922518    0
## lmStepAIC 4.028395 5.690166 7.868767 8.503530 9.837814 17.181537    0
## lm        2.039521 5.772827 7.115061 7.641375 8.368587 16.692018    0
## ridge     3.406549 4.539113 4.997571 5.161525 6.107118  6.701543   13
## rf        1.996873 4.456777 5.186487 5.185054 5.888977  7.589383    0
## gbm       2.553344 5.186242 6.269624 6.590318 8.017100 11.058042    0
## pls       3.322617 4.289868 4.661391 4.939639 6.014574  6.505947    0
## 
## RMSE 
##               Min.  1st Qu.   Median      Mean   3rd Qu.      Max. NA's
## ranger    3.864228 5.315607 6.162724  6.350531  7.357032  9.001666    0
## lmStepAIC 4.956079 7.563875 9.427272 10.849266 12.508605 22.507683    0
## lm        2.072607 7.474750 8.841582  9.608014 10.506074 21.748986    0
## ridge     3.789583 5.322770 6.175154  6.371706  7.532710  8.867574   13
## rf        2.845897 5.896209 6.423869  6.527895  7.398713  9.887790    0
## gbm       2.863830 7.040941 8.600280  8.355581  9.551342 12.558296    0
## pls       3.398100 5.122330 5.592774  5.753895  6.480938  8.004247    0
## 
## Rsquared 
##                  Min.   1st Qu.    Median      Mean   3rd Qu.      Max. NA's
## ranger    0.395533303 0.5110174 0.6963843 0.6508775 0.7521799 0.9194498    0
## lmStepAIC 0.032085810 0.2440455 0.5301134 0.4420157 0.5929040 0.8193574    0
## lm        0.002773983 0.3152272 0.5205367 0.4709629 0.6646064 0.9594312    0
## ridge     0.156077140 0.6851875 0.7338446 0.7108150 0.8053173 0.9515817   13
## rf        0.125014858 0.5885457 0.6937981 0.6618163 0.7600447 0.9296281    0
## gbm       0.113071932 0.3462277 0.5310918 0.5266083 0.6574668 0.9769281    0
## pls       0.010994365 0.6228905 0.7980685 0.7319133 0.8426825 0.9723046    0
```

## model evaluation

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
   <td style="text-align:left;"> ABRSM5 </td>
   <td style="text-align:right;"> 5.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cumulative_Duration </td>
   <td style="text-align:right;"> 4.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM6 </td>
   <td style="text-align:right;"> 4.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM4 </td>
   <td style="text-align:right;"> 3.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Length </td>
   <td style="text-align:right;"> 2.8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreClassical </td>
   <td style="text-align:right;"> 2.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> StandardPerformance </td>
   <td style="text-align:right;"> 2.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ABRSM2 </td>
   <td style="text-align:right;"> 2.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreRomantic </td>
   <td style="text-align:right;"> 2.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BreakNo </td>
   <td style="text-align:right;"> 2.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GenreModern </td>
   <td style="text-align:right;"> 1.7 </td>
  </tr>
</tbody>
</table>

### actuals vs predictions

<img src="figures/unnamed-chunk-26-1.png" width="100%" />

### residual distribution {.tabset .tabset-fade .tabset-pills}

#### histogram {-}

We can see that the residuals are mostly situated around 0.

<img src="figures/unnamed-chunk-27-1.png" width="100%" />

#### QQ plot / normal probability plot of residuals {-}

Similar to the previous histogram, we can spot some deviations from the normal distribution.

<img src="figures/unnamed-chunk-28-1.png" width="100%" />

### independence of residuals (and hence observations)

There seems to be a slight trend where newer pieces have a smaller residuals. This could mean a lack of independence from the order of data collection (the model predictions are based on my current level).

<img src="figures/unnamed-chunk-29-1.png" width="100%" />

### actuals versus residuals

Looking at the variability of errors, there is still a tendency to over-predict for pieces that took very little and under-predict for the more difficult ones. There could be two main reasons for this:

* practicing an old piece in order to further improve (which naturally adds more practice time as I re-learn it)
* learning easier pieces later on in my journey which means I will learn them faster than expected (based on my earlier data where a piece of a similar difficulty took longer)

<img src="figures/unnamed-chunk-30-1.png" width="100%" />

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
   <td style="text-align:right;"> 3.080119 </td>
   <td style="text-align:right;"> 3.333892 </td>
   <td style="text-align:right;"> 0.0027725 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:right;"> 1.173323 </td>
   <td style="text-align:right;"> 4.986915 </td>
   <td style="text-align:left;"> One Sample t-test </td>
   <td style="text-align:left;"> two.sided </td>
  </tr>
</tbody>
</table>

## How many predictors did the most optimal model have?

<img src="figures/predictors-1.png" width="100%" />

## What were the most important variables?

We can now see that the most important variables seemed to be the length of the piece, my experience prior to starting a piece and time difficulty of the piece. These were also confirmed by the linear regression model.

<img src="figures/factors-1.png" width="100%" />

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
* I started tracking sight-reading/technique so maybe will look into reporting on that too once I gather some data
