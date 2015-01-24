Basado en el plugin de Statik https://bitbucket.org/Polvora/force-picker

###Descripción
Mini-plugin para los pick-up games (PUGs), que tira a 2 jugadores al azar que estén en spec a pickear, útil cuando nadie se pasa después de un rato, si algun jugador se paso previamente a pickear solo elegirá al del equipo contrario.

###Comandos
`!forcepick` - `!fp` - `.fp` - Cualquiera de los 2 hace lo mismo, manda a 2 jugadores de spec a pickear inmediatamente.
`!forcepick <tiempo>` - `!fp <tiempo>` - Al agregar un valor de tiempo (en segundos) se hará una cuenta regresiva con ese tiempo. Esto para darle tiempo a los jugadores antes de forzarlos a pickear. 
Tambien se puede usar por consola: `sm_forcepick` - `sm_fp`. 
Nota: Estos comandos solo funcionan para quienes sean admins genericos.

###Requerimientos
Una version de Sourcemod reciente y funcional (Versión Actual: 1.6.3), probablemente también funcione con versiones antiguas.
 
 
###Instalación
Como cualquier otro plugin, copiar el archivo *forcepicker.smx* a */addons/sourcemod/plugins* del directorio de tf2.
Para cargar el plugin puede reiniciar el server, cambiar de mapa o con rcon escribir este comando:

`rcon sm plugins load forcepicker`

O con el comando de chat 
`!rcon sm plugins load forcepicker` (Necesita flag `m`)

 
###Descarga
Compila el codigo fuente en el [compilador en linea](http://www.sourcemod.net/compiler.php) o descarga la versión compilada aqui: [forcepicker.smx](https://bitbucket.org/Polvora/force-picker/downloads/forcepicker.smx)

###Changelog
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

> [24/01/2015] v2.0.1 - KniL
> * Arreglado el no poder cambiar el mensaje del hud.
> * Añadido una Cvar que permite Activar/Desactivar la función de "Mandar-a-spec cuando se usa el timer" (sm_forcepicker_sendtospec)