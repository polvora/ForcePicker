# Force Picker
Mini-plugin para los pick-up games (PUGs), que tira a 2 jugadores al azar que estén en spec a pickear, útil cuando nadie se pasa después de un rato, si algún jugador se paso previamente a pickear solo elegirá al del equipo contrario.

### Comandos
`!fp [1-30] [stop|spec]` como alias esta también `!forcepicker`

_**Ejemplos:**_

`!fp` Moverá 2 players aleatoriamente a pickear.
`!fp 5` Moverá 2 players aleatoriamente a pickear, si alguno de los players se retira (se va a spec, se desconecta o queda afk) vuelve a mover a el o los players que falten para pickear. El plugin se detiene despues de `5` reintentos, cuando un player mata a otro o cuando se ejecuta !fp 
`!fp 5 spec` Lo mismo que el anterior pero antes de forzar mueve a los jugadores a spec.  
`!fp stop` Para detener los reintentos.

Nota: Estos comandos solo funcionan para quienes sean admins genericos.

### Requerimientos
Una version de Sourcemod reciente y funcional (Versión Actual: 1.6.3), probablemente también funcione con versiones antiguas.

### Instalación
Como cualquier otro plugin, copiar el archivo _**forcepicker.smx**_ a _**/addons/sourcemod/plugins**_ del directorio de tf2.
Para cargar el plugin puede reiniciar el server, cambiar de mapa o con rcon escribir este comando:

`rcon sm plugins load forcepicker`
 
### Descarga
En [Releases](https://github.com/polvora/ForcePicker/releases/) o compila el codigo fuente en el [compilador en linea](http://www.sourcemod.net/compiler.php).

### Changelog
> [19/12/2014] v1.0 - Statik

> * Publicación Inicial.

> [12/01/2015] v1.1 - Statik

> * Cambios en los colores y textos.
> * Rescritura del codigo que elige jugadores al azar, ahora es mas limpio el proceso.
> * Cambio de clase dependiendo del modo de juego (HL: Heavy / 6v6: Scout).

> [20/01/2015] v2.0 - KniL

> * Nueva versión con muchas mejoras!
> * Agregados comandos de admin `!forcepick` y `!fp` como alias de `!forcepicker`.
> * Comandos de admin ahora reciben un argumento de tiempo que activarán una cuenta regresiva. Esta cuenta regresiva sirve para darle tiempo a los jugadores antes de forzarlos a pickear.
> * Agregados varios CVARs que se pueden configurar en `cfg/sourcemod/plugin.forcepicker.cfg` especialmente para customizar el mensaje del HUD.
> * Agregado una función de manda a Spec a los jugadores antes de forzar el pikeo con cuenta regresiva.
> * Arreglado un error que hacía que no se forzara la clase de scout en el equipo red.
> * Otras corecciones de bugs.

> [24/01/2015] v2.1 - KniL

> * Arreglado el no poder cambiar el mensaje del hud.  
> * Añadido una Cvar que permite Activar/Desactivar la función de "Mandar-a-spec cuando se usa el timer" (sm_forcepicker_sendtospec)

> [02/02/2015] v2.2 - Statik

> * Eliminadas todas las Cvars.
> * Eliminados los comandos `.fp` y `!forcepick`.
> * Eliminada la función que elegía la clase dependiendo del modo de juego.
> * Enviar a los jugadores a spec es ahora opcional agregando el argumento `spec` al final del comando.
> * Agregado un límite en el rango de tiempo, desde 5 segundos hasta 10 minutos.
> * Agregada el argumento `stop` al final del comando, este sirve para detener el timer.
> * Reparado un bug que se daba cuando no habia suficiente gente en Spectator.
> * Reparados bugs menores varios.
> * Algunos cambios gráficos.

> [06/02/2015] v2.3 - Statik

> * Reparado bug critico que permitia que cualquier persona ejecutara los comandos.

> [29/04/2020] v3.0 - Statik

> * Eliminada función de cuenta regresiva reemplazada por función de reintentos.
> * Agredada función de reintentos para evitar que admin tenga que manualmente ejecutar el comando cada vez que un player falle al pickear.
> * Agregada detección de retirada, detecta player que se pasa a spec o se desconecta.
> * Agregada funcion de AFK para prevenir que pickeo se estanque debido a player AFK.
> * Agregada detección cuando player mata a otro para dar por seleccionado a los pickers y por tanto terminar con los reintentos.
> * Agregada mitigación para disminuir la probabilidad que un player sea pickeado 2 veces seguidas.
