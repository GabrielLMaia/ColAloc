import matplotlib.pyplot as plt
from shapely.geometry.polygon import Polygon
import pandas as pd
import re

class Local():
    def __init__(self,minx,miny,maxx,maxy):
        self.minx = minx
        self.miny = miny
        self.maxx = maxx
        self.maxy = maxy
        self.taxa = 0
        
class Crime():
    def __init__(self,x,y):
        self.x = x
        self.y = y

polyform = open('polygon.txt','r').read()
polyform = re.split(r',(?![^[]*\])',polyform)
    
poly = Polygon([polyform])
x,y = poly.exterior.xy

crimes_doc = pd.read_csv('wikicrimesfortaleza-semdescricao.csv', index_col = None)

crimes = []
crimesx = []
crimesy = []
for crime in crimes_doc.iterrows():
    crimesx.append(crime[1]['CRI_LATITUDE'])
    crimesy.append(crime[1]['CRI_LONGITUDE'])
    crimes.append(Crime(crime[1]['CRI_LONGITUDE'],crime[1]['CRI_LATITUDE']))

maxx = max(x)
minx = min(x)
maxy = max(y)
miny = min(y)

div = 16

uox = (maxx - minx)/div
uoy = (maxy - miny)/div

atualx = minx
divx = []
divx.append(minx)
for i in range(div):
    atualx = atualx + uox
    divx.append(atualx)

atualy = maxy
divy = []
divy.append(maxy)
for i in range(div):
    atualy = atualy - uoy
    divy.append(atualy)

plt.scatter(crimesy,crimesx,s = 1,c ='r',alpha=0.5)
plt.plot(x, y, color='#6699cc',
    linewidth=2, solid_capstyle='round', zorder=2)

for i in divx:
    plt.plot([i,i], [miny,maxy], ':g',alpha=0.7)
    
for i in divy:
    plt.plot([minx,maxx],[i,i], ':g',alpha=0.7)

plt.show()

locais = []
for j,y in enumerate(divy[:-1]):
    for i,x in enumerate(divx[:-1]):
        locais.append(Local(x,y,divx[i+1],divy[j+1]))
  
totalsum = 0
cont = 0
for l in locais:
    sum = 0
    for c in crimes:
        if c.x >= l.minx and c.x < l.maxx  and c.y < l.miny and c.y >= l.maxy:
            sum = sum + 1
    l.taxa = sum
    totalsum = totalsum + sum
    
    cont = cont + 1
# =============================================================================
#     print("Local",cont, "", sum, l.maxx, l.minx, l.maxy, l.miny)
# =============================================================================
# =============================================================================
# print("Total", totalsum)
# print()
# =============================================================================
    
cont = 1
for l in locais:
    if cont == div:
        print(l.taxa)
        cont = 1
    else:
        cont = cont + 1
        
        if l.taxa < 100:
            if l.taxa < 10:
                print(l.taxa, end='    ')
            else:
                 print(l.taxa, end='   ')   
        else:
            print(l.taxa, end='  ')