import sys
import std_containers


cube = (((1, 2), (3, 4)), ((5, 6), (7, 8)))


if cube != std_containers.cident(cube):
  raise RuntimeError, "bad cident"


p = (1,2)
if p != std_containers.pident(p):
  raise RuntimeError, "bad pident"

v = (1,2,3,4,5,6)

if v != std_containers.vident(v):
  raise RuntimeError, "bad pident"


if v != std_containers.videntu(v):
  raise RuntimeError, "bad videntu"

vu = std_containers.vector_ui(v)
if vu[2] != std_containers.videntu(vu)[2]:
  raise RuntimeError, "bad videntu"
  

if v[0:3] != vu[0:3]:
  raise RuntimeError, "bad getslice"
  

m = ((1,2,3),(2,3),(3,4))
if m != std_containers.mident(m):
  raise RuntimeError, "bad getslice"
  

mi = std_containers.imatrix(m)
mc = std_containers.cmatrix(m)
if mi[0][1] != mc[0][1]:
  raise RuntimeError, "bad matrix"


map ={}
map['hello'] = 1
map['hi'] = 2
map['3'] = 2

if map != std_containers.mapident(map):
  raise RuntimeError, "bad map"
  

