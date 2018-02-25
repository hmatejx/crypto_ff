# Is Crypto a bubble?

This project documents my thoughts on the recent unprecedented rise in crypto-currency hype.

------

### Introduction

First, a disclaimer is in order. I am a believer in the technology, but I am not a Bitcoin maximalist. I do hold a bit of BTC and various alts. I am a also very late adopter, so my bags are small by many standards :-)

I believe there are valid uses for block-chain or distributed ledger technology, and we are collectively only scratching the surface.

### Background

In what I believe is my original contribution I shall describe the modeling framework that emerged from my other (unfinished) [hobby project](https://github.com/hmatejx/slashdot-ai-hype)...

Initially I tried fitting the well established infectious recovery [SIR model](https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology#Bio-mathematical_deterministic_treatment_of_the_SIR_model), which has successfully been used in the past [by](https://arxiv.org/abs/1401.4208) [many](http://i-scover.ieice.org/proceedings/apsitt/2015/pdf/RS-3-2.pdf) [others](https://arxiv.org/abs/1608.07870), myself including, to predict the growth and decline of giant Social Networking Services (SNS) such as [Facebook](https://raw.githubusercontent.com/hmatejx/slashdot-ai-hype/master/img/Facebook_irSIR_fit.png) and [LinkedIn](https://raw.githubusercontent.com/hmatejx/slashdot-ai-hype/master/img/LinkedIn_irSIR_fit.png). The results were, in contrast to the success of the SNS setting, *all but satisfactory...*

The irSIR model, expressed by ordinary differential equations, is shown below . Here the letters *S*, *I*, and *R* stand for the susceptible, infected, and recovered part of the population.

**irSIR model**                                                  <img src="img/irSIR_model.png" alt="irSIR equations]" width="196">

It quickly dawned on me that within the SNS setting the driving force can mostly be described as passive, "push" based. 

For example, If you start as *S*, you eventually give up to the pressure of your peers, who are already *I*. Likewise, if you are *I*, you start observing your friends leaving  and eventually you leave as there is hardly anyone left that you know or care about. This might indeed be a very crude approximation, but it fits nicely with my own anecdotal experience.

Crypto, on the other hand, is *different*. Anybody who has tried to trade and time the market, especially as a rookie, knows what I mean. Even the "seasoned" traders are sometimes subject to it. 

### FOMO/FUD model

Picture (or remember) the following situation. 

> Observing (in your favorite trading view) the performance of your chosen asset, you see the candles moving rapidly. The volume is rising as well. Learning just beforehand some of important bit of news related to your asset, your mind is racing. It's going to be huge, they said... What should I do? Am I already too late?. My oh my, this is moving so fast. Without fully being aware of it, you react.

You buy based on fear. You sell based on fear. 

You might fear that you might miss the opportunity of a life-time.  There is a even word for it: [FOMO](https://en.wikipedia.org/wiki/Fear_of_missing_out).  Alternatively, if the news is negative, and the price is rapidly dropping, you might fear that you will loose everything and are already picturing yourself explaining the misfortune to your significant other. While I am not aware of a jargon word describing the later situation, such a situation is often caused by deliberate disinformation. Hence I shall call this state of fear [FUD](https://en.wikipedia.org/wiki/Fear,_uncertainty_and_doubt).

Fear appears to be much more "pull" based.  In contrast to the push-based dynamics of SNS, in Crypto your brain is trying to estimate the value of belonging to a certain group of the population. If you find yourself in a subgroup that is loosing value, but you also observe another subgroup that is quickly growing in value, your fear of being mispositioned. And you quickly react to fix it.

The simplest approach to mimic your brain's estimation of the perceived value of belonging to a particular subgroup is simply to utilize [Metcalfe's law](https://en.wikipedia.org/wiki/Metcalfe%27s_law). The bigger the (growing) subgroup, the bigger the perceived value, and the value scales as the square of the subgroup size.

The differential equations the FOMO/FUD model are therefore similar to irSIR, but the *SI/N* and *IR/N* terms are replaced with *SI/N^2* and *IR/N^2*. 

**FOMO/FUD model**                                   <img src="img/FOMO_FUD_model.png" alt="irSIR equations]" width="196">

### Approach

The approach is to fit the (normalized) Google Trends popularity data for the [Cryptocurrency](https://trends.google.com/trends/explore?q=Cryptocurrency) keyword using the FOMO/FUD model. The actual fit is performed in a Bayesian fashion (no particular reason, I just wanted to learn how to do it). 

Namely, a generative model is specified that completely describes the data generation process: 

- temporal evolution of the sate using ODEs, and 
- subsequent addition of a Poisson-like noise.

As the absolute scale is not known, the noise is approximated by a normal or log-normal distribution whose width is proportional to the square root of the normalized popularity score. This approach has been shown to adequately describe the observed variability. 

**The key principle is to try to include _all_ uncertainties into prediction.**

Coupled with weak uninformative priors we can obtain the _posterior predictive distribution_ of the normalized popularity. The model can be extrapolated into the future. 

The model is implemented in the [Stan](http://mc-stan.org/) probabilistic programming language, which uses the advanced NUTS MCMC sampling algorithm.

Of course, it goes without saying that even a Bayesian approach cannot mitigate the consequences of fitting the wrong model ;-)

### Attempt at a global fit

The fit to popularity data starting from the beginning of 2017 is shown in the figure below. 

Two things can be noticed immediately. The minor bubbles of June and September are not very well described, which is to be expected. After all, the model is only able to describe a single bubble. Moreover, at early time periods, as well as after the big peak, the lower limit of the 95% prediction interval goes below zero. This is a consequence the variability is being modeled by a normal distribution with the width proportional to the square root of the mean value.



![Cryptocurrency fit_all](img/Cryptocurrency_FOMO-FUD_fit%28update%29.png)



### Describing the shape of the peak

In order to improve the explore if the model is applicable, the process is repeated below by using data from 2017-10-01 onwards (therefore excluding the two pre-peaks). In addition, the variability model is replaced by a log-normal distribution, which cannot go below zero. 



![Cryptocurrency fit_peak](img/Cryptocurrency_FOMO-FUD_%28jan%20peak%29.png)

I personally find it astounding how well the median prediction line matches the 31-day moving average of the Google Trends data.

### Quo vadis, crypto?

Ok, so now what? Is it over? Honestly, I don't know.

One way to utilize the above result is to monitor the Google Trends data for a possible break outside the 95% prediction interval. If the FOMO/FUD assumptions hold, even approximately, one would expect to see the future trend data within the 95% prediction interval (the decay will continue).

On the other hand, an sustained upwards break-out of the gray zone would indicate this peak was a indeed bubble indeed, but overlaid on slowly rising background adoption curve 

```To-Do: cite some S-curve articles, especially try to find the fractal one...```

I will try to make regular weekly updates, unless my busy schedule prohibits it.

Stay tuned ;-)