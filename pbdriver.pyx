#!/usr/bin/python
from pieva import *
from screen import Screen
import numpy as np
cimport numpy as np

from bibliopixel.drivers.driver_base import DriverBase

class DriverPieva(DriverBase):

    def __init__(self, int num=0, int width=0, int height=0):
        super(DriverPieva, self).__init__(num, width, height)
        self.screen = Screen(sections)
        self.screen.dimm(0)
        self.pixels = width * height
        self.width = width
        self.height = height
        self.bitmap = np.zeros([140, 140])

    def update(self, data):
        if len(data) != self.pixels * 3:
            print "Data length mismatch"
            return

        cdef int i, r, g, b, rgb
        for i in range(self.pixels):
            r = data[i * 3 + 0]
            g = data[i * 3 + 1]
            b = data[i * 3 + 2]
            rgb = (r << 16) + (g << 8) + b
            self.draw(self.bitmap, i, rgb)
        self.screen.send(self.bitmap)

    def draw(self, bitmap, int i, int rgb):
        bitmap[i % self.width][i / self.height] = rgb

class DriverPievaX4(DriverPieva):
    def draw(self, bitmap, int i, int rgb):
        cdef int iwidth = i % self.width
        cdef int iheight = i / self.width
        bitmap[iwidth][iheight] = rgb
        bitmap[iheight][139 - iwidth] = rgb
        bitmap[139 - iheight][iwidth] = rgb
        bitmap[139 - iwidth][139 - iheight] = rgb

class DriverPievaX4Rev(DriverPieva):
    def draw(self, bitmap, int i, int rgb):
        cdef int iwidth = i % self.width
        cdef int iheight = i / self.height
        bitmap[70 - iwidth][70 - iheight] = rgb
        bitmap[70 - iheight][70 + iwidth] = rgb
        bitmap[70 + iheight][70 - iwidth] = rgb
        bitmap[70 + iwidth][70 + iheight] = rgb
