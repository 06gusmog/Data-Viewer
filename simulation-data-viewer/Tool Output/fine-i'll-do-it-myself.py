import pygame
import pandas as pd

df = pd.read_csv('DNA-match.txt', sep='\t')

size = 50
minvalues = df.min()
maxvalues = df.max()


hist2d = [[0 for x in range(size)] for y in range(size)]

x = 'relatedness'
y = 'DNA-match percentage'
for index, row in df.iterrows():
    #print(type(row[x]))
    #print(type(minvalues[x]))
    #if row[x] < 10 and row[x]!= -1:
    #    print(row[x])
    hist2d[int(((row[x]-minvalues[x])/(maxvalues[x]-minvalues[x]))*(size-1))][int(((row[y]-minvalues[y])/(maxvalues[y]-minvalues[y]))*(size-1))] += 1

print(maxvalues[x])
print(maxvalues[y])

def heat(value):
    #if 0<value < 2:
    #    return (0,0,255)
    if 0 <= value and value <= 255:
        return (value, 0, 0)
    thing = (value - 256) / 10
    if thing <= 255:
        return (255, 0, thing)
    else:
        return (255,255,255)

pygame.init()

scale = 20
window = pygame.display.set_mode((size * scale, size * scale))

for x in range(size):
    for y in range(size):
        #print((hist2d[x][y],hist2d[x][y],hist2d[x][y]))
        window.fill(heat(hist2d[x][y]), pygame.rect.Rect(x*scale, size*scale-y*scale, scale, scale))



while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            exit()
    pygame.display.update()