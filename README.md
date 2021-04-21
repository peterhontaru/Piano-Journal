Human Learning meets Machine Learning - 1,200+ hours of piano practice
================
by Peter Hontaru

<div align="center">

<img src="www/piano.jpg" alt="I have a soft spot for grand pianos" width="550"/>

</div>

# Problem statement

### the why

Learning a piano piece is a time-intensive process. Like with most other
things, we tend to overestimate our own ability and then become
frustrated that we cannot learn and play that Chopin piece like a
concert pianist after only 30 minutes of practice. Fortunately, unlike
what you might hear on Wall Street, previous performance **is**
indicative of future success.

### the what

**Can we predict how long it would take to learn a piano piece based on
a number of factors? If so, which factors influenced the total amount of
hours required to learn the piece the most?**

### context

I started playing the piano in 2018 as a complete beginner and I’ve been
tracking my practice time for around 2 and a half years. I’ve now
decided to put that data to good use and see what interesting patterns I
might be able to find and hopefully develop a tool that others might be
able to use in their journeys.

![Timeline](figs/unnamed-chunk-3-1.png)

Here’s an example of a recent performance (I mainly play classical music
but cannot help but love Elton John’s music):

<div align="center">

**click to view**

</div>

<div align="center">

[![Everything Is
AWESOME](www/Elton.png)](https://www.youtube.com/embed/eTJiT6TXIcw "Elton John - Your Song")

</div>

# Key insights:

-   identified various trends in my practice habits (can you guess in
    which month I had my piano exam in 2019?)

![trends](figs/unnamed-chunk-5-1.png)

-   pieces could take me anywhere from \~4 hours to 40+ hours of
    practice, subject to difficulty (as assessed by the ABRSM grade)

![difficulty](figs/unnamed-chunk-15-1.png)

-   the **Random Forest** model was shown to be the most optimal model

    -   **Rsquared** (0.59)
    -   **MAE** - 5.9 hours
    -   **RMSE** - 7.5 hours

Looking at the variability of errors, there is still a tendency to
over-predict for pieces that took very little time to learn and
under-predict for the more difficult ones. There could be two main
reasons for this:

-   artificially inflating the number of hours spent on a piece by
    returning to it a second time (due to a recital performance, wanting
    to improve the interpretation further or simply just liking it
    enough to play it again)
-   learning easier pieces later on in my journey which means I will
    learn them faster than expected (based on my earlier data where a
    piece of a similar difficulty took longer)

![Residuals](www/residuals.png)

-   the most important variables were shown to be the **length of the
    piece**, **standard of playing**(performance vs casual) and
    **experience**(lifetime total practice before first practice session
    on each piece)

![factors](figs/factors-1.png)

# Data collection

-   imputed conservative estimations for the first 10 months of the
    first year (Jan ’18 to Oct ’18) and on Excel spreadsheet for Nov ’18
-   everything from Dec ’18 onwards was tracked using Toggl, a
    time-tracking app/tool
-   time spent in piano lessons was not tracked/included (usually 2-3
    hours total per month)
-   the **Extract, Transform, Load** script is available in the
    **global.R** file of this repo

**Disclaimer**: I am not affiliated with Toggl. I started using it a few
years ago because it provided all the functionality I needed and loved
its minimalistic design. The standard membership, which I use, is free
of charge.

# Limitations

-   very **limited data** which did not allow for a train/test split;
    however, a bootstrap resampling method is known to be a good
    substitute
-   biased to **one person’s** learning ability (others might learn
    faster or slower)
-   on top of total hours of practice, **quality of practice** is a
    significant factor which is not captured in this dataset
-   very **difficult to assess when a piece is “finished”** as you can
    always further improve on your interpretation
-   not all pieces had official **ABRSM ratings** and a few had to be
    estimated; even for those that do have an official rating, the
    difficulty of a piece is highly subjective to each pianist and hard
    to quantify with one number
-   **memorisation** might be a confounding variable that was not
    accounted for and it could lead to inflating the numbers required on
    a specific piece

# What’s next?

-   keep practicing, gather more data and refresh this analysis + adjust
    the model
-   add a recommender tab to the shiny dashboard to recommend pieces
    based on specific features
-   connect to the Toggl API for live updates

# Extended analysis

Full project available:

-   at the following
    [link](https://htmlpreview.github.io/?https://github.com/peterhontaru/Piano-Practice-Prediction/blob/master/EDA-and-modelling.html),
    in HTML format
-   in the **EDA-and-modelling.md** file of this repo (however, I
    recommend previewing it at the link above since it was originally
    designed as a HTML document)

# Interactive application:

-   you can find an interactive display of this presentation, as well as
    the model in production at the [following
    link](https://peterhontaru.shinyapps.io/piano-practice-prediction/)
-   <https://peterhontaru.shinyapps.io/piano-practice-prediction/>
