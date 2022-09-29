# -*- coding: utf-8 -*-
"""
Created on Tue Jun 23 23:06:54 2020

@author: k
"""

import os
from pathlib import Path
import sklearn 
import sklearn.linear_model
import pandas as pd
from scipy import interpolate
import matplotlib.pyplot as plt
from sklearn import linear_model
import skfuzzy as fuzz
import numpy as np
import numpy as np
import pandas as pd
from statsmodels.tsa.arima_model import ARIMA
import matplotlib.pyplot as plt
import collections
import sklearn.svm as svm
import pylab as pl
import timeit
from sklearn.utils import shuffle
#from sklearn.cross_validation import StratifiedKFold, cross_val_score
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

from sklearn import preprocessing


def appendDFToCSV_void(df, csvFilePath, Rownames=False, sep=";"):
    import os
    if not os.path.isfile(csvFilePath):
        df.to_csv(csvFilePath, mode='a', index=Rownames, sep=sep)
    elif len(df.columns) != len(pd.read_csv(csvFilePath, nrows=1, sep=sep).columns):
        raise Exception("Columns do not match!! Dataframe has " + str(len(df.columns)) + " columns. CSV file has " + str(len(pd.read_csv(csvFilePath, nrows=1, sep=sep).columns)) + " columns.")
    elif not (df.columns == pd.read_csv(csvFilePath, nrows=1, sep=sep).columns).all():
        raise Exception("Columns and column order of dataframe and csv file do not match!!")
    else:
        df.to_csv(csvFilePath, mode='a', index=False, sep=sep, header=False)

# name the run
name_of_run = "20220928"

project_dir = Path(os.getcwd())
levels_up = 2
print(project_dir.parents[levels_up-1])
parent_dir = project_dir.parents[levels_up-1]

#### LS for selected portfolio
# portfolio = "PXD000323"
portfolio = "PXD000324"

scripts_dir = "python_LS_module/python_scripts"
data_dir = "chromatography_data"
output_dir = "python_LS_module/output"
plots_dir = "python_LS_module/plots"

path_scripts = os.path.join(parent_dir, scripts_dir)
path_data_portfolio = os.path.join(parent_dir, data_dir, portfolio)

path_output = os.path.join(parent_dir, output_dir, portfolio, name_of_run)
path_plots = os.path.join(parent_dir, plots_dir, portfolio, name_of_run)
os.makedirs(path_output, exist_ok=True)
os.makedirs(path_plots, exist_ok=True)

# load list of chistograms
f = open(os.path.join(path_data_portfolio, "chromatograms_good.txt"), 'r')
good = f.readlines()
f.close()
s = open(os.path.join(path_data_portfolio, "chromatograms_poor.txt"), 'r')
poor = s.readlines()
s.close()

# error term
max_error = 10

#ling_var = "interval"
ling_var = "quantile"

# plot outputs
if_plot = True

# Here we decide whether all chromatograms are created
# or only the first k from each portfolio
all_summaries = True
k = 10
first = True

label = '_good_'
if(all_summaries):k = len(good)
for i in range(k):
    print(good[i])
    # i=91
    name_of_example = good[i][:-1]
    table_name = path_output
    name = os.path.join(path_data_portfolio, name_of_example + '.RAW_Ms_TIC_chromatogram.txt')
    data_ms_tic = pd.read_table(name, sep = "\t")#[start:end]
    name = name + label
    data = data_ms_tic
    data['Intensity'] = data['Intensity']/1000000
    exec(open(os.path.join(path_scripts, '02_generate_segments.py')).read())
    exec(open(os.path.join(path_scripts, '03_time_series_analysis.py')).read())
    if(first):exec(open(os.path.join(path_scripts, '04_set_up_ling_vars_quantile.py')).read())
    exec(open(os.path.join(path_scripts, '041_set_up_ling_var_of_time.py')).read())
    exec(open(os.path.join(path_scripts, '05_summarize_segments.py')).read())
    first = False


label = '_poor_'
if(all_summaries):k = len(poor)
for i in range(k):
    print(poor[i])
    i = 56
    name_of_example=poor[i][:-1]
    table_name = path_output
    name = os.path.join(path_data_portfolio, name_of_example + '.RAW_Ms_TIC_chromatogram.txt')
    data_ms_tic = pd.read_table(name, sep="\t")#[start:end]
    name=name+label
    data=data_ms_tic
    data['Intensity']=data['Intensity']/1000000
    exec(open(os.path.join(path_scripts, '02_generate_segments.py')).read())
    exec(open(os.path.join(path_scripts, '03_time_series_analysis.py')).read())
    exec(open(os.path.join(path_scripts, '041_set_up_ling_var_of_time.py')).read())
    exec(open(os.path.join(path_scripts, '05_summarize_segments.py')).read())
