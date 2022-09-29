
def kwantyfikator(x):
    czesc = np.arange(0, 1.01, 0.01)
    
    majority = fuzz.trapmf(czesc, [0.45, 0.6, 1, 1])
    mniejszosc = fuzz.trapmf(czesc, [0, 0, 0.4, 0.55])
    prawie_wszystkie = fuzz.trapmf(czesc, [0.7, 0.8, 1, 1])
    
    czesc_wiekszeosc = fuzz.interp_membership(czesc, majority, x) # Depends from Step 1
    czesc_mniejszosc = fuzz.interp_membership(czesc, mniejszosc, x)
    czesc_prawie_wszystkie = fuzz.interp_membership(czesc, prawie_wszystkie, x)

    return dict(majority=czesc_wiekszeosc, mniejszosc=czesc_mniejszosc,
                prawie_wszystkie=czesc_prawie_wszystkie)

czesc = np.arange(0, 1.01, 0.01)

#majority = fuzz.trapmf(czesc, [0.45, 0.6, 1, 1])
majority = fuzz.trapmf(czesc, [0.5, 0.7, 1, 1])
mniejszosc = fuzz.trapmf(czesc, [0, 0, 0.4, 0.55])
prawie_wszystkie = fuzz.trapmf(czesc, [0.7, 0.8, 1, 1])

# fig, (ax0) = plt.subplots(nrows=1, figsize=(8, 9))
# ax0.plot(czesc, majority, 'b', linewidth=1.5, label='majority')
# ax0.plot(czesc, mniejszosc, 'g', linewidth=1.5, label='minority')
# ax0.plot(czesc, prawie_wszystkie, 'r', linewidth=1.5, label='almost_all')
# ax0.set_title('kwantyfikator')
# ax0.legend(loc = 'lower left')
# ax0.set_ylim([0, 1.05])
# plt.close(fig)

#################
# Funkcje do fuzzyfikacji odpowiednich segmentow szeregu  
def mse_category(mse_in = 0):
    mse_cat_low = fuzz.interp_membership(mse, mse_low, mse_in) 
    mse_cat_medium = fuzz.interp_membership(mse, mse_medium, mse_in)
    mse_cat_high = fuzz.interp_membership(mse, mse_high, mse_in)
    
    return pd.DataFrame([[mse_cat_low, mse_cat_medium, mse_cat_high]], 
                            columns=["mse_low", "mse_medium", "mse_high"])


def mse_table(df):
    n = df.shape[0]
    for i in range(n):
        if i == 0:
            d = mse_category(df.mse[i])
        else:
            d = d.append(mse_category(df.mse[i]),
                         ignore_index=True)
    return d


def time_category(time_in=0):
    time_cat_low = fuzz.interp_membership(time, time_beginning, time_in) 
    time_cat_medium = fuzz.interp_membership(time, time_middle, time_in)
    time_cat_high = fuzz.interp_membership(time, time_ending, time_in)
    
    return pd.DataFrame([[time_cat_low, time_cat_medium, time_cat_high]], 
                            columns=["time_beginning", "time_middle", "time_ending"])


def time_table(df):
    n = df.shape[0]
    for i in range(n):
        if i == 0:
            d = time_category(df.time[i])
        else:
            d = d.append(time_category(df.time[i]),
                         ignore_index=True)
    return d



def variability_category(variability_in=0):
    variability_cat_low = fuzz.interp_membership(variability, variability_low, variability_in) # Depends from Step 1
    variability_cat_medium = fuzz.interp_membership(variability, variability_medium, variability_in)
    variability_cat_high = fuzz.interp_membership(variability, variability_high, variability_in)
    
    return pd.DataFrame([[variability_cat_low, variability_cat_medium, variability_cat_high]], 
                            columns=["variability_low", "variability_medium", "variability_high"])


def variability_table(df):
    n = df.shape[0]
    for i in range(n):
        if i == 0:
            d = variability_category(df.variability[i])
        else:
            d = d.append(variability_category(df.variability[i]),
                         ignore_index=True)
    return d


def duration_category(duration_in = 150):
    duration_cat_short = fuzz.interp_membership(duration,duration_short, duration_in) # Depends from Step 1
    duration_cat_medium = fuzz.interp_membership(duration,duration_medium, duration_in)
    duration_cat_long = fuzz.interp_membership(duration, duration_long, duration_in)
    
    return pd.DataFrame([[duration_cat_short, duration_cat_medium, duration_cat_long]], 
                            columns=["duration_short", "duration_medium", "duration_long"])



def duration_table(df):
    n = df.shape[0]
    for i in range(n):
        if i == 0:
            d = duration_category(df.lengt[i])
        else:
            d = d.append(duration_category(df.lengt[i]),
                         ignore_index=True)
    return d




def dynamics_category(dynamics_in = 0):
    dynamics_cat_decreasing = fuzz.interp_membership(dynamics,dynamics_decreasing, dynamics_in) # Depends from Step 1
    dynamics_cat_constant = fuzz.interp_membership(dynamics,dynamics_constant, dynamics_in)
    dynamics_cat_increasing = fuzz.interp_membership(dynamics, dynamics_increasing, dynamics_in)
    
    return pd.DataFrame([[dynamics_cat_decreasing, dynamics_cat_constant, dynamics_cat_increasing]], 
                            columns=["dynamics_decreasing", "dynamics_constant", "dynamics_increasing"])


def dynamics_table(df):
    n = df.shape[0]
    for i in range(n):
        if i == 0:
            d = dynamics_category(df.dynamics[i])
        else:
            d = d.append(dynamics_category(df.dynamics[i]),
                         ignore_index=True)
    return d

