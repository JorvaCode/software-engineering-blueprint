# ADR-011: Distribucion versionada, allowlist de instalacion y una sola validacion

- **Status**: Accepted
- **Date**: 2026-09-29
- **Scope**: `scripts/`, `.github/workflows/`, `.gitignore`, `VERSION`, `README.md`

## Contexto

El blueprint se distribuye con dos instaladores que copian directorios completos. El
problema no es que copien de mas lo que el proyecto necesita; es que copian de mas lo que
el mantenedor tiene en su arbol de trabajo.

Concretamente: ambos instaladores copian `.opencode/` entero y luego borran `node_modules`
a posteriori. En la practica eso significa que un consumidor recibe tambien el
`package.json`, el lockfile y el `.gitignore` locales de quien ejecuto el instalador. El
limpieza posterior es una lista negra contra un problema de lista blanca, y las listas
negras pierden: cualquier artefacto nuevo que aparezca en `.opencode/` se cuela sin que
nadie se entere hasta que ya esta en el repositorio de un consumidor.

El `.opencode/.gitignore` que existia hacia esto mas dificil de lo que parecio: se
ignoraba a si mismo, asi que era imposible versionarlo. Cada colaborador debia
reinventarlo localmente y cada uno podia cubrir un conjunto distinto de archivos. La
solucion era mover esas reglas al `.gitignore` de la raiz, que si esta versionado.

El segundo problema era la trazabilidad de la distribucion. Una copia instalada no
decia que version era. El repositorio tenia `[1.0.0]` en el CHANGELOG y `[Unreleased]`
con trabajo sin publicar, pero ningun archivo de la raiz declaraba la version, asi que
un consumidor no podia saber que habia recibido ni si lo habia modificado despues. Sin
esa informacion, «actualizar el blueprint» no es una operacion: es volver a instalar y
rezar.

El tercero era que la validacion vivia duplicada. `ci.yml` tenia el gate completo
inline; `reusable-blueprint-validation.yml` tenia una version de cinco lineas que
comprobaba `test -d` en tres directorios. Dos gates que dicen cosas distintas no son
redundancia, son dos fuentes de verdad, y la que nadie mira es la que se queda vieja.
La version de cinco lineas ademas se ofrecia a los consumidores como si validara el
blueprint, y no validaba casi nada.

## Decision

**1. Allowlist en lugar de lista negra.** Los dos instaladores declaran una lista explicita
de entradas —`blueprint`, `templates`, `standards`, `.opencode/agents`, `.opencode/skills`—
y no copian nada mas. La limpieza de `node_modules` desaparece: con una allowlist ya no hay
nada que limpiar, y dejarla seria un mensaje contradictorio. El adaptador OpenCode sigue
siendo opcional, porque no es una dependencia (ADR-002): si el origen no lo tiene, se
informa y se sigue.

El motivo de la allowlist es que el coste de anadir una entrada es visible —una linea y un
ADR— mientras que el coste de que una entrada se cuele es invisible hasta que ya
contamina un proyecto ajeno. Merece la pena que lo previsto cueste mas que lo accidental.

**2. `VERSION` en la raiz y manifiesto de adopcion.** `VERSION` declara la version que
produce este arbol de trabajo. Los instaladores escriben `.blueprint-install.json` en el
destino con la version instalada, la fecha, el instalador usado y las entradas aplicadas.
Un consumidor puede responder «que blueprint tengo» sin buscar en ningun sitio.

La version es `1.1.0-dev` mientras el CHANGELOG tenga trabajo sin publicar, y pasa a
`1.1.0` como parte de la publicacion. Se declara como `-dev` en vez de afirmar `1.1.0`
porque el arbol ya no es lo que se publico como `1.0.0`, y un numero que miente es peor
que un numero con sufijo.

