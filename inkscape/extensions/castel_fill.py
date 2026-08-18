#!/usr/bin/env python3
import inkex

# Paleta completa de rellenos (Sólidos neutros + Tonos pastel para conjuntos y sombreados)
FILLS = [
    'none',     # 0. Transparente
    '#ffffff',  # 1. Blanco sólido (Tapa líneas de fondo)
    '#f5f5f5',  # 2. Gris Ultra Claro (Cajas y fondos suaves)
    '#e0e0e0',  # 3. Gris Medio (Sombreados de cuerpos)
    '#000000',  # 4. Negro Sólido
    '#ffcdd2',  # 5. Rojo Pastel (Subconjuntos A, rechazos)
    '#ffe0b2',  # 6. Naranja Pastel (Regiones de integración)
    '#fff9c4',  # 7. Amarillo Pastel (Luz, áreas bajo la curva)
    '#c8e6c9',  # 8. Verde Pastel (Subconjuntos B, convergencia)
    '#b2dfdb',  # 9. Menta / Teal Pastel (Superficies)
    '#bbdefb',  # 10. Azul Pastel (Entornos abiertos U, interiores)
    '#c5cae9',  # 11. Azul Marino / Navy Pastel
    '#e1bee7',  # 12. Púrpura Pastel (Intersecciones U ∩ V)
    '#ea80fc',  # 13. Magenta Pastel
    '#f8bbd0',  # 14. Rosa Pastel (Bolas abiertas, topología)
    '#d7ccc8',  # 15. Marrón Pastel (Masas, bloques)
]

def cycle_fill_style(svg, direction=1):
    for node in svg.selection.values():
        if isinstance(node, (inkex.TextElement, inkex.Tspan)):
            continue

        current = str(node.style.get('fill', 'none')).strip().lower()
        try:
            idx = FILLS.index(current)
        except ValueError:
            idx = 0

        new_fill = FILLS[(idx + direction) % len(FILLS)]
        node.style['fill'] = new_fill

class CycleFill(inkex.EffectExtension):
    def effect(self):
        cycle_fill_style(self.svg, direction=1)

if __name__ == '__main__':
    CycleFill().run()