def characteristic_table(df):
    d1 = duration_table(df)
    d2 = dynamics_table(df)
    d3 = variability_table(df)
    #d4 = mse_table(df)
    d4 = time_table(df)
    return pd.concat([d1, d2, d3, d4], axis=1)

#df4

d = characteristic_table(df4)
d['id'] = name_of_example
d['label'] = label
csvFilePath = os.path.join(table_name,"_characteristic_table.csv")
appendDFToCSV_void(d, csvFilePath, False, sep=";")



def Degree_of_truth_ext(d, Q = "majority", P = "duration_medium", R = "dynamics_decreasing"):    
    """
    Stopień prawdy dla zlozonych podsumowan lingwistycznych
    """ 
    
    p = np.fmin(d[P], d[R])
    r = d[R]
    t = np.sum(p)/np.sum(r)
    if np.sum(r) == 0:    
        t = 0
    else:
        t = np.sum(p)/np.sum(r)
        
    return kwantyfikator(t)[Q]
    
Degree_of_truth_ext(d = d)  

     
def Degree_of_truth(d = d, Q = "mniejszosc", P = "duration_long", P2 = ""):
    """
    Stopień prawdy dla prostych podsumowan lingwistycznych
    """    
    if P2 == "":    
        p = np.mean(d[P])
    else:
        p = np.mean(np.fmin(d[P], d[P2]))
    return kwantyfikator(p)[Q]

Degree_of_truth()

Degree_of_truth(d = d, Q = "majority", P = "dynamics_decreasing")
Degree_of_truth(d = d, Q = "majority", P = "duration_short")
Degree_of_truth(d = d, Q = "majority", P = "duration_short", P2 = "dynamics_decreasing")
Degree_of_truth_ext(d = d, Q = "majority", P = "duration_long", R = "dynamics_increasing")



def all_protoform(d):
    """
    Funkcja wyznaczajoca stopnie prawdy dla wszystkich 
    podumowań lingwistycznych (prostych i zlozonych)    
    """
    pp = ["duration_short", "duration_medium", "duration_long"]
    rr = ["dynamics_decreasing", "dynamics_constant", "dynamics_increasing"]
    qq = ["variability_low", "variability_medium", "variability_high"]
    #zz = ["mse_low", "mse_medium", "mse_high"]
    zz = ["time_beginning", "time_middle", "time_ending"]
    protoform = np.empty(120, dtype = "object")
    DoT = np.zeros(120)
    Type = np.zeros(120)
    k = 0
    for i in range(len(pp)):
        DoT[k] = Degree_of_truth(d = d, Q = "majority", P = qq[i])
        protoform[k] = "Most trends are " + qq[i]
        Type[k]=1
        k += 1
        DoT[k] = Degree_of_truth(d = d, Q = "majority", P = pp[i])
        protoform[k] = "Most trends are " + pp[i]
        Type[k]=1
        k += 1
        DoT[k] = Degree_of_truth(d = d, Q = "majority", P = rr[i])
        protoform[k] = "Most trends are " + rr[i]
        Type[k]=1
        k += 1
        DoT[k] = Degree_of_truth(d = d, Q = "majority", P = zz[i])
        protoform[k] = "Most trends are " + zz[i]
        Type[k]=1
        k += 1
    for i in range(len(pp)):
        for j in range(len(rr)):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = qq[j], R = pp[i])
            protoform[k] = "Most " + pp[i] + " trends are " + qq[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = rr[j], R = pp[i])
            protoform[k] = "Most " + pp[i] + " trends are " + rr[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = zz[j], R = pp[i])
            protoform[k] = "Most " + pp[i] + " trends are " + zz[j]
            Type[k]=2
            k += 1
    for i in range(len(pp)):
        for j in range(len(rr)):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = qq[j], R = rr[i])
            protoform[k] = "Most " + rr[i] + " trends are " + qq[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = pp[j], R = rr[i])
            protoform[k] = "Most " + rr[i] + " trends are " + pp[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = zz[j], R = rr[i])
            protoform[k] = "Most " + rr[i] + " trends are " + zz[j]
            Type[k]=2
            k += 1

    for i in range(len(pp)):
        for j in range(len(rr)):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = rr[j], R = qq[i])
            protoform[k] = "Most " + qq[i] + " trends are " + rr[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = pp[j], R = qq[i])
            protoform[k] = "Most " + qq[i] + " trends are " + pp[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = zz[j], R = qq[i])
            protoform[k] = "Most " + qq[i] + " trends are " + zz[j]
            Type[k]=2
            k += 1
            
    for i in range(len(pp)):
        for j in range(len(rr)):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = rr[j], R = zz[i])
            protoform[k] = "Most " + zz[i] + " trends are " + rr[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = pp[j], R = zz[i])
            protoform[k] = "Most " + zz[i] + " trends are " + pp[j]
            Type[k]=2
            k += 1
        for j in range(3):
            DoT[k] = Degree_of_truth_ext(d = d, Q = "majority", P = qq[j], R = zz[i])
            protoform[k] = "Most " + zz[i] + " trends are " + qq[j]
            Type[k]=2
            k += 1
   
    dd = {"protoform":protoform,
         "DoT":DoT,
         "Type":Type}
    dd = pd.DataFrame(dd)   
    return dd[['protoform', "DoT", "Type"]]
         
pd.set_option('max_colwidth', 70)
df_protoform = all_protoform(d)

# 40 najbardzien prawdziwych podsumowan lingwistycznych 
#df_protoform.sort('DoT', ascending = False).head(n = 40)

df_protoform['id'] = name_of_example
df_protoform['label'] = label
csvFilePath = os.path.join(table_name, "_protoforms.csv")
appendDFToCSV_void(df_protoform, csvFilePath, sep=";")