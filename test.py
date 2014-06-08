from argparse import ArgumentParser
from pieva import *
import fastopc as opc
import time

leds = opc.FastOPC()

def testPattern(pattern):
    global testDotIndex
    pixels = []
    for i in range(len(pattern)):
        if i == testDotIndex:
            pixels += testDot
        else:
            pixels += testBlank
    testDotIndex = testDotIndex + 1
    if(testDotIndex >= len(pattern)):
        testDotIndex = 0
    return pixels
    
def blank(pattern):
    pixels = []
    for led in pattern:
        pixels += testBlank
    return pixels

def test(testSectionIdx):
    for t in range(len(sections[testSectionIdx]['pattern'])):
        s = 0
        pixels = []
        startTime = time.time()
        for section in sections:
            if s == testSectionIdx:
                pixels += testPattern(section['pattern'])
            else:
                pixels += blank(section['pattern'])
            s = s +1
         
        leds.putPixels(0, pixels)
        endTime = time.time()
        print "pushing pixels in", (endTime - startTime), "s"
        if None != screen:
            screen.putPixels(0, pixels)
        time.sleep(0.05)

parser = ArgumentParser(description = "Play test sequences")
parser.add_argument("testSection", type=int, action="store", default=None, nargs="?", help=" - which section to test. All sections will be tested if omitted")
parser.add_argument("--server", action="store", default=None, help="additional OPC server for debug purposes")
cliargs = parser.parse_args()

testDotIndex = 0
testBlank = [0, 0, 0]
testDot = [255, 255, 255]

if None != cliargs.server:
    screen = opc.FastOPC(cliargs.server)
else:
    screen = None


if None != cliargs.testSection:
    currSection = cliargs.testSection
    print "Testing section", currSection 
else:
    currSection = 0
    print "Testing all sections"
print "Control-C to interrupt"

#~ print testPattern(sections[0]['pattern'])

while True:
    test(currSection)
    if None == cliargs.testSection:
        currSection += 1
        if currSection >= len(sections):
            currSection = 0