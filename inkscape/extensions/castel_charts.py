#!/usr/bin/env python3
import inkex

# Paleta completa de cartas/conjuntos con emparejamiento coordinado de Relleno + Borde + Opacidad
CHARTS = [
    ('#bbdefb', '#1976d2', '0.55'),  # 0. Carta U (Azul Real)
    ('#c5cae9', '#0d47a1', '0.55'),  # 1. Carta Navy (Azul Marino Profundo)
    ('#ffcdd2', '#d32f2f', '0.55'),  # 2. Carta V (Rojo Carmín)
    ('#c8e6c9', '#2e7d32', '0.55'),  # 3. Carta W (Verde Esmeralda)
    ('#e1bee7', '#7b1fa2', '0.65'),  # 4. Carta Omega (Púrpura / Intersección)
    ('#ea80fc', '#d500f9', '0.55'),  # 5. Carta Magenta (Magenta Vívido)
    ('#ffe0b2', '#ef6c00', '0.55'),  # 6. Carta A (Naranja Ámbar)
    ('#b2ebf2', '#00838f', '0.55'),  # 7. Carta B (Cian / Turquesa)
    ('#fff9c4', '#f57f17', '0.55'),  # 8. Carta C (Amarillo Dorado)
    ('#f8bbd0', '#c2185b', '0.55'),  # 9. Carta D (Rosa / Fucsia)
    ('#eeeeee', '#424242', '0.45'),  # 10. Carta M (Superficie base / Variedad gris)
    ('#ffffff', '#000000', '1.0'),   # 11. Tarjeta Blanca Opaca + Borde negro
    ('none', '#000000', '1.0'),      # 12. Reset: Transparente + Borde negro
]

def cycle_charts_style(svg, direction=1):
    for node in svg.selection.values():
        if isinstance(node, (inkex.TextElement, inkex.Tspan)):
            continue

        cur_fill = str(node.style.get('fill', 'none')).strip().lower()
        
        found_idx = -1
        for i, (f, s, op) in enumerate(CHARTS):
            if f.lower() == cur_fill:
                found_idx = i
                break
        
        if found_idx == -1:
            new_idx = 0 if direction > 0 else len(CHARTS) - 1
        else:
            new_idx = (found_idx + direction) % len(CHARTS)

        fill, stroke, opacity = CHARTS[new_idx]
        node.style['fill'] = fill
        node.style['stroke'] = stroke
        node.style['fill-opacity'] = opacity

        # Sincronizar flechas intermedias (mid-arrow) vinculadas al objeto
        node_id = node.get('id')
        if node_id:
            for helper in svg.xpath(f'//*[@data-parent-id="{node_id}" and @class="mid-arrow-helper"]'):
                helper.style['fill'] = stroke

class CycleCharts(inkex.EffectExtension):
    def effect(self):
        cycle_charts_style(self.svg, direction=1)

if __name__ == '__main__':
    CycleCharts().run()