**3. El gate sale del workflow.** El gate se mueve a `scripts/validate-blueprint.sh`,
que `ci.yml` ejecuta. Antes vivia escrito dentro de `ci.yml`, de modo que cada
comprobacion nueva habia que reescribirla a mano para probarla en local. Ahora se
ejecuta en local sin Actions, que es como se desarrollo esto mismo: cada gate
nuevo se comprueba por mutacion antes de commitearse.

**El workflow reutilizable no ejecuta este script, y no puede.** La
documentacion de M11 afirmaba que tambien lo ejecutaba, y era falso. La razon es
estructural, no una omision: el gate valida *este* repositorio, y los instaladores
no copian `scripts/` a ningun consumidor, de modo que un proyecto consumidor no
tiene ese fichero que ejecutar. Compartirlo exigiria enviar el gate de
mantenimiento del repositorio a cada consumidor y anadir `scripts/` a la
allowlist que este mismo ADR define para excluirlo. El workflow reutilizable
declara entonces su propio suelo estructural, que es lo que un consumidor
necesita de verdad: los directorios instalados existen, las quince fases
existen, cada fase de proceso declara sus information items, y el manifiesto de
adopcion registra una version. Las comprobaciones que solo tienen sentido aqui
—ADR, gobernanza, el `VERSION` de este repositorio, los enlaces de esta prosa—
quedan fuera, porque un consumidor no es este repositorio.

Esa segunda implementacion es un coste asumido y declarado, no un descuido: son
dos y van a divergir. Lo que evita que diverjan hacia una afirmacion falsa es que
`scripts/validate-blueprint.sh` comprueba que el workflow reutilizable no invoque
el script. La prosa no se comprueba, porque una frase no es un hecho: la
afirmacion falsa original ponia el sujeto en una frase y la asercion en la
siguiente, y ningun regex sobre frases la detecta sin disparar tambien contra la
correccion que dice lo contrario.

**4. La comprobacion de enlaces cubre referencias y anclas.** El validador anterior solo
miraba enlaces en linea. Una referencia definida con `[texto][ref]` y sin
definir, o un enlace a `archivo.md#seccion` donde la seccion ya no existe, pasaban
silenciosos. Las dos formas son las que mas se pudren, y la segunda es la que hace que la
documentacion parezca rota.

## Alternativas consideradas

**Opcion A — mantener la lista negra y anadir mas exclusiones.** Se descarta. Anadir
`package.json` al `rm -rf` de ambos instaladores funciona hoy y falla manana. Es la
opcion que ya estaba y su coste es invisible solo hasta la primera fuga.

**Opcion B — `git clone` o submódulo para instalar.** Se descarta: exige que el consumidor
tenga git y una conexion, y el compromiso del proyecto es que los instaladores no
necesitan nada externo. Ademas instalaria la historia completa en repositorios que no la
quieren.

**Opcion C — publicar un paquete en un registro.** Es la solucion correcta a largo plazo y
la correcta en cuanto exista un mantenedor que pueda Assume el coste de versionar y
publicar. No se adopta ahora porque no hay quien lo mantenga, y un mecanismo de
publicacion sin mantenedor se convierte en la parte del proyecto que se rompe primero. El
`VERSION` y el manifiesto dejan el camino abierto sin exigirlo.

**Opcion D — dejar dos validaciones.** Se descarta por la razon ya expuesta. La version de
cinco lineas ademas prometia a los consumidores una validacion que no hacia.

**Opcion E — anadir un hash de contenido al manifiesto.** Se descarta, y es la unica
decision de este ADR que se aparta por una restriccion tecnica y no de criterio. `sha256sum` no
es parte de POSIX —en macOS se llama `shasum`— y los instaladores prometen no depender de
nada externo. Un hash haria que dos consumidores con el mismo numero de version pero
contenido distinto parecieran el mismo, lo cual es peor que no tener hash. El
identificador es la version, y es la que el proyecto controla.

## Consecuencias

- Un consumidor recibe unicamente lo que el blueprint es. `.opencode/package.json` y los
  lockfiles dejan de propagarse, y `.opencode/.gitignore` desaparece de raiz porque sus
  reglas viven ahora en un archivo versionado.
