# -*- coding: utf-8 -*-
"""
Created on Wed Jun 24 06:45:13 2020

@author: k
"""
# -*- coding: utf-8 -*-
"""
Created on Sat Mar 23 20:57:55 2019

@author: k
"""

import numpy as np
import pandas as pd
from statsmodels.tsa.arima_model import ARIMA
import matplotlib.pyplot as plt
import collections
import sklearn.svm as svm
import pylab as pl
import timeit
from sklearn.utils import shuffle
from pylab import *
from numpy import *
import scipy as sc
from pandas import Series
import statsmodels.tsa
from statsmodels.tsa.arima_process import arma_generate_sample, ArmaProcess
from statsmodels.graphics.api import qqplot
import csv
import collections
import statsmodels.api as sm


a = Series(T['Intensity'].astype(np.float))
#, index=data['RetentionTime'])

fig = plt.figure(1, figsize=(20,10))
fig.suptitle('ACF and PACF of data and diff(1) ')
    
subplot1 = fig.add_subplot(231)   #top left
subplot1 = a.plot()
subplot1.set_title("TS: ")
subplot2 = fig.add_subplot(232)   #top right
subplot2.plot(np.array(statsmodels.tsa.stattools.acf(a, unbiased=False, nlags=10, qstat=False, fft=False, alpha=None)).astype(np.float), 'ro')
subplot2.set_title("ACF")
#subplot2.plot(arma_t.acf(10), 'go')
subplot3 = fig.add_subplot(233)   #bottom left
subplot3.plot(np.array(statsmodels.tsa.stattools.pacf(a, nlags=10, method='ywunbiased', alpha=None)).astype(np.float), 'ro')
#subplot3.plot(arma_t.pacf(10), 'go')
subplot3.set_title("PACF") 

acf = statsmodels.tsa.stattools.acf(a, unbiased=False, nlags=3, qstat=False, fft=False, alpha=None)
acf1 = statsmodels.tsa.stattools.acf(a, unbiased=False, nlags=10, qstat=False, fft=False, alpha=None)[1]
acf2 = statsmodels.tsa.stattools.acf(a, unbiased=False, nlags=10, qstat=False, fft=False, alpha=None)[2]
acf3 = statsmodels.tsa.stattools.acf(a, unbiased=False, nlags=10, qstat=False, fft=False, alpha=None)[3]
acf_df = transpose(pd.DataFrame(acf))
acf_df["lag1"] = acf1
acf_df["lag2"] = acf2
acf_df["lag3"] = acf3
acf_df["label"] = label
acf_df["name"] = name_of_example
acf_df = acf_df.drop([0, 1, 2, 3], axis=1)

csvFilePath = os.path.join(table_name, "_acf.csv")
appendDFToCSV_void(acf_df, csvFilePath, sep=";")


#ts_diff=ts.diff()
#Transformacja
roznica = 1
adiff = a.diff(periods = roznica)
#adiff.plot()
srednia = np.mean(adiff[roznica:])
adiff[roznica:] = adiff[roznica:]-srednia

subplot1 = fig.add_subplot(234)   #top left
subplot1 = adiff.plot()
subplot1.set_title("Diff")
subplot2 = fig.add_subplot(235)   #top right
subplot2.plot(np.array(statsmodels.tsa.stattools.acf(adiff[roznica:], unbiased=False, nlags=10, qstat=False, fft=False, alpha=None)).astype(np.float), 'ro')
subplot2.set_title("ACF(diff): "+str(roznica))
subplot3 = fig.add_subplot(236)   #bottom left
subplot3.plot(np.array(statsmodels.tsa.stattools.pacf(adiff[roznica:], nlags=10, method='ywunbiased', alpha=None)).astype(np.float), 'ro', linewidth=0)
subplot3.set_title("PACF(diff): "+str(roznica))
#fig.savefig(name+"_autocorrelations.png")
plt.close(fig)