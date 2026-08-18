#!/bin/bash
# -----------------------------------------------------------------------------
# SCRIPT PARA INSTALAR LAS EXTENSIONES DE ESTILO DE GILLES CASTEL EN INKSCAPE
# -----------------------------------------------------------------------------

# 0. Asegurarnos de que la carpeta existe y estamos dentro de ella
echo "Creando carpeta de extensiones si no existe..."
mkdir -p ~/.config/inkscape/extensions/
cd ~/.config/inkscape/extensions/

# 1. fs: Relleno Gris + Borde Negro
echo "Creando extensión: Relleno Gris (fs)..."
cat > castel_fs.py << 'EOF'
import inkex
class StyleFS(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = '#e6e6e6'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleFS().run()
EOF
cat > castel_fs.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>1. Relleno Gris + Borde (fs)</name><id>org.castel.fs</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_fs.py</command></script></inkscape-extension>
EOF

# 2. fw: Relleno Blanco + Borde Negro
echo "Creando extensión: Relleno Blanco (fw)..."
cat > castel_fw.py << 'EOF'
import inkex
class StyleFW(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = '#ffffff'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleFW().run()
EOF
cat > castel_fw.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>2. Relleno Blanco + Borde (fw)</name><id>org.castel.fw</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_fw.py</command></script></inkscape-extension>
EOF

# 3. s: Línea Normal
echo "Creando extensión: Línea Normal (s)..."
cat > castel_s.py << 'EOF'
import inkex
class StyleS(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleS().run()
EOF
cat > castel_s.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>3. Linea Normal (s)</name><id>org.castel.s</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_s.py</command></script></inkscape-extension>
EOF

# 4. t: Línea Gruesa
echo "Creando extensión: Línea Gruesa (t)..."
cat > castel_t.py << 'EOF'
import inkex
class StyleT(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '2.5'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleT().run()
EOF
cat > castel_t.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>4. Linea Gruesa (t)</name><id>org.castel.t</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_t.py</command></script></inkscape-extension>
EOF

# 5. d: Línea Punteada
echo "Creando extensión: Línea Punteada (d)..."
cat > castel_d.py << 'EOF'
import inkex
class StyleD(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = '4, 4'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleD().run()
EOF
cat > castel_d.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>5. Linea Punteada (d)</name><id>org.castel.d</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_d.py</command></script></inkscape-extension>
EOF

# 6. a: Flecha Normal
echo "Creando extensión: Flecha Normal (a)..."
cat > castel_a.py << 'EOF'
import inkex
class StyleA(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'url(#Arrow1Mend)'
if __name__ == '__main__': StyleA().run()
EOF
cat > castel_a.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>6. Flecha Normal (a)</name><id>org.castel.a</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_a.py</command></script></inkscape-extension>
EOF

# 7. da: Flecha Punteada
echo "Creando extensión: Flecha Punteada (da)..."
cat > castel_da.py << 'EOF'
import inkex
class StyleDA(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#000000'; node.style['stroke-width'] = '1.5'; node.style['stroke-dasharray'] = '4, 4'; node.style['marker-end'] = 'url(#Arrow1Mend)'
if __name__ == '__main__': StyleDA().run()
EOF
cat > castel_da.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>7. Flecha Punteada (da)</name><id>org.castel.da</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_da.py</command></script></inkscape-extension>
EOF

# 8. e: Énfasis Rojo
echo "Creando extensión: Énfasis Rojo (e)..."
cat > castel_e.py << 'EOF'
import inkex
class StyleE(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#ff0000'; node.style['stroke-width'] = '2.0'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'none'
if __name__ == '__main__': StyleE().run()
EOF
cat > castel_e.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>8. Enfasis Rojo (e)</name><id>org.castel.e</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_e.py</command></script></inkscape-extension>
EOF

# 9. ea: Flecha de Énfasis Roja
echo "Creando extensión: Flecha Roja (ea)..."
cat > castel_ea.py << 'EOF'
import inkex
class StyleEA(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection:
            node.style['fill'] = 'none'; node.style['stroke'] = '#ff0000'; node.style['stroke-width'] = '2.0'; node.style['stroke-dasharray'] = 'none'; node.style['marker-end'] = 'url(#Arrow1Mend)'
if __name__ == '__main__': StyleEA().run()
EOF
cat > castel_ea.inx << 'EOF'
<?xml version="1.0" encoding="UTF-8"?><inkscape-extension><name>9. Flecha Roja (ea)</name><id>org.castel.ea</id><effect><object-type>all</object-type><effects-menu><submenu name="Estilos Castel"/></effects-menu></effect><script><command location="inx" interpreter="python">castel_ea.py</command></script></inkscape-extension>
EOF

# 10. Añadir permisos de ejecución a todos los scripts de Python
echo "Añadiendo permisos de ejecución..."
chmod +x ~/.config/inkscape/extensions/*.py

echo ""
echo "✅ ¡El arsenal completo de Castel ha sido instalado!"
