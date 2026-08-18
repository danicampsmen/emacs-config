#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex

# Escala amplia de grosores (desde líneas de cota ultrafinas hasta títulos y énfasis macro)
WIDTHS = [
    0.5,   # 0. Extra fino / Hairline (Líneas de cota, cuadrículas, tramados)
    0.75,  # 1. Fino sutil (Líneas de referencia secundarias)
    1.0,   # 2. Estándar fino (Trazos generales estándar)
    1.5,   # 3. Medio (Curvas y funciones estándar)
    2.0,   # 4. Semi-grueso (Funciones principales, vectores)
    2.5,   # 5. Grueso (Ejes coordenados principales, fuerzas)
    3.0,   # 6. Muy grueso (Bordes de cuerpos rígidos, límites)
    4.0,   # 7. Extra grueso (Trazos de énfasis máximo, secciones de corte)
    5.0,   # 8. Ultra grueso (Barras, resaltados macro)
    6.0,   # 9. Máximo / Cartel (Trazos pesados de alto impacto)
]

def cycle_width_style(svg, direction=1):
    for node in svg.selection.values():
        if isinstance(node, (inkex.TextElement, inkex.Tspan)):
            continue

        width_str = str(node.style.get('stroke-width', '1')).replace('px', '').replace(',', '.')
        try:
            val = float(width_str)
        except ValueError:
            val = 1.0

        closest_idx = 0
        min_diff = 999.0
        for i, w in enumerate(WIDTHS):
            diff = abs(w - val)
            if diff < min_diff:
                min_diff = diff
                closest_idx = i

        new_width = WIDTHS[(closest_idx + direction) % len(WIDTHS)]
        node.style['stroke-width'] = str(new_width)

        # Si el trazo tiene un patrón de guiones, recalcular su distribución equitativa
        saved_idx_str = node.get('data-dash-idx')
        cur_dash = str(node.style.get('stroke-dasharray', 'none')).strip().lower()
        if (saved_idx_str is not None and saved_idx_str != '0') or (cur_dash != 'none' and cur_dash != ''):
            try:
                from castel_stroke import DASH_PATTERNS, get_node_path_length, is_path_closed, compute_equitable_dasharray
                dash_idx = int(saved_idx_str) if saved_idx_str else 1
                base_pattern = DASH_PATTERNS[dash_idx % len(DASH_PATTERNS)][1]
                if base_pattern != 'none':
                    path_len = get_node_path_length(node)
                    closed = is_path_closed(node)
                    node.style['stroke-dasharray'] = compute_equitable_dasharray(base_pattern, path_len, stroke_width=new_width, is_closed=closed)
            except Exception:
                pass

        # Sincronizar escala de flecha intermedia si existe
        node_id = node.get('id')
        if node_id:
            try:
                from castel_arrow import ArrowHelper
                helpers = svg.xpath(f'//*[@data-parent-id="{node_id}" and @class="mid-arrow-helper"]')
                if helpers:
                    is_rev = helpers[0].get('data-reverse') == 'true'
                    ArrowHelper.create_mid_arrow(svg, node, reverse=is_rev)
            except Exception:
                pass

class CycleWidth(inkex.EffectExtension):
    def effect(self):
        cycle_width_style(self.svg, direction=1)

if __name__ == '__main__':
    CycleWidth().run()
