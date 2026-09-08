#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_charts import cycle_charts_style

class CycleChartsPrev(inkex.EffectExtension):
    def effect(self):
        cycle_charts_style(self.svg, direction=-1)

if __name__ == '__main__':
    CycleChartsPrev().run()