- La lista de entradas de la allowlist es la definicion ejecutable de «que es el
  blueprint». Anadir una entrada es una decision de distribucion y por tanto necesita un
  ADR, no un commit cualquiera.
- La validacion se ejecuta en local sin Actions. Los tres paquetes anteriores de este
  trabajo se developing con mutaciones negativas contra un gate copiado del workflow; a
  partir de aqui se ejecuta contra el archivo real, y la copia temporal desaparece.
- La comprobacion de anclas puede fallar sobre enlaces legitimos a secciones que GitHub
  genera de otra forma —codigo en linea en el encabezado, acentos, titulos duplicados—. Se
  ha limitado a encabezados de una linea, que es donde esta el valor, antes que intentar
  replicar el generador de slugs de GitHub completo, que es un proyecto en si mismo.
- `VERSION` es un archivo mas que mantener. El coste es real y pequeno: se actualiza una
  vez por publicacion y la validacion falla si falta o esta vacio.

### Lo que este ADR no hace

- **No purga el contenido de los directorios que si instala.** La allowlist es a nivel
  de directorio: `blueprint/`, `templates/` y `standards/` se copian completos. Un archivo
  suelto que un mantenedor deje dentro de uno de ellos si llega al consumidor. No se
 atiende con una allowlist por archivo porque habria que enumerar las quince fases, las
  plantillas y los estandares, y esa lista dejaria de estar al dia en el primer commit que
  anadiera una fase —fallando en silencio, que es la forma peor de fallar— mientras que
  el problema que resolveria es de baja probabilidad y autocorregible: git muestra un
  archivo suelto en `git status`. El caso que si era realista, un archivo suelto en
  `.opencode/`, queda cubierto, porque ese directorio lo gestiona la herramienta de
  OpenCode. Las pruebas de `scripts/test-installers.sh` y
  `scripts/test-installers.ps1` fijan este comportamiento conocido como tal, en lugar de
  dejarlo implicito.
- **No publica nada en ningun registro.** No hay npm, ni PyPI, ni un release de GitHub.
  El `VERSION` identifica el arbol, no lo distribuye.
- **No verifica la integridad del contenido instalado.** Se registro por que no, en la
  Opcion E: hacerlo exigiria una dependencia que los instaladores prometen no tener.
- **No fuerza la migracion de consumidores existentes.** Un proyecto instalado con la
  version anterior no recibe `.blueprint-install.json` hasta que reinstale. El
  instalador avisa cuando encuentra un manifiesto previo y no lo sobrescribe, porque el
  manifiesto anterior puede haberse editado a mano.
- **No toca las fases 09 a 14.** La fase 09 describe pipelines y la 14 el bucle de mejora;
  introducir aqui notions de versionado o de publicacion seria duplicar un estandar que
  ya existe en otra parte.

## Verificacion

La decision se comprobo ejecutando los dos instaladores contra un destino real y
mutando el validador, no solo leyendolos. Las pruebas de los instaladores viven
en `scripts/test-installers.sh` y `scripts/test-installers.ps1` y se ejecutan en
CI, porque un script de instalacion que nadie ejecuta no es un script probado.

Siete defectos aparecieron al ejecutar en vez de leer, y ninguno era visible en el
codigo:

- El instalador de PowerShell usaba `Write-Host`, que escribe al host pasando
  por alto el flujo de exito. `$out = & .\blueprint-init.ps1 C:\x` devolvia
  vacio, lo que hacia el instalador intestable e inservible desde otro script, y
  lo diferenciaba de su hermano de bash, que si escribe en stdout. Se comprobo
  que `[Console]::Out` tampoco sirve, porque esquiva PowerShell por completo;
  solo `Write-Output` es capturable, y `Write-Host` solo con `6>&1`.
