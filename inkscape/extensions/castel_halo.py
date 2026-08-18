#!/usr/bin/env python3
import inkex

class ToggleBackground(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection.values():
            if isinstance(node, (inkex.TextElement, inkex.Tspan)):
                node_id = node.get_id()
                parent = node.getparent()
                
                # Localización XPath nativa
                existing_halos = parent.xpath(f'//*[@data-parent-id="{node_id}" and @class="text-halo-bg"]')
                if existing_halos:
                    for halo in existing_halos:
                        parent.remove(halo)
                    continue

                # Hack nativo de inkex para obtener la caja local desprovista de rotaciones
                saved_transform = node.transform
                node.transform = inkex.Transform() # Reinicia la matriz local a Identidad
                
                bbox = node.bounding_box()
                
                node.transform = saved_transform # Restaura al momento
                
                if bbox:
                    # Parsear la métrica real del texto para hacer rellenos inteligentes
                    font_size = 12.0
                    try:
                        fs_str = node.style.get('font-size', '12px')
                        font_size = float(''.join(c for c in fs_str if c.isdigit() or c == '.'))
                    except ValueError:
                        pass
                        
                    # Los descenders (g, j, p) estandarizados ocupan ~20% del font-size en SVG
                    optical_trim = font_size * 0.20
                    
                    padding_x = font_size * 0.4  # Margen lateral proporcional a la letra
                    padding_y = font_size * 0.2  # Margen superior proporcional
                    
                    rect = inkex.Rectangle()
                    rect.set('x', str(bbox.left - padding_x))
                    rect.set('y', str(bbox.top - padding_y))
                    rect.set('width', str(bbox.width + padding_x * 2))
                    
                    # Cortamos la base según la métrica tipográfica
                    rect.set('height', str(bbox.height - optical_trim + padding_y * 2))
                    
                    # Redondeado dinámico basado en la tipografía
                    border_radius = str(font_size * 0.3)
                    rect.set('rx', border_radius) 
                    rect.set('ry', border_radius)
                    
                    rect.set('class', 'text-halo-bg')
                    rect.set('data-parent-id', node_id)
                    
                    # Herencia de la rotación / escala original
                    rect.transform = saved_transform
                    
                    rect.style = {'fill': '#ffffff', 'stroke': 'none', 'fill-opacity': '0.9'}
                    
                    # API LXML Nativa: 'addprevious' fuerza al recuadro a insertarse
                    # por detrás del texto en el árbol, asegurando que se vea como fondo.
                    node.addprevious(rect)

if __name__ == '__main__':
    ToggleBackground().run()
