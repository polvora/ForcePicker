###Descripción
Mini-plugin para los pick-up games (PUGs), que tira a 2 jugadores al azar que estén en spec a pickear, útil cuando nadie se pasa después de un rato, si algun jugador se paso previamente a pickear solo elegirá al del equipo contrario.
 
*El plugin no mueve a los jugadores a spec automaticamente, por lo tanto antes de ejecutarlo deberian estar todos en spec* `!spec @all`

###Comandos
`!forcepicker` - `/forcepicker` - `.fp` - Cualquiera de los 3 hace lo mismo, manda a 2 jugadores de spec a pickear, tambien se puede usar por consola: `sm_forcepicker`. Los comandos solo funcionan para quienes sean admins genericos
 
###Requerimientos
Una version de Sourcemod reciente y funcional (Versión Actual: 1.6.3), probablemente también funcione con versiones antiguas.
 
###Instalación
Como cualquier otro plugin, copiar el archivo *forcepicker.smx* a */addons/sourcemod/plugins* del directorio de tf2.
Para actualizar los plugins puedes reiniciar el server, cambiar de mapa o con rcon escribir estos dos comandos:

`rcon sm plugins unload_all`

`rcon sm plugins refresh`
 
###Descarga
Compila el codigo fuente en el [compilador en linea](http://www.sourcemod.net/compiler.php) o descarga la versión compilada aqui: [forcepicker.smx](https://bitbucket.org/Polvora/force-picker/downloads/forcepicker.smx)

###Changelog
> [19/12/2014] v1.0 - Publicación Inicial.
>
> [12/01/2015] v1.1 - Cambios en los colores y textos.
>
>  					- Rescritura del codigo que elige jugadores al azar, ahora es mas limpio el proceso.
>
> 					- Cambio de clase dependiendo del modo de juego (HL: Heavy / 6v6: Scout).