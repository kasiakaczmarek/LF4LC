# -*- coding: utf-8 -*-
"""
Created on Wed Jun 24 16:04:53 2020

@author: k
"""


duration = np.arange(df4.lengt.min(),df4.lengt.max()+1, 1)
a = df4.lengt.min()
b = df4.lengt.quantile(0.95)
duration_short = fuzz.trapmf(duration ,[a, a,a + (b-a)/4,a + (b-a)/2])
duration_medium = fuzz.trapmf(duration ,[a + (b-a)/4, a + (b-a)/3,a + (b-a)*2/3,a + (b-a)*3/4])
duration_long = fuzz.trapmf(duration ,[a + (b-a)/2 , a + (b-a)*3/4, df4.lengt.max(), df4.lengt.max()])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(duration, duration_short, 'b', linewidth=1.5, label='duration_short')
ax0.plot(duration, duration_medium, 'g', linewidth=1.5, label='duration_medium')
ax0.plot(duration, duration_long, 'r', linewidth=1.5, label='duration_long')
ax0.set_title('Duration')
ax0.legend()
ax0.set_ylim([0, 1.05])
fig.savefig("_duration.pdf", bbox_inches='tight')        

dynamics = np.arange(df4.dynamics.min(),df4.dynamics.max()+0.05, 0.01)
# Input Membership Functions
a = df4.dynamics.min()
b = df4.dynamics.max()
dynamics_decreasing = fuzz.trapmf(dynamics ,[a, a,a + (b-a)/4,a + (b-a)/2])
dynamics_constant = fuzz.trapmf(dynamics ,[a + (b-a)/4, a + (b-a)/3,a + (b-a)*2/3,a + (b-a)*3/4])
dynamics_increasing = fuzz.trapmf(dynamics ,[a + (b-a)/2 , a + (b-a)*3/4, b, b])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(dynamics, dynamics_decreasing, 'b', linewidth=1.5, label='dynamics_decreasing')
ax0.plot(dynamics, dynamics_constant, 'g', linewidth=1.5, label='dynamics_constant')
ax0.plot(dynamics, dynamics_increasing, 'r', linewidth=1.5, label='dynamics_increasing')
ax0.set_title('Dynamics')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])
fig.savefig("_dynamics.pdf", bbox_inches='tight')        


variability = np.arange(df4.variability.min(),df4.variability.max()+0.1, 0.1)

a = df4.variability.min()
b = df4.variability.quantile(0.95)
variability_low = fuzz.trapmf(variability, [a, a,a + (b-a)/4,a + (b-a)/2])
variability_medium = fuzz.trapmf(variability, 
                                 [a + (b-a)/4, a + (b-a)/3,a + (b-a)*2/3,a + (b-a)*3/4])
variability_high = fuzz.trapmf(variability, 
                               [a + (b-a)/2 , a + (b-a)*3/4, df4.variability.max(), df4.variability.max()])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(variability, variability_low, 'b', linewidth=1.5, label='variability_low')
ax0.plot(variability, variability_medium, 'g', linewidth=1.5, label='variability_medium')
ax0.plot(variability, variability_high, 'r', linewidth=1.5, label='variability_high')
ax0.set_title('Variability')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])
fig.savefig("_variability.pdf", bbox_inches='tight')        


mse = np.arange(df4.mse.min(),df4.mse.max()+0.1, 0.1)

a = max_error # bo taki jest błąd w naszym algorytmie segmentacji
b = df4.mse.quantile(0.95)
mse_low = fuzz.trapmf(mse, [df4.mse.min(), df4.mse.min(),a + (b-a)/4,a + (b-a)/2])
mse_medium = fuzz.trapmf(mse, 
                                 [a + (b-a)/4, a + (b-a)/3,a + (b-a)*2/3,a + (b-a)*3/4])
mse_high = fuzz.trapmf(mse, 
                               [a + (b-a)/2 , a + (b-a)*3/4, df4.mse.max(), df4.mse.max()])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(mse, mse_low, 'b', linewidth=1.5, label='mse_low')
ax0.plot(mse, mse_medium, 'g', linewidth=1.5, label='mse_medium')
ax0.plot(mse, mse_high, 'r', linewidth=1.5, label='mse_high')
ax0.set_title('mse')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])

fig.savefig("_mse.pdf", bbox_inches='tight')        
