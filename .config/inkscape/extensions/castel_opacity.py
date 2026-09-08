#!/usr/bin/env python3
import inkex

# Gradiente completo de opacidades para capas, superposiciones, halos y marcas tenues
OPACITIES = [
    1.00,  # 0. 100% (Totalmente opaco)
    0.85,  # 1. 85%  (Opaco sutil, evita tapar completamente capas inferiores)
    0.70,  # 2. 70%  (Semitransparente alto, ideal para conjuntos y regiones)
    0.55,  # 3. 55%  (Medio estándar, intersecciones y sombreados)
    0.40,  # 4. 40%  (Translúcido, fondos de figuras y planos posteriores)
    0.25,  # 5. 25%  (Muy translúcido, efecto fantasma / ghosting)
    0.15,  # 6. 15%  (Tenue, halos, nubes de probabilidad, dispersión)
    0.05,  # 7. 5%   (Casi invisible, marcas de guía y alineación de fondo)
]

def cycle_opacity_style(svg, direction=1):
    for node in svg.selection.values():
        val = float(node.style.get('opacity', '1.0'))
        
        closest_idx = 0
        min_diff = 999.0
        for i, op in enumerate(OPACITIES):
            diff = abs(op - val)
            if diff < min_diff:
                min_diff = diff
                closest_idx = i

        new_op = OPACITIES[(closest_idx + direction) % len(OPACITIES)]
        node.style['opacity'] = f'{new_op:.2f}'.rstrip('0').rstrip('.')

class CycleOpacity(inkex.EffectExtension):
    def effect(self):
        cycle_opacity_style(self.svg, direction=1)

if __name__ == '__main__':
    CycleOpacity().run()
