import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

df = pd.read_csv('DNA-match.txt', sep='\t')



# Big bins
plt.hist2d(df['relatedness'], df['DNA-match percentage'], bins=(50, 50), cmap=plt.cm.jet)
 
plt.show()
