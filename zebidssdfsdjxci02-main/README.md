# Sistema de Búsqueda de Jugadores Cercanos

## 📋 Descripción
Este recurso agrega un botón en la interfaz que permite buscar al jugador más cercano (dentro de 2 metros), forzar una animación en él y abrir su inventario usando ox_inventory.

## ✨ Características
- Botón flotante estilizado en la esquina inferior derecha
- Busca automáticamente al jugador más cercano
- Aplica animación "dead" al jugador encontrado
- Abre el inventario del jugador objetivo
- Rango de detección: 2 metros

## 📦 Instalación

1. Copia la carpeta del recurso a tu directorio `resources` de FiveM
2. Agrega esto a tu `server.cfg`:
   ```
   ensure nombre-del-recurso
   ```
3. Reinicia el servidor

## 🎮 Uso

1. La UI se cargará automáticamente cuando el recurso esté activo
2. Haz clic en el botón "Buscar Jugador Cercano" (esquina inferior derecha)
3. Si hay un jugador dentro de 2 metros:
   - Se aplicará la animación "dead"
   - Se abrirá su inventario
4. Si no hay jugadores cercanos, verás un mensaje en la consola

## ⚙️ Configuración

### Modificar el rango de búsqueda
Edita `client_search.lua` línea 51:
```lua
if closestPlayer ~= -1 and distance <= 2.0 then  -- Cambia 2.0 por el valor deseado
```

### Cambiar la animación
Edita `client_search.lua` líneas 23-24:
```lua
local dict = "dead"  -- Diccionario de animación
local anim = "dead_a"  -- Nombre de la animación
```

### Personalizar el estilo del botón
Edita `index.html` en la sección `<style>` del `#searchPlayerBtn`

## 🔧 Requisitos
- ox_inventory (para la función de abrir inventario)
- FiveM server actualizado

## 📝 Notas Técnicas

### Estructura de archivos:
```
tu-recurso/
├── fxmanifest.lua       # Manifiesto del recurso
├── client_search.lua    # Lógica del cliente
├── index.html           # UI con el botón
├── assets/
│   ├── index.b957513f.js
│   ├── index-B_Dj6KMd.js
│   ├── index-B0wyOXoM.css
│   └── index.b284bac3.css
└── README.md
```

### Flujo de funcionamiento:
1. Usuario hace clic en el botón HTML
2. JavaScript envía fetch a `https://monitor/searchNearbyPlayer`
3. Lua recibe el callback via `RegisterNUICallback`
4. Se ejecuta la lógica de búsqueda del jugador más cercano
5. Si se encuentra, se aplica animación y abre inventario

## 🐛 Solución de problemas

**El botón no aparece:**
- Verifica que el recurso esté iniciado correctamente
- Revisa la consola F8 en busca de errores
- Asegúrate de que los archivos assets están en la carpeta correcta

**La animación no se aplica:**
- Verifica que el diccionario "dead" existe en el juego
- Prueba con otras animaciones si es necesario

**El inventario no se abre:**
- Confirma que ox_inventory está instalado y funcionando
- Verifica que el evento `ox_inventory:openInventory` es el correcto para tu versión

## 📄 Licencia
Libre para uso personal y comercial.

## 👤 Autor
Creado para facilitar la interacción entre jugadores en servidores FiveM.