- El validador comprobaba las *definiciones* de enlace pero no sus *usos*. Un
  documento podia definir cada referencia que usaba y aun asi tener una
  indefinida, porque son dos comprobaciones separadas: al borrar una definicion,
  cada `[texto][ref]` que apuntaba a ella deja de ser un enlace sin que nada lo
  note. Ahora un uso sin definicion en el mismo archivo es un defecto.
- El validador buscaba la allowlist en todo el archivo, y ambos instaladores
  nombran cada entrada requerida en el comentario de cabecera. Una comprobacion
  que hace `grep` del archivo sigue pasando despues de que la allowlist
  ejecutable cambie a copiar `.opencode` entero: es decir, pasaba exactamente la
  regresion que el check existe para detectar. Ahora se parsea la asignacion y se
  inspecciona el valor declarado, no el texto que lo rodea.
- Al comprobar usos de enlace aparecieron falsos positivos en documentos que
  explican la sintaxis de los enlaces: el literal va en un `span` de codigo y no
  es un enlace. El validador descarta codigo antes de escanear. Descartar solo
  puede ocultar un enlace real, nunca inventar uno, que es la direccion segura en
  la que fallar.
- Una prueba propia de ausencia de BOM daba falso positivo. `ReadAllText`
  decodifica y descarta el BOM, y `String.StartsWith([char]0xFEFF)` resuelve mal
  su sobrecarga en Windows PowerShell: devolvia `True` sobre un archivo que
  empezaba por `7b 0a`. El instalador escribia correctamente sin BOM; la
  comprobacion ahora mira los bytes.
- La documentacion afirmaba una cosa que el codigo hacia imposible. Decia, en el
  README, el CHANGELOG, el AGENTS y este ADR, que el workflow reutilizable
  ejecutaba `scripts/validate-blueprint.sh`, y por tanto que habia «una
  implementacion, tres ejecutores». No lo ejecutaba, y no podia: la allowlist de
  este mismo ADR excluye `scripts/`, asi que un consumidor no tiene el fichero.
  Ninguno de los dos lados estaba mal por si solo —el workflow es correcto, la
  documentacion es que exagera— y ninguno se delata leyendo solo uno de los dos.
  La contradiccion era ademas autoinformante: el CHANGELOG decia que el workflow
  se habia puesto a ejecutar el script para no duplicar el gate, y lo unico que
  hacia era duplicarlo. Esto lo apareció leer la documentacion contra la decision
  de allowlist, que es un cruzamiento que ninguna de las dos mitades hace consigo
  misma. Un gate que hubiera unsatisfactory aqui: el validador comprueba que el
  workflow no *invoque* el script, y no puede comprobar que la prosa no lo
  *afirme*, porque la frase original partia el sujeto y la asercion en dos
  frases y la correccion que dice lo contrario dispararia cualquier regex igual.
  Se corrige la prosa y se cubre el comportamiento, y se deja constancia de que
  la prosa no esta cubierta.
- El ejemplo de uso del workflow reutilizable fijaba `@v1.0.0`, que es la
  etiqueta anterior a este trabajo: un consumidor que lo siguiera al pie de la
  letra recibia los tres `test -d` originales. El pin por etiqueta es el
  correcto, porque un gate que se mueve solo no es un gate, pero un ejemplo que
  instala un gate mas debil del que el repositorio cree tener es peor que no
  documentarlo. El comentario de uso lo dice y el suelo nuevo viaja en la
  siguiente etiqueta.

Se deja constancia de los siete porque son la clase de defecto que aparece al
ejecutar y no al leer, y porque el primero habria sido facil de declarar
«funciona» sin haberlo intentado nunca. Dos de ellos —el `Write-Host` y la
allowlist mal comprobada— eran la razon entera de este ADR, y ninguno se habria
encontrado leyendo el codigo. El sexto no es de ejecucion sino de
contradiccion: aparecio al poner la documentacion delante de la decision que
dice lo contrario, que es la unica forma de que aparezca.
