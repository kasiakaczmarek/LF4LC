# -*- coding: utf-8 -*-
"""
Created on Tue Jun  9 22:51:36 2020

@author: k
"""

# -*- coding: utf-8 -*-
"""
Created on Fri Jun  3 12:17:16 2016

@author: Mikolaj Wasniewski, Krzysztof Rudas, Katarzyna Kaczmarek
"""

#data['RetentionTime']=data['Index']
#Intensity = data.Intensity

#T = Intensity
#x = data['Intensity']

#data.fillna(method='pad')
#T = data[['RetentionTime', 'Intensity']

min_time = min(data['RetentionTime'])
max_time = max(data['RetentionTime'])

x = pd.DataFrame(dtype = float, data = {'Intensity': data["Intensity"]})
series = x.set_index(pd.DatetimeIndex(data['RetentionTime']*60000000000))
T = series.resample('15S').pad()[1:]
T = T.reset_index()

x = pd.DataFrame(dtype = float, data = {'Intensity': T["Intensity"]})
x['RetentionTime'] = range(len(x))
T = x

def error(T):
    T = T.fillna(method='pad')
    model = linear_model.LinearRegression()

    x = T['RetentionTime'].tolist()
    y = T['Intensity'].tolist()
    xx = array(x)
    xx.shape = (1,xx.shape[0])
    yy = array(y)
    yy.shape = (1,yy.shape[0])
    x = xx.transpose()
    y = yy.transpose()
    model.fit(x,y)
    mse = mean((model.predict(x)-y)**2)
    return(mse)


def create_segment(T, j):
    T = T.fillna(method='pad')
    model = linear_model.LinearRegression()

    x = T['RetentionTime'].tolist()
    y = T['Intensity'].tolist()
    xx = np.array(x)
    xx.shape = (1,xx.shape[0])
    yy = np.array(y)
    yy.shape = (1,yy.shape[0])
    x = xx.transpose()
    y = yy.transpose()
    model.fit(x,y)

    poczatekR = np.array([min(x), model.coef_[0][0]*min(x) + model.intercept_])
    koniecR = np.array([max(x), model.coef_[0][0]*max(x) + model.intercept_])
    lengtR = ((koniecR[1]-poczatekR[1])**2 + (koniecR[0]-poczatekR[0])**2)**.5
    dynamicsR = model.coef_[0]
    variabilityR = np.abs(koniecR[1]-poczatekR[1])
    mseR = np.mean((model.predict(x) - y) ** 2)
    # time faze wstepna, srodkowa, koncowa


    d = {
        'cecha': ['numer', 'poczatek', 'koniec', 'lengt', 'dynamics', 'variability', 'mse', 'time'],
        'R': [j, poczatekR, koniecR, lengtR[0], dynamicsR[0], variabilityR[0], mseR, poczatekR[0]]
    }
    df = pd.DataFrame(data=d, columns=['R'], index=d['cecha'])
    return df.transpose()

def concat(seg_ts, seg_new, j):
    seg_ts = seg_ts.append(seg_new, ignore_index=True)
    return seg_ts

def sliding_window(T,max_error):
    T = T.fillna(method='pad')

    anchor = 1
    j = 1
    while anchor < T.shape[0]:
        i = 2
        while error(T.iloc[anchor:(anchor+i),]) < max_error:
            i += 1
            if anchor + i > T.shape[0]:
                break
        if j == 1:
            seg_ts = create_segment(T.iloc[anchor:(anchor+i),], j)
        else:
            seg_new = create_segment(T.iloc[anchor:(anchor+i),], 1)
            seg_ts = concat(seg_ts, seg_new, j)
        anchor = anchor + i
        j = j + 1
        print(anchor, j)

    return seg_ts


# PLOT with segments - no Intensity standarization
start = 0
end = T.shape[0]

df2 = sliding_window(T.iloc[start:end, ], max_error)
plt.figure(figsize=(12, 10))
plt.plot(T['RetentionTime'][start:end], T['Intensity'][start:end], c = 'black', ls = ('dotted'), lw = 1)
for i in range(df2.shape[0]):
    plt.plot([df2.iloc[i, 1][0], df2.iloc[i, 2][0]],
             [df2.iloc[i, 1][1], df2.iloc[i, 2][1]], color = "teal", lw = 2, alpha = 0.7)

if if_plot: plt.savefig(os.path.join(path_segments_plots, "no_standard" + label + name_of_example + "_segments.pdf"), bbox_inches = 'tight')
plt.close()


# standardization of dependent variable: intensity
T["Intensity"] = preprocessing.scale(T["Intensity"])*100

start = 0
end = T.shape[0]

df2 = sliding_window(T.iloc[start:end, ], max_error)
plt.figure(figsize=(12, 10))
plt.plot(T['RetentionTime'][start:end], T['Intensity'][start:end], c = 'black', ls = ('dotted'), lw = 1)
for i in range(df2.shape[0]):
    plt.plot([df2.iloc[i, 1][0], df2.iloc[i, 2][0]],
             [df2.iloc[i, 1][1], df2.iloc[i, 2][1]], color = "teal", lw = 2, alpha = 0.7)

# real time on x axis
locs, labels = xticks()
l = len(T['RetentionTime'][start:end])
nr_of_labels = 15
n = max_time/nr_of_labels
a = np.arange(min_time, max_time, n)
a = a.round(1)
a.astype(str)
label_step = floor(l/(nr_of_labels-1))
xticks(np.arange(0, l, step=label_step), a.astype(str))

if if_plot: plt.savefig(os.path.join(path_segments_plots, label + name_of_example + "_segments.pdf"), bbox_inches = 'tight')
plt.close()

#df3 = sliding_window(T,max_error)

df4 = df2.iloc[:, 3:].astype('float')
df4['time'] = df2.iloc[:, 7]/end
seg_summary = df4.describe()
seg_summary['label'] = label
df4.index = np.arange(0, df4.shape[0], 1)

summary_intensity = T['Intensity'].describe()
summary_time = T['RetentionTime'].describe()
seg_summary['summary_intensity'] = summary_intensity
seg_summary['summary_time'] = summary_time
seg_summary['id'] = name_of_example
seg_summary['statistic'] = seg_summary.index

csvFilePath = os.path.join(table_name, "_summary_segments.csv")
appendDFToCSV_void(seg_summary, csvFilePath, sep = ";")

first_element = df4.iloc[0]
first_element["type"] = "first"

last_element=df4.iloc[df4.shape[0]-1]
last_element["type"] = "last"

border_segments = transpose(pd.concat([first_element,last_element],1))
border_segments['id'] = name_of_example
border_segments['label'] = label
csvFilePath = os.path.join(table_name, "_border_segments.csv")
appendDFToCSV_void(border_segments, csvFilePath, sep = ";")