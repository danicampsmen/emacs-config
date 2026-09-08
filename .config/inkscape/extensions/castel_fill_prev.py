#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_fill import cycle_fill_style

class CycleFillPrev(inkex.EffectExtension):
    def effect(self):
        cycle_fill_style(self.svg, direction=-1)

if __name__ == '__main__':
    CycleFillPrev().run()
