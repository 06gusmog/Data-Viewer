import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
"""
location = 'Cell_graph.txt'

cleaned_data = []

with open(location) as file:
    order = []
    for line in file:
        if not line[0].isnumeric():
            for item in line.split(','):
                order.append(item)
            continue
        snippet = {}
        data_in = line.split(',')
        for i, type in enumerate(order):
            snippet[type] = int(data_in[i])
        cleaned_data.append(snippet)

print(cleaned_data)
"""
sns.set_theme(style="whitegrid")

# Load the diamonds dataset
diamonds = pd.read_csv('Cell_graph.txt')

print(diamonds)

# Plot the distribution of clarity ratings, conditional on carat
sns.displot(
    data=diamonds,
    x='time',hue='cell_type',
    kind="kde", height=6,
    multiple="fill", clip=(0, None),
)

plt.show()

print('hello')