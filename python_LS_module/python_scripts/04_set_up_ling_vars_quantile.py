# -*- coding: utf-8 -*-
"""
Created on Wed Jun 24 16:04:53 2020

@author: k
"""

duration = np.arange(df4.lengt.min(), df4.lengt.max()+1, 0.01)
a = df4.lengt.min()
b = df4.lengt.quantile(0.95)

if(ling_var == "interval"):
        duration_short = fuzz.trapmf(duration, [a, a, a + (b-a)/4, a + (b-a)/2])
        duration_medium = fuzz.trapmf(duration, [a + (b-a)/4, a + (b-a)/3, a + (b-a)*2/3, a + (b-a)*3/4])
        duration_long = fuzz.trapmf(duration, [a + (b-a)/2, a + (b-a)*3/4, df4.lengt.max(), df4.lengt.max()])
else:
            min_for_universe = a
            max_for_universe = df4.lengt.max()
            first_quartile = np.percentile(df4.lengt, 25)
            median_quartile = np.percentile(df4.lengt, 50)
            third_quartile = np.percentile(df4.lengt, 75)
            duration_short = fuzz.trapmf(duration, [min_for_universe, min_for_universe, first_quartile, median_quartile])
            duration_medium = fuzz.trimf(duration, [first_quartile, median_quartile, third_quartile])
            duration_long = fuzz.trapmf(duration, [median_quartile, third_quartile, max_for_universe, max_for_universe])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(duration, duration_short, 'b', linewidth=1.5, label='duration_short')
ax0.plot(duration, duration_medium, 'g', linewidth=1.5, label='duration_medium')
ax0.plot(duration, duration_long, 'r', linewidth=1.5, label='duration_long')
ax0.set_title('Duration')
ax0.legend()
ax0.set_ylim([0, 1.05])
fig.savefig(os.path.join(path_plots, "_duration_" + ling_var + ".pdf"), bbox_inches='tight')
plt.close()

dynamics = np.arange(df4.dynamics.min(), df4.dynamics.max()+0.05, 0.01)
a = df4.dynamics.min()
b = df4.dynamics.max()

if(ling_var == "interval"):
    dynamics_decreasing = fuzz.trapmf(dynamics, [a, a, a + (b-a)/4, a + (b-a)/2])
    dynamics_constant = fuzz.trapmf(dynamics, [a + (b-a)/4, a + (b-a)/3,a + (b-a)*2/3, a+(b-a)*3/4])
    dynamics_increasing = fuzz.trapmf(dynamics, [a + (b-a)/2, a + (b-a)*3/4, b, b])
else:
            min_for_universe=a
            max_for_universe=df4.dynamics.max()
            first_quartile = np.percentile(df4.dynamics, 25)
            median_quartile = np.percentile(df4.dynamics, 50)
            third_quartile = np.percentile(df4.dynamics, 75)
            dynamics_decreasing = fuzz.trapmf(dynamics, [min_for_universe, min_for_universe, first_quartile, median_quartile])
            dynamics_constant = fuzz.trimf(dynamics, [first_quartile, median_quartile, third_quartile])
            dynamics_increasing = fuzz.trapmf(dynamics, [median_quartile, third_quartile, max_for_universe, max_for_universe])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(dynamics, dynamics_decreasing, 'b', linewidth=1.5, label='dynamics_decreasing')
ax0.plot(dynamics, dynamics_constant, 'g', linewidth=1.5, label='dynamics_constant')
ax0.plot(dynamics, dynamics_increasing, 'r', linewidth=1.5, label='dynamics_increasing')
ax0.set_title('Dynamics')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])
fig.savefig(os.path.join(path_plots, "_dynamics_" + ling_var + ".pdf"), bbox_inches='tight')
plt.close()


variability = np.arange(df4.variability.min(), df4.variability.max()+0.001, 0.001)
a = df4.variability.min()
b = df4.variability.quantile(0.95)

if(ling_var == "interval"):
        variability_low = fuzz.trapmf(variability, [a, a, a + (b-a)/4, a + (b-a)/2])
        variability_medium = fuzz.trapmf(variability, [a + (b-a)/4, a + (b-a)/3, a + (b-a)*2/3, a + (b-a)*3/4])
        variability_high = fuzz.trapmf(variability, [a + (b-a)/2, a + (b-a)*3/4, df4.variability.max(), df4.variability.max()])
else:
            min_for_universe=a
            max_for_universe=df4.variability.max()
            first_quartile = np.percentile(df4.variability, 25)
            median_quartile = np.percentile(df4.variability, 50)
            third_quartile = np.percentile(df4.variability, 75)
            variability_low = fuzz.trapmf(variability, [min_for_universe, min_for_universe, first_quartile, median_quartile])
            variability_medium = fuzz.trimf(variability, [first_quartile, median_quartile, third_quartile])
            variability_high = fuzz.trapmf(variability, [median_quartile, third_quartile, max_for_universe, max_for_universe])



fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(variability, variability_low, 'b', linewidth=1.5, label='variability_low')
ax0.plot(variability, variability_medium, 'g', linewidth=1.5, label='variability_medium')
ax0.plot(variability, variability_high, 'r', linewidth=1.5, label='variability_high')
ax0.set_title('Variability')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])
fig.savefig(os.path.join(path_plots, "_variability_" + ling_var + ".pdf"), bbox_inches='tight')
plt.close()


mse = np.arange(df4.mse.min(),df4.mse.max()+0.1, 0.1)

a = max_error #error in our algorithm of segmentation
b = df4.mse.quantile(0.95)
mse_low = fuzz.trapmf(mse, [df4.mse.min(), df4.mse.min(), a + (b-a)/4, a + (b-a)/2])
mse_medium = fuzz.trapmf(mse, [a + (b-a)/4, a + (b-a)/3, a + (b-a)*2/3, a + (b-a)*3/4])
mse_high = fuzz.trapmf(mse, [a + (b-a)/2, a + (b-a)*3/4, df4.mse.max(), df4.mse.max()])

fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
ax0.plot(mse, mse_low, 'b', linewidth=1.5, label='mse_low')
ax0.plot(mse, mse_medium, 'g', linewidth=1.5, label='mse_medium')
ax0.plot(mse, mse_high, 'r', linewidth=1.5, label='mse_high')
ax0.set_title('mse')
ax0.legend(loc = 'lower left')
ax0.set_ylim([0, 1.05])
fig.savefig(os.path.join(path_plots, "_mse_" + ling_var + ".pdf"), bbox_inches='tight')
plt.close()