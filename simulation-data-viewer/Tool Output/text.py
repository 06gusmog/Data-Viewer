import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


result = pd.read_csv('DNA-match.txt', sep='\t')

fig, ax = plt.subplots(figsize=(6, 6))
ax.hist2d(result["relatedness"], result["DNA-match percentage"], bins=10)
ax.set_xlabel("Bill Length [mm]")
ax.set_ylabel("Flipper Length [mm]")

plt.show()