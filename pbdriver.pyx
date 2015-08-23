#!/usr/bin/python
import cython
from pieva import *
from screen import Screen
import numpy as np
cimport numpy as np

from bibliopixel.drivers.driver_base import DriverBase

cdef class DriverPievaStruct:
    cdef np.int_t height
    cdef np.int_t width
    cdef np.int_t pixels

class DriverPieva(DriverBase, DriverPievaStruct):

    def __init__(self, np.int_t num=0, np.int_t width=0, np.int_t height=0):
        super(DriverPieva, self).__init__(num, width, height)
        self.screen = Screen(sections)
        self.screen.dimm(0)
        self.pixels = width * height
        self.width = width
        self.height = height

    @cython.boundscheck(False)
    def update(self, data):
        if len(data) != self.pixels * 3:
            print "Data length mismatch"
            return

        cdef np.ndarray[np.int_t, ndim=2] bitmap = np.zeros([140, 140], dtype='int')
        cdef np.int_t i, r, g, b, rgb
        for i in range(self.pixels):
            r = data[i * 3 + 0]
            g = data[i * 3 + 1]
            b = data[i * 3 + 2]
            rgb = (r << 16) + (g << 8) + b
            bitmap[i % self.width][i / self.height] = rgb
        self.screen.send(bitmap)

class DriverPievaX4(DriverPieva):
    @cython.boundscheck(False)
    def update(self, data):
        if len(data) != self.pixels * 3:
            print "Data length mismatch"
            return

        cdef np.ndarray[np.int_t, ndim=2] bitmap = np.zeros([140, 140], dtype='int')
        cdef np.int_t i, r, g, b, rgb, iwidth, iheight
        for i in range(self.pixels):
            r = data[i * 3 + 0]
            g = data[i * 3 + 1]
            b = data[i * 3 + 2]
            rgb = (r << 16) + (g << 8) + b
            iwidth = i % self.width
            iheight = i / self.width
            bitmap[iwidth, iheight] = rgb
            bitmap[iheight, 139 - iwidth] = rgb
            bitmap[139 - iheight, iwidth] = rgb
            bitmap[139 - iwidth, 139 - iheight] = rgb

        self.screen.send(bitmap)

class DriverPievaX4Rev(DriverPieva):
    @cython.boundscheck(False)
    def update(self, data):
        if len(data) != self.pixels * 3:
            print "Data length mismatch"
            return

        cdef np.ndarray[np.int_t, ndim=2] bitmap = np.zeros([140, 140], dtype='int')
        cdef np.int_t i, r, g, b, rgb, iwidth, iheight
        for i in range(self.pixels):
            r = data[i * 3 + 0]
            g = data[i * 3 + 1]
            b = data[i * 3 + 2]
            rgb = (r << 16) + (g << 8) + b
            iwidth = i % self.width
            iheight = i / self.height
            bitmap[70 - iwidth, 70 - iheight] = rgb
            bitmap[70 - iheight, 70 + iwidth] = rgb
            bitmap[70 + iheight, 70 - iwidth] = rgb
            bitmap[70 + iwidth, 70 + iheight] = rgb
        self.screen.send(bitmap)
